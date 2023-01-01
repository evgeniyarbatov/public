# Strava Webhook

Strava activity post-processing in AWS Lambda:

- rename activities
- hide certain activities from home
- save Strava activity info in DynamoDB

## Setup

- Create AWS Lambda with public function URL: [Lambda function URLs](https://docs.aws.amazon.com/lambda/latest/dg/lambda-urls.html)
- Create Strava app and point to AWS Lambda URL: [How to Create Strava App](https://developers.strava.com/docs/getting-started/#account)
- Subscribe webhook for Strava app: [Strava Webhook](https://developers.strava.com/docs/webhooks/)
- Login with the app to authorize getting Strava webhook events for yourself: [Strava Authentication](https://developers.strava.com/docs/authentication/)

## Config

Lambda function requires these enviroment variables:

- ACTIVITY_DYNAMO_DB - dynamo DB with activityId as key
- OAUTH_TOKEN_DYNAMO_DB	- dynamo DB with userId as key
- DYNAMO_DB_REGION - dynamo DB region
- STRAVA_CLIENT_ID - your Strava client ID
- STRAVA_CLIENT_SECRET - your Strava client secret
- STRAVA_VERIFY_TOKEN - your Strava verify token