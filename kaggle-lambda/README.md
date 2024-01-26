# Update Kaggle Dataset with AWS Lambda

Follow these steps to automate updating Kaggle datasets.

## Create additional AWS Lambda layers

Install Kaggle and any other Python packages you may need. 

Then use AWS CLI to create Lambda function layer.

```
rm -rf python/
mkdir -p python/lib/python3.7/site-packages
docker run -v "$PWD":/var/task "public.ecr.aws/sam/build-python3.7" /bin/sh -c "pip install kaggle -t python/lib/python3.7/site-packages/; exit"
zip -r kaggle.zip python > /dev/null
aws lambda publish-layer-version --layer-name kaggle --description "Kaggle" --zip-file fileb://kaggle.zip --compatible-runtimes "python3.7"
```

## Store Kaggle params as environment variables in AWS Lambda

```
KAGGLE_CONFIG_DIR	/tmp/
KAGGLE_KEY	        <YOUR-KEY-HERE>
KAGGLE_USERNAME	        <YOUR-USERNAME-HERE>
```

## Create AWS Lambda function

Follow the example inside `code` dir.
