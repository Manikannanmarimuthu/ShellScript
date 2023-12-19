#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <environment> <date format should be:YYYY-MM-DD>"
    exit 1
fi

ENVIRONMENT=$1
DATE=$2

# Validate date format
if ! [[ $DATE =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "Invalid date format. Please use the 'YYYY-MM-DD' format."
    exit 1
fi

if [ "$ENVIRONMENT" == "uat" ]; then
    APP_VERSION=247
    DEPLOY_DIR="/hlfapp/Deploy/uatlogfiles"
elif [ "$ENVIRONMENT" == "prd" ]; then
    APP_VERSION=246
    DEPLOY_DIR="/hlfapp/Deploy/prdlogfiles"
else
    echo "Invalid environment. Supported environments are 'uat' and 'prd'."
    exit 1
fi

LOGS_DIR="/hlfapp/$ENVIRONMENT/logs"

# Create folder based on date with milliseconds
TIMESTAMP=$(date "+%Y%m%d%H%M%S%3N")
TARGET_DIR="$DEPLOY_DIR/$DATE-$TIMESTAMP"

echo "Navigating to logs directory..."
cd "$LOGS_DIR"

echo "Listing files in S3..."
aws s3 ls "s3://mvi-logs-$ENVIRONMENT/$DATE"

echo "Copying logs for app version $APP_VERSION..."
aws s3 cp "s3://mvi-logs-$ENVIRONMENT/$DATE/${ENVIRONMENT}-dxp-online-app-01a_${APP_VERSION}-${DATE}-logs.zip" .
aws s3 cp "s3://mvi-logs-$ENVIRONMENT/$DATE/${ENVIRONMENT}-dxp-online-app-01b_${APP_VERSION}-${DATE}-logs.zip" .

echo "Creating target directory and moving logs..."
mkdir -p "$TARGET_DIR"
mv "${ENVIRONMENT}-dxp-online-app-01a_${APP_VERSION}-${DATE}-logs.zip" "$TARGET_DIR"
mv "${ENVIRONMENT}-dxp-online-app-01b_${APP_VERSION}-${DATE}-logs.zip" "$TARGET_DIR"

echo "Log download and move complete for $ENVIRONMENT environment on $DATE for app version $APP_VERSION. Logs are stored in: $TARGET_DIR"
