#!/bin/bash
export param_path=$PORTFOLIO/$ENVIRONMENT/

# Set the environment variable to specify the desired environment
environment=$ENVIRONMENT

# Define the output file paths
SECRET_MANAGER_OUTPUT="secret_manager_output.txt"
PARAMETER_STORE_OUTPUT="parameter_store_output.txt"

# Function to run an AWS Secrets Manager command and capture the output
run_aws_secretsmanager_command() {
    local secret_id="$1"
    local parameter_name="$2"
    command="aws secretsmanager get-secret-value --secret-id '$secret_id' --query 'SecretString' --output text 2>&1 | tee -a '$SECRET_MANAGER_OUTPUT'"
    echo "Running AWS Secrets Manager command:"
    echo "$command"
    eval "$command"
    # Capture the output in the specified format
    echo "$parameter_name : $(cat "$SECRET_MANAGER_OUTPUT" | tail -n 1)" >> "$SECRET_MANAGER_OUTPUT"
    echo "---------------------------" >> "$SECRET_MANAGER_OUTPUT"
}

# Function to run an AWS SSM Parameter Store command and capture the output
run_aws_ssm_parameter_command() {
    local name="$1"
    local parameter_name="$2"
    command="aws ssm get-parameter --name '$name' --query Parameter.Value --output text 2>&1 | tee -a '$PARAMETER_STORE_OUTPUT'"
    echo "Running AWS SSM Parameter Store command:"
    echo "$command"
    eval "$command"
    # Capture the output in the specified format
    echo "$parameter_name : $(cat "$PARAMETER_STORE_OUTPUT" | tail -n 1)" >> "$PARAMETER_STORE_OUTPUT"
    echo "---------------------------" >> "$PARAMETER_STORE_OUTPUT"
}

# Run the AWS Secrets Manager commands and capture the output
run_aws_secretsmanager_command "hlfdxp/$environment/rds/envcmm" "/hlfdxp/$environment/rds/envcmm"
run_aws_secretsmanager_command "hlfdxp/$environment/rds/rtdat" "/hlfdxp/$environment/rds/rtdat"
run_aws_secretsmanager_command "hlfdxp/$environment/rds/sys" "/hlfdxp/$environment/rds/sys"
run_aws_secretsmanager_command "hlfdxp/$environment/mq/activemq" "/hlfdxp/$environment/mq/activemq"
run_aws_secretsmanager_command "hlfdxp/$environment/cert/pgp_pub/bts" "/hlfdxp/$environment/cert/pgp_pub/bts"
run_aws_secretsmanager_command "hlfdxp/$environment/cert/pgp_sec/dxp" "/hlfdxp/$environment/cert/pgp_sec/dxp"
run_aws_secretsmanager_command "hlfdxp/$environment/ks/pass_batch" "/hlfdxp/$environment/ks/pass_batch"
run_aws_secretsmanager_command "hlfdxp/$environment/ks/pass_batch/b64" "/hlfdxp/$environment/ks/pass_batch/b64"
run_aws_secretsmanager_command "hlfdxp/$environment/cert/ds_pub/bts" "/hlfdxp/$environment/cert/ds_pub/bts"
run_aws_secretsmanager_command "hlfdxp/$environment/cert/ds_sec/dxp" "/hlfdxp/$environment/cert/ds_sec/dxp"
run_aws_secretsmanager_command "hlfdxp/$environment/ks/wsprocess" "/hlfdxp/$environment/ks/wsprocess"
run_aws_secretsmanager_command "hlfdxp/$environment/ts/wsprocess" "/hlfdxp/$environment/ts/wsprocess"
run_aws_secretsmanager_command "hlfdxp/$environment/cert/tcp_sec/bts" "/hlfdxp/$environment/cert/tcp_sec/bts"
run_aws_secretsmanager_command "hlfdxp/$environment/cred/wsprocess" "/hlfdxp/$environment/cred/wsprocess"
run_aws_secretsmanager_command "hlfdxp/$environment/ts/ssl" "/hlfdxp/$environment/ts/ssl"
run_aws_secretsmanager_command "hlfdxp/$environment/ts/ssl/b64" "/hlfdxp/$environment/ts/ssl/b64"
run_aws_secretsmanager_command "hlfdxp/$environment/ts/ssl" "/hlfdxp/$environment/ts/ssl"
run_aws_secretsmanager_command "hlfdxp/$environment/ts/ssl/b64" "/hlfdxp/$environment/ts/ssl/b64"
run_aws_secretsmanager_command "hlfdxp/$environment/ks/pass_wsprocess" "/hlfdxp/$environment/ks/pass_wsprocess"

# Run the AWS SSM Parameter Store commands and capture the output
run_aws_ssm_parameter_command "/hlfdxp/$environment/auth_app_lb_url" "/hlfdxp/$environment/auth_app_lb_url"
run_aws_ssm_parameter_command "/hlfdxp/$environment/host1_name" "/hlfdxp/$environment/host1_name"
run_aws_ssm_parameter_command "/hlfdxp/$environment/host2_name" "/hlfdxp/$environment/host2_name"
run_aws_ssm_parameter_command "/hlfdxp/$environment/dxpfe_host_port" "/hlfdxp/$environment/dxpfe_host_port"
run_aws_ssm_parameter_command "/hlfdxp/$environment/btshost1_ip" "/hlfdxp/$environment/btshost1_ip"
run_aws_ssm_parameter_command "/hlfdxp/$environment/btshost2_ip" "/hlfdxp/$environment/btshost2_ip"
run_aws_ssm_parameter_command "/hlfdxp/$environment/btshost1_port" "/hlfdxp/$environment/btshost1_port"
run_aws_ssm_parameter_command "/hlfdxp/$environment/btshost2_port" "/hlfdxp/$environment/btshost2_port"
run_aws_ssm_parameter_command "/hlfdxp/$environment/bp_active_instance" "/hlfdxp/$environment/bp_active_instance"
run_aws_ssm_parameter_command "/hlfdxp/$environment/bp_app1_url" "/hlfdxp/$environment/bp_app1_url"
run_aws_ssm_parameter_command "/hlfdxp/$environment/bp_app2_url" "/hlfdxp/$environment/bp_app2_url"
run_aws_ssm_parameter_command "/hlfdxp/$environment/ldap_authmode" "/hlfdxp/$environment/ldap_authmode"
run_aws_ssm_parameter_command "/hlfdxp/$environment/ldap_url" "/hlfdxp/$environment/ldap_url"
run_aws_ssm_parameter_command "/hlfdxp/$environment/ldap_domain" "/hlfdxp/$environment/ldap_domain"
run_aws_ssm_parameter_command "/hlfdxp/$environment/ldap_domainname_pattern" "/hlfdxp/$environment/ldap_domainname_pattern"
run_aws_ssm_parameter_command "/hlfdxp/$environment/ldap_no_ssl" "/hlfdxp/$environment/ldap_no_ssl"
run_aws_ssm_parameter_command "/hlfdxp/$environment/ldap_sec_protocol" "/hlfdxp/$environment/ldap_sec_protocol"
run_aws_ssm_parameter_command "/hlfdxp/$environment/rt_ws_svc_lb_url" "/hlfdxp/$environment/rt_ws_svc_lb_url"
run_aws_ssm_parameter_command "/hlfdxp/$environment/wsprocess_host_port" "/hlfdxp/$environment/wsprocess_host_port"
run_aws_ssm_parameter_command "/hlfdxp/$environment/wsprocess/conn_profile" "/hlfdxp/$environment/wsprocess/conn_profile"
run_aws_ssm_parameter_command "/hlfdxp/$environment/wsprocess/manager_channel" "/hlfdxp/$environment/wsprocess/manager_channel"
run_aws_ssm_parameter_command "/hlfdxp/$environment/wsprocess/queue_name" "/hlfdxp/$environment/wsprocess/queue_name"
run_aws_ssm_parameter_command "/hlfdxp/$environment/whitelist/wsprocess" "/hlfdxp/$environment/whitelist/wsprocess"
run_aws_ssm_parameter_command "/hlfdxp/$environment/wsprocess1_resp_queue" "/hlfdxp/$environment/wsprocess1_resp_queue"
run_aws_ssm_parameter_command "/hlfdxp/$environment/wsprocess2_resp_queue" "/hlfdxp/$environment/wsprocess2_resp_queue"
run_aws_ssm_parameter_command "/hlfdxp/$environment/bts_api_host" "/hlfdxp/$environment/bts_api_host"
run_aws_ssm_parameter_command "/hlfdxp/$environment/bts_api_trxn_sts" "/hlfdxp/$environment/bts_api_trxn_sts"
# Add more Parameter Store commands as needed