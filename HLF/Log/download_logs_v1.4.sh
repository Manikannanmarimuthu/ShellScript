#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <environment> <date format should be:YYYY-MM-DD>"
    exit 1
fi

print_info() {
    echo "*********************************"
    echo -e "\e[1;34m[INFO]\e[0m \e[1m$1\e[0m \e[1;32m\e[0m"
}

print_error() {
    echo "*********************************"
    echo -e "\e[1;31m[ERROR]\e[0m \e[1m$1\e[0m \e[1;32m\e[0m"
}

print_warn() {
    echo "*********************************"
    echo -e "\e[1;33m[WARNING]\e[0m \e[1m$1\e[0m"
    echo "*********************************"
}

ENVIRONMENT=$1
DATE=$2

CONVERTED_DATE=$(date -d "$DATE" "+%Y%m%d")

# Validate date format
if ! [[ $DATE =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    print_error "Invalid date format. Please use the 'YYYY-MM-DD' format."
    exit 1
fi

if [ "$ENVIRONMENT" == "uat" ]; then
    APP_VERSION=247
    DEPLOY_DIR="/hlfapp/Deploy/uatlogfiles"
elif [ "$ENVIRONMENT" == "prd" ]; then
    APP_VERSION=246
    DEPLOY_DIR="/hlfapp/Deploy/prdlogfiles"
elif [ "$ENVIRONMENT" == "sit" ]; then
    DEPLOY_DIR="/hlfapp/Deploy/sitlogfiles"
    LOG_DIRS=(
        "/hlfapp/DXPApp/auth/logfiles"
        "/hlfapp/DXPApp/datasync/logfiles"
        "/hlfapp/DXPApp/inquiry/logfiles"
        "/hlfapp/DXPApp/partitionservice/logfiles"
        "/hlfapp/DXPApp/online/mdynamics/logfiles"
        "/hlfapp/DXPApp/batch/logfiles"
    )
else
    print_error "Invalid environment. Supported environments are 'uat', 'prd', and 'sit'."
    exit 1
fi

current_hostname=$(hostname)

# Set log directory based on environment
case $ENVIRONMENT in
"uat" | "prd")
    LOG_DIR="/hlfapp/$ENVIRONMENT/logs"
    # Create folder based on date with milliseconds
    TIMESTAMP=$(date "+%Y%m%d%H%M%S%3N")
    TARGET_DIR="$DEPLOY_DIR/$DATE-$TIMESTAMP"

    print_info "Navigating to logs directory..."
    cd "$LOGS_DIR"

    print_info "Listing files in S3..."
    aws s3 ls "s3://mvi-logs-$ENVIRONMENT/$DATE"

    print_info "Copying logs for app version $APP_VERSION..."
    aws s3 cp "s3://mvi-logs-$ENVIRONMENT/$DATE/${ENVIRONMENT}-dxp-online-app-01a_${APP_VERSION}-${DATE}-logs.zip" .
    aws s3 cp "s3://mvi-logs-$ENVIRONMENT/$DATE/${ENVIRONMENT}-dxp-online-app-01b_${APP_VERSION}-${DATE}-logs.zip" .

    print_info "Creating target directory and moving logs..."
    mkdir -p "$TARGET_DIR"
    mv "${ENVIRONMENT}-dxp-online-app-01a_${APP_VERSION}-${DATE}-logs.zip" "$TARGET_DIR"
    mv "${ENVIRONMENT}-dxp-online-app-01b_${APP_VERSION}-${DATE}-logs.zip" "$TARGET_DIR"

    print_info "Log download and move complete for $ENVIRONMENT environment on $DATE for app version $APP_VERSION. Logs are stored in: $TARGET_DIR"
    ;;
"sit")
    TIMESTAMP=$(date "+%Y%m%d%H%M%S%3N")
    TARGET_DIR="$DEPLOY_DIR/$current_hostname-$DATE-$TIMESTAMP"
    mkdir -p "$TARGET_DIR"
    print_info "Navigating to logs directories..."
    if [ -n "${LOG_DIRS}" ]; then
        for LOG_DIR in "${LOG_DIRS[@]}"; do
            echo "Copying logs from $LOG_DIR to $TARGET_DIR..."
            find "$LOG_DIR" -type f -name "*${CONVERTED_DATE}*" -exec cp -t "$TARGET_DIR" {} +
            find "$LOG_DIR" -type f -name "mvi-services.log" -exec cp -t "$TARGET_DIR" {} +
        done
    fi
    if [ -n "${LOG_DIR}" ]; then
        echo "Copying logs from $LOG_DIR to $TARGET_DIR..."
        find "$LOG_DIR" -type f -name "*${CONVERTED_DATE}*" -exec cp -t "$TARGET_DIR" {} +
        find "$LOG_DIR" -type f -name "mvi-services.log" -exec cp -t "$TARGET_DIR" {} +
    fi
    print_info "Log move complete for $ENVIRONMENT environment on $DATE. Logs are stored in: $TARGET_DIR"

    print_info "Zipping logs in $TARGET_DIR..."
    zip -r "$TARGET_DIR/logs.zip" "$TARGET_DIR"
    print_info "Logs zipped successfully."

    print_info "Removing original log files..."
    rm -rf "$TARGET_DIR"
    print_info "Original log files removed."
    ;;
*)
    print_error "Invalid environment. Supported environments are 'uat', 'prd', and 'sit'."
    exit 1
    ;;
esac
