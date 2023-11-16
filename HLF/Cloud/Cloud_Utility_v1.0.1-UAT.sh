#!/bin/bash

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
run_aws_secretsmanager_command "hlfdxp/uat/rds/envcmm" "/hlfdxp/uat/rds/envcmm"
run_aws_secretsmanager_command "hlfdxp/uat/rds/rtdat" "/hlfdxp/uat/rds/rtdat"
run_aws_secretsmanager_command "hlfdxp/uat/rds/sys" "/hlfdxp/uat/rds/sys"
run_aws_secretsmanager_command "hlfdxp/uat/mq/activemq" "/hlfdxp/uat/mq/activemq"
run_aws_secretsmanager_command "hlfdxp/uat/cert/pgp_pub/bts" "/hlfdxp/uat/cert/pgp_pub/bts"
run_aws_secretsmanager_command "hlfdxp/uat/cert/pgp_sec/dxp" "/hlfdxp/uat/cert/pgp_sec/dxp"
run_aws_secretsmanager_command "hlfdxp/uat/ks/pass_batch" "/hlfdxp/uat/ks/pass_batch"
run_aws_secretsmanager_command "hlfdxp/uat/ks/pass_batch/b64" "/hlfdxp/uat/ks/pass_batch/b64"
run_aws_secretsmanager_command "hlfdxp/uat/cert/ds_pub/bts" "/hlfdxp/uat/cert/ds_pub/bts"
run_aws_secretsmanager_command "hlfdxp/uat/cert/ds_sec/dxp" "/hlfdxp/uat/cert/ds_sec/dxp"
run_aws_secretsmanager_command "hlfdxp/uat/ks/wsprocess" "/hlfdxp/uat/ks/wsprocess"
run_aws_secretsmanager_command "hlfdxp/uat/ts/wsprocess" "/hlfdxp/uat/ts/wsprocess"
run_aws_secretsmanager_command "hlfdxp/uat/cert/tcp_sec/bts" "/hlfdxp/uat/cert/tcp_sec/bts"
run_aws_secretsmanager_command "hlfdxp/uat/cred/wsprocess" "/hlfdxp/uat/cred/wsprocess"
run_aws_secretsmanager_command "hlfdxp/uat/ts/ssl" "/hlfdxp/uat/ts/ssl"
run_aws_secretsmanager_command "hlfdxp/uat/ts/ssl/b64" "/hlfdxp/uat/ts/ssl/b64"
run_aws_secretsmanager_command "hlfdxp/uat/ks/pass_wsprocess" "/hlfdxp/uat/ks/pass_wsprocess"
# Add more Secrets Manager commands as needed

# Run the AWS SSM Parameter Store commands and capture the output
run_aws_ssm_parameter_command "/hlfdxp/uat/auth_app_lb_url" "/hlfdxp/uat/auth_app_lb_url"
run_aws_ssm_parameter_command "/hlfdxp/uat/host1_name" "/hlfdxp/uat/host1_name"
run_aws_ssm_parameter_command "/hlfdxp/uat/host2_name" "/hlfdxp/uat/host2_name"
run_aws_ssm_parameter_command "/hlfdxp/uat/dxpfe_host_port" "/hlfdxp/uat/dxpfe_host_port"
run_aws_ssm_parameter_command "/hlfdxp/uat/btshost1_ip" "/hlfdxp/uat/btshost1_ip"
run_aws_ssm_parameter_command "/hlfdxp/uat/btshost2_ip" "/hlfdxp/uat/btshost2_ip"
run_aws_ssm_parameter_command "/hlfdxp/uat/btshost1_port" "/hlfdxp/uat/btshost1_port"
run_aws_ssm_parameter_command "/hlfdxp/uat/btshost2_port" "/hlfdxp/uat/btshost2_port"
run_aws_ssm_parameter_command "/hlfdxp/uat/bp_active_instance" "/hlfdxp/uat/bp_active_instance"
run_aws_ssm_parameter_command "/hlfdxp/uat/bp_app1_url" "/hlfdxp/uat/bp_app1_url"
run_aws_ssm_parameter_command "/hlfdxp/uat/bp_app2_url" "/hlfdxp/uat/bp_app2_url"
run_aws_ssm_parameter_command "/hlfdxp/uat/ldap_authmode" "/hlfdxp/uat/ldap_authmode"
run_aws_ssm_parameter_command "/hlfdxp/uat/ldap_url" "/hlfdxp/uat/ldap_url"
run_aws_ssm_parameter_command "/hlfdxp/uat/ldap_domain" "/hlfdxp/uat/ldap_domain"
run_aws_ssm_parameter_command "/hlfdxp/uat/ldap_domainname_pattern" "/hlfdxp/uat/ldap_domainname_pattern"
run_aws_ssm_parameter_command "/hlfdxp/uat/ldap_no_ssl" "/hlfdxp/uat/ldap_no_ssl"
run_aws_ssm_parameter_command "/hlfdxp/uat/ldap_sec_protocol" "/hlfdxp/uat/ldap_sec_protocol"
run_aws_ssm_parameter_command "/hlfdxp/uat/rt_ws_svc_lb_url" "/hlfdxp/uat/rt_ws_svc_lb_url"
run_aws_ssm_parameter_command "/hlfdxp/uat/wsprocess_host_port" "/hlfdxp/uat/wsprocess_host_port"
run_aws_ssm_parameter_command "/hlfdxp/uat/wsprocess/conn_profile" "/hlfdxp/uat/wsprocess/conn_profile"
run_aws_ssm_parameter_command "/hlfdxp/uat/wsprocess/manager_channel" "/hlfdxp/uat/wsprocess/manager_channel"
run_aws_ssm_parameter_command "/hlfdxp/uat/wsprocess/queue_name" "/hlfdxp/uat/wsprocess/queue_name"
run_aws_ssm_parameter_command "/hlfdxp/uat/whitelist/wsprocess" "/hlfdxp/uat/whitelist/wsprocess"
run_aws_ssm_parameter_command "/hlfdxp/uat/wsprocess1_resp_queue" "/hlfdxp/uat/wsprocess1_resp_queue"
run_aws_ssm_parameter_command "/hlfdxp/uat/wsprocess2_resp_queue" "/hlfdxp/uat/wsprocess2_resp_queue"
run_aws_ssm_parameter_command "/hlfdxp/uat/bts_api_host" "/hlfdxp/uat/bts_api_host"
run_aws_ssm_parameter_command "/hlfdxp/uat/bts_api_trxn_sts" "/hlfdxp/uat/bts_api_trxn_sts"
# Add more Parameter Store commands as needed

run_aws_secretsmanager_command
run_aws_ssm_parameter_command 