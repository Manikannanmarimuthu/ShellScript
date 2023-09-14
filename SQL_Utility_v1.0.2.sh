#!/bin/bash

export param_path=$PORTFOLIO/$ENVIRONMENT/

NOW=$(date +%Y%m%d%H%M%S)

# MySQL server credentials
SYS_DB_USER=$(aws secretsmanager get-secret-value --secret-id  ${param_path}"rds/sys" --query "SecretString" --output text | jq -r '.username')
SYS_DB_PASSWORD=$(aws secretsmanager get-secret-value --secret-id ${param_path}"rds/sys" --query "SecretString" --output text | jq -r '.password')
SYS_DB_HOST=$(aws secretsmanager  get-secret-value --secret-id ${param_path}"rds/sys" | jq --raw-output '.SecretString' | jq -r .host)
SYS_DB_PORT=$(aws secretsmanager  get-secret-value --secret-id ${param_path}"rds/sys" | jq --raw-output '.SecretString' | jq -r .port)
SYS_DB_NAME=$(aws secretsmanager  get-secret-value --secret-id  ${param_path}"rds/sys" | jq --raw-output '.SecretString' | jq -r .db_schema)

RTDAT_DB_USER=$(aws secretsmanager get-secret-value --secret-id ${param_path}"rds/rtdat" --query "SecretString" --output text | jq -r '.username')
RTDAT_DB_PASSWORD=$(aws secretsmanager get-secret-value --secret-id ${param_path}"rds/rtdat" --query "SecretString" --output text | jq -r '.password')
RTDAT_DB_HOST=$(aws secretsmanager  get-secret-value --secret-id ${param_path}"rds/rtdat" | jq --raw-output '.SecretString' | jq -r .host)
RTDAT_DB_PORT=$(aws secretsmanager  get-secret-value --secret-id ${param_path}"rds/rtdat" | jq --raw-output '.SecretString' | jq -r .port)
RTDAT_DB_NAME=$(aws secretsmanager  get-secret-value --secret-id  ${param_path}"rds/rtdat" | jq --raw-output '.SecretString' | jq -r .db_schema)

ENVCMM_DB_USER=$(aws secretsmanager get-secret-value --secret-id ${param_path}"rds/envcmm" --query "SecretString" --output text | jq -r '.username')
ENVCMM_DB_PASSWORD=$(aws secretsmanager get-secret-value --secret-id ${param_path}"rds/envcmm" --query "SecretString" --output text | jq -r '.password')
ENVCMM_DB_HOST=$(aws secretsmanager  get-secret-value --secret-id ${param_path}"rds/envcmm" | jq --raw-output '.SecretString' | jq -r .host)
ENVCMM_DB_PORT=$(aws secretsmanager  get-secret-value --secret-id ${param_path}"rds/envcmm" | jq --raw-output '.SecretString' | jq -r .port)
ENVCMM_DB_NAME=$(aws secretsmanager  get-secret-value --secret-id  ${param_path}"rds/envcmm" | jq --raw-output '.SecretString' | jq -r .db_schema)

# Directory containing SQL script files
SQL_ROOT_DIR="/hlfapp/Deploy/SQL"

# Log file
LOG_FILE="/hlfapp/Deploy/SQL/SQL_logfile${NOW}.log"

print_info() {
   echo "*********************************"
   echo -e "\e[1;34m[INFO]\e[0m \e[1;32m$1\e[0m"
}

# Function to execute SQL scripts and log output
execute_sql_scripts() {
  local dir="$1"
  for SQL_FILE in "$dir"/*.sql
  do
    if [ -f "$SQL_FILE" ]; then
       if echo "$SQL_FILE" | grep -q "sys"; then
          #mysql -h "$SYS_DB_HOST" -u $SYS_DB_USER --password=$SYS_DB_PASSWORD "$SYS_DB_NAME" < "$SQL_FILE" >> "$LOG_FILE" 2>&1
          #mysql -h "$SYS_DB_HOST" -u $SYS_DB_USER --password=$SYS_DB_PASSWORD "$SYS_DB_NAME" -e "source $SQL_FILE" | tee -a "a.out"
          #mysql -h "$SYS_DB_HOST" -u $SYS_DB_USER --password="$SYS_DB_PASSWORD" "$SYS_DB_NAME" --show-warnings -e "source $SQL_FILE" | tee -a "$LOG_FILE"
          mysql -h "$SYS_DB_HOST" -u $SYS_DB_USER --password="$SYS_DB_PASSWORD" "$SYS_DB_NAME"  -X < "$SQL_FILE" | > "actors.xml"
           print_info "Executed  SQL script in: HOST:$SYS_DB_HOST USER: $SYS_DB_USER  DB: $SYS_DB_NAME SQLFile:  $SQL_FILE."
       elif echo "$SQL_FILE" | grep -q "envrtdata"; then
          mysql -h "$RTDAT_DB_HOST" -u $RTDAT_DB_USER --password=$RTDAT_DB_PASSWORD "$RTDAT_DB_NAME" < "$SQL_FILE" >> "$LOG_FILE" 2>&1
           print_info "Executed  SQL script in: HOST:$RTDAT_DB_HOST USER: $RTDAT_DB_USER  DB: $RTDAT_DB_NAME SQLFile:  $SQL_FILE."
       elif echo "$SQL_FILE" | grep -q "envcmm"; then
          mysql -h "$ENVCMM_DB_HOST" -u $ENVCMM_DB_USER --password=$ENVCMM_DB_PASSWORD "$ENVCMM_DB_NAME" < "$SQL_FILE" >> "$LOG_FILE" 2>&1
           print_info "Executed  SQL script in: HOST:$ENVCMM_DB_HOST USER: $ENVCMM_DB_USER  DB: $ENVCMM_DB_NAME SQLFile:  $SQL_FILE."
       fi
    fi
  done

  # Recursively process subdirectories
  for SUBDIR in "$dir"/*
  do
    if [ -d "$SUBDIR" ]; then
      execute_sql_scripts "$SUBDIR"
    fi
  done
}

# Start processing from the root directory
execute_sql_scripts "$SQL_ROOT_DIR"