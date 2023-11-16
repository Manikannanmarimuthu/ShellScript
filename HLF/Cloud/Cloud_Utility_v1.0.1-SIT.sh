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
run_aws_secretsmanager_command "hlfdxp/sit/rds/envcmm" "/hlfdxp/sit/rds/envcmm"
run_aws_secretsmanager_command "hlfdxp/sit/rds/rtdat" "/hlfdxp/sit/rds/rtdat"
run_aws_secretsmanager_command "hlfdxp/sit/rds/sys" "/hlfdxp/sit/rds/sys"
run_aws_secretsmanager_command "hlfdxp/sit/mq/activemq" "/hlfdxp/sit/mq/activemq"
run_aws_secretsmanager_command "hlfdxp/sit/cert/pgp_pub/bts" "/hlfdxp/sit/cert/pgp_pub/bts"
run_aws_secretsmanager_command "hlfdxp/sit/cert/pgp_sec/dxp" "/hlfdxp/sit/cert/pgp_sec/dxp"
run_aws_secretsmanager_command "hlfdxp/sit/ks/pass_batch" "/hlfdxp/sit/ks/pass_batch"
run_aws_secretsmanager_command "hlfdxp/sit/ks/pass_batch/b64" "/hlfdxp/sit/ks/pass_batch/b64"
run_aws_secretsmanager_command "hlfdxp/sit/cert/ds_pub/bts" "/hlfdxp/sit/cert/ds_pub/bts"
run_aws_secretsmanager_command "hlfdxp/sit/cert/ds_sec/dxp" "/hlfdxp/sit/cert/ds_sec/dxp"
run_aws_secretsmanager_command "hlfdxp/sit/ks/wsprocess" "/hlfdxp/sit/ks/wsprocess"
run_aws_secretsmanager_command "hlfdxp/sit/ts/wsprocess" "/hlfdxp/sit/ts/wsprocess"
run_aws_secretsmanager_command "hlfdxp/sit/cert/tcp_sec/bts" "/hlfdxp/sit/cert/tcp_sec/bts"
run_aws_secretsmanager_command "hlfdxp/sit/cred/wsprocess" "/hlfdxp/sit/cred/wsprocess"
run_aws_secretsmanager_command "hlfdxp/sit/ts/ssl" "/hlfdxp/sit/ts/ssl"
run_aws_secretsmanager_command "hlfdxp/sit/ts/ssl/b64" "/hlfdxp/sit/ts/ssl/b64"
run_aws_secretsmanager_command "hlfdxp/sit/ks/pass_wsprocess" "/hlfdxp/sit/ks/pass_wsprocess"
# Add more Secrets Manager commands as needed

# Run the AWS SSM Parameter Store commands and capture the output
run_aws_ssm_parameter_command "/hlfdxp/sit/auth_app_lb_url" "/hlfdxp/sit/auth_app_lb_url"
run_aws_ssm_parameter_command "/hlfdxp/sit/host1_name" "/hlfdxp/sit/host1_name"
run_aws_ssm_parameter_command "/hlfdxp/sit/host2_name" "/hlfdxp/sit/host2_name"
run_aws_ssm_parameter_command "/hlfdxp/sit/dxpfe_host_port" "/hlfdxp/sit/dxpfe_host_port"
run_aws_ssm_parameter_command "/hlfdxp/sit/btshost1_ip" "/hlfdxp/sit/btshost1_ip"
run_aws_ssm_parameter_command "/hlfdxp/sit/btshost2_ip" "/hlfdxp/sit/btshost2_ip"
run_aws_ssm_parameter_command "/hlfdxp/sit/btshost1_port" "/hlfdxp/sit/btshost1_port"
run_aws_ssm_parameter_command "/hlfdxp/sit/btshost2_port" "/hlfdxp/sit/btshost2_port"
run_aws_ssm_parameter_command "/hlfdxp/sit/bp_active_instance" "/hlfdxp/sit/bp_active_instance"
run_aws_ssm_parameter_command "/hlfdxp/sit/bp_app1_url" "/hlfdxp/sit/bp_app1_url"
run_aws_ssm_parameter_command "/hlfdxp/sit/bp_app2_url" "/hlfdxp/sit/bp_app2_url"
run_aws_ssm_parameter_command "/hlfdxp/sit/ldap_authmode" "/hlfdxp/sit/ldap_authmode"
run_aws_ssm_parameter_command "/hlfdxp/sit/ldap_url" "/hlfdxp/sit/ldap_url"
run_aws_ssm_parameter_command "/hlfdxp/sit/ldap_domain" "/hlfdxp/sit/ldap_domain"
run_aws_ssm_parameter_command "/hlfdxp/sit/ldap_domainname_pattern" "/hlfdxp/sit/ldap_domainname_pattern"
run_aws_ssm_parameter_command "/hlfdxp/sit/ldap_no_ssl" "/hlfdxp/sit/ldap_no_ssl"
run_aws_ssm_parameter_command "/hlfdxp/sit/ldap_sec_protocol" "/hlfdxp/sit/ldap_sec_protocol"
run_aws_ssm_parameter_command "/hlfdxp/sit/rt_ws_svc_lb_url" "/hlfdxp/sit/rt_ws_svc_lb_url"
run_aws_ssm_parameter_command "/hlfdxp/sit/wsprocess_host_port" "/hlfdxp/sit/wsprocess_host_port"
run_aws_ssm_parameter_command "/hlfdxp/sit/wsprocess/conn_profile" "/hlfdxp/sit/wsprocess/conn_profile"
run_aws_ssm_parameter_command "/hlfdxp/sit/wsprocess/manager_channel" "/hlfdxp/sit/wsprocess/manager_channel"
run_aws_ssm_parameter_command "/hlfdxp/sit/wsprocess/queue_name" "/hlfdxp/sit/wsprocess/queue_name"
run_aws_ssm_parameter_command "/hlfdxp/sit/whitelist/wsprocess" "/hlfdxp/sit/whitelist/wsprocess"
run_aws_ssm_parameter_command "/hlfdxp/sit/wsprocess1_resp_queue" "/hlfdxp/sit/wsprocess1_resp_queue"
run_aws_ssm_parameter_command "/hlfdxp/sit/wsprocess2_resp_queue" "/hlfdxp/sit/wsprocess2_resp_queue"
run_aws_ssm_parameter_command "/hlfdxp/sit/bts_api_host" "/hlfdxp/sit/bts_api_host"
run_aws_ssm_parameter_command "/hlfdxp/sit/bts_api_trxn_sts" "/hlfdxp/sit/bts_api_trxn_sts"
# Add more Parameter Store commands as needed

run_aws_secretsmanager_command
run_aws_ssm_parameter_command 