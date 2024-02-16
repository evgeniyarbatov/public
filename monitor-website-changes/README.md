# Get notified about website changes

Use AWS Lambda to send emails when a website changes. 

The changes are tracked by calculating a hash on the text between `<body>` tags.

### Create new Lambda layer

This is required to extract text between `<body>` tags:

```
rm -rf python/
mkdir -p python/lib/python3.11/site-packages
docker run -v "$PWD":/var/task "public.ecr.aws/sam/build-python3.11" /bin/sh -c "pip install bs4 -t python/lib/python3.11/site-packages/; exit"
zip -r bs4.zip python > /dev/null
aws lambda publish-layer-version --layer-name bs4 --description "BeautifulSoup" --zip-file fileb://bs4.zip --compatible-runtimes "python3.11"
```

### Set Lambda environment variables

- `DYNAMODB_TABLE` - name of DynamoDB to store URL hashes
- `RECIPIENT_EMAIL` - your email address
- `SENDER_EMAIL` - can be same as `RECIPIENT_EMAIL`

### Define URLs you want to monitor

Update `config.json` with the the URLs to track

### Create EventBridge rule

Set the rule to trigger Lambda based on your preferred schedule

### Update code

I am editing code directly in Lambda UI. To sync changes:

