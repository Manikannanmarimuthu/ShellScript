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
SQL_ROOT_DIR="/hlfapp/Deploy/SQL/hlfdxp_pra1_envcmm.sql"

OUTPUT_PATH="/hlfapp/Deploy/SQL/1.out"

mysql -u "$ENVCMM_DB_USER" -p"$ENVCMM_DB_PASSWORD" -D "$ENVCMM_DB_NAME" <<EOF
print_info "Executed  SQL script in: HOST:$ENVCMM_DB_HOST USER: $ENVCMM_DB_USER  DB: $ENVCMM_DB_NAME"
tee "$OUTPUT_PATH"
source "$SCRIPT_PATH"
notee
exit
EOF