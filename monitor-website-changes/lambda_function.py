import json
import hashlib
import boto3
import os
import re

from bs4 import BeautifulSoup
from bs4.element import Comment

from urllib.request import urlopen, Request
from urllib.parse import urlparse

from botocore.exceptions import ClientError


def tag_visible(element):
    if element.parent.name in [
        "style",
        "script",
        "head",
        "title",
        "meta",
        "[document]",
    ]:
        return False
    if isinstance(element, Comment):
        return False
    if re.match(r"[\s\r\n]+", str(element)):
        return False
    return True


def text_from_html(html):
    soup = BeautifulSoup(html, "html.parser")
    texts = soup.findAll(text=True)
    visible_texts = filter(tag_visible, texts)
    return " ".join(t.strip() for t in visible_texts)


def get_body_text(url):
    request = Request(
        url,
        headers={
            "User-Agent": "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:20.0) Gecko/20100101 Firefox/20.0"
        },
    )

    html = urlopen(request)

    body_text = text_from_html(html)
    body_text = body_text.encode(encoding="UTF-8", errors="strict")

    return body_text


def get_text_hash(text):
    return hashlib.sha224(text).hexdigest()


def get_previous_hash(url, table):
    response = table.get_item(Key={"url": url})
    record = response["Item"] if "Item" in response else None
    return record["hash"] if record is not None else None


def update_hash(url, hash, table):
    table.put_item(
        Item={
            "url": url,
            "hash": hash,
        }
    )


def send_email(url):
    ses = boto3.client("ses")
    charset = "UTF-8"

    domain = urlparse(url).netloc
    subject = f"""{domain} update"""

    text_message = f"""{url}"""
    html_message = f"""<html>
<head></head>
<body>
  <p>
    <a href='{url}'>{url}</a>
  </p>
</body>
</html>
"""

    try:
        response = ses.send_email(
            Destination={
                "ToAddresses": [
                    os.environ["RECIPIENT_EMAIL"],
                ],
            },
            Message={
                "Body": {
                    "Html": {
                        "Charset": charset,
                        "Data": html_message,
                    },
                    "Text": {
                        "Charset": charset,
                        "Data": text_message,
                    },
                },
                "Subject": {
                    "Data": subject,
                    "Charset": charset,
                },
            },
            Source=os.environ["SENDER_EMAIL"],
        )
    except ClientError as e:
        print("Error sending email", e)


def lambda_handler(event, context):
    dynamodb = boto3.resource("dynamodb")
    table = dynamodb.Table(os.environ["DYNAMODB_TABLE"])

    config = json.load(open("config.json"))
    for url in config["urls"]:
        body_text = get_body_text(url)

        current_hash = get_text_hash(body_text)
        previous_hash = get_previous_hash(url, table)

        if previous_hash is not None and previous_hash != current_hash:
            send_email(url)

        update_hash(url, current_hash, table)

    return {"statusCode": 200}
