.PHONY: zip clean setup delete update run

FUNCTION_NAME = YourFunctionName
ROLE_NAME = YourRoleName

default: update run

zip:
	mkdir -p output
	mkdir -p build
	zip -j build/function.zip code/*

clean:
	rm -rf build/*
	rm -rf output/*

setup: zip
	$$(aws iam create-role \
	--role-name $(ROLE_NAME) \
	--assume-role-policy-document file://config/trust-policy.json \
	| jq '.Role.Arn')

	$(eval ROLE_ARN := $(shell aws iam get-role \
	--role-name $(ROLE_NAME) \
	| jq '.Role.Arn'))

	aws iam attach-role-policy \
	--role-name $(ROLE_NAME) \
	--policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

	aws iam attach-role-policy \
	--role-name $(ROLE_NAME) \
	--policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

	aws iam attach-role-policy \
	--role-name $(ROLE_NAME) \
	--policy-arn arn:aws:iam::655701728733:policy/service-role/AWSLambdaMicroserviceExecutionRole-91ff712a-8e79-4840-a07f-e9612e4a5f51

	aws lambda create-function \
	--function-name $(FUNCTION_NAME) \
	--zip-file fileb://build/function.zip \
	--handler lambda_function.lambda_handler \
	--runtime python3.9 \
	--role $(ROLE_ARN) \
	> /dev/null 2>&1

	aws lambda wait function-exists \
	--function-name $(FUNCTION_NAME)

delete:
	aws lambda delete-function \
	--function-name $(FUNCTION_NAME)

update: zip
	aws lambda update-function-configuration \
	--function-name $(FUNCTION_NAME) \
	--environment file://config/environment.json \
	| jq '[.Environment]'

	aws lambda wait function-updated \
	--function-name $(FUNCTION_NAME)

	aws lambda update-function-code \
	--function-name $(FUNCTION_NAME) \
	--zip-file fileb://build/function.zip \
	> /dev/null 2>&1

	aws lambda wait function-updated \
	--function-name $(FUNCTION_NAME)

run:
	aws lambda invoke \
	--function-name $(FUNCTION_NAME) \
	output/output.txt \
	--log-type Tail \
	--query 'LogResult' \
	--output text \
	| base64 -d

