#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <environment> <date>"
    exit 1
fi

ENVIRONMENT=$1
DATE=$2

if [ "$ENVIRONMENT" == "uat" ]; then
    APP_VERSION=247
elif [ "$ENVIRONMENT" == "preprod" ]; then
    APP_VERSION=246
else
    echo "Invalid environment. Supported environments are 'uat' and 'preprod'."
    exit 1
fi

echo "Navigating to logs directory..."
cd "/hlfapp/$ENVIRONMENT/logs"

echo "Listing files in S3..."
aws s3 ls "s3://mvi-logs-$ENVIRONMENT/$DATE"

echo "Copying logs for app version $APP_VERSION..."
aws s3 cp "s3://mvi-logs-$ENVIRONMENT/$DATE/${ENVIRONMENT}-dxp-online-app-01a_${APP_VERSION}-${DATE}-logs.zip" .
aws s3 cp "s3://mvi-logs-$ENVIRONMENT/$DATE/${ENVIRONMENT}-dxp-online-app-01b_${APP_VERSION}-${DATE}-logs.zip" .

echo "Log download complete for $ENVIRONMENT environment on $DATE for app version $APP_VERSION."