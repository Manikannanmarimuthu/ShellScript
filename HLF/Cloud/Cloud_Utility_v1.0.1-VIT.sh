

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
run_aws_secretsmanager_command "hlfdxp/vit/rds/envcmm" "/hlfdxp/vit/rds/envcmm"
run_aws_secretsmanager_command "hlfdxp/vit/rds/rtdat" "/hlfdxp/vit/rds/rtdat"
run_aws_secretsmanager_command "hlfdxp/vit/rds/sys" "/hlfdxp/vit/rds/sys"
run_aws_secretsmanager_command "hlfdxp/vit/mq/activemq" "/hlfdxp/vit/mq/activemq"
run_aws_secretsmanager_command "hlfdxp/vit/cert/pgp_pub/bts" "/hlfdxp/vit/cert/pgp_pub/bts"
run_aws_secretsmanager_command "hlfdxp/vit/cert/pgp_sec/dxp" "/hlfdxp/vit/cert/pgp_sec/dxp"
run_aws_secretsmanager_command "hlfdxp/vit/ks/pass_batch" "/hlfdxp/vit/ks/pass_batch"
run_aws_secretsmanager_command "hlfdxp/vit/ks/pass_batch/b64" "/hlfdxp/vit/ks/pass_batch/b64"
run_aws_secretsmanager_command "hlfdxp/vit/cert/ds_pub/bts" "/hlfdxp/vit/cert/ds_pub/bts"
run_aws_secretsmanager_command "hlfdxp/vit/cert/ds_sec/dxp" "/hlfdxp/vit/cert/ds_sec/dxp"
run_aws_secretsmanager_command "hlfdxp/vit/ks/wsprocess" "/hlfdxp/vit/ks/wsprocess"
run_aws_secretsmanager_command "hlfdxp/vit/ts/wsprocess" "/hlfdxp/vit/ts/wsprocess"
run_aws_secretsmanager_command "hlfdxp/vit/cert/tcp_sec/bts" "/hlfdxp/vit/cert/tcp_sec/bts"
run_aws_secretsmanager_command "hlfdxp/vit/cred/wsprocess" "/hlfdxp/vit/cred/wsprocess"
run_aws_secretsmanager_command "hlfdxp/vit/ts/ssl" "/hlfdxp/vit/ts/ssl"
run_aws_secretsmanager_command "hlfdxp/vit/ts/ssl/b64" "/hlfdxp/vit/ts/ssl/b64"
run_aws_secretsmanager_command "hlfdxp/vit/ks/pass_wsprocess" "/hlfdxp/vit/ks/pass_wsprocess"
# Add more Secrets Manager commands as needed

# Run the AWS SSM Parameter Store commands and capture the output
run_aws_ssm_parameter_command "/hlfdxp/vit/auth_app_lb_url" "/hlfdxp/vit/auth_app_lb_url"
run_aws_ssm_parameter_command "/hlfdxp/vit/host1_name" "/hlfdxp/vit/host1_name"
run_aws_ssm_parameter_command "/hlfdxp/vit/host2_name" "/hlfdxp/vit/host2_name"
run_aws_ssm_parameter_command "/hlfdxp/vit/dxpfe_host_port" "/hlfdxp/vit/dxpfe_host_port"
run_aws_ssm_parameter_command "/hlfdxp/vit/btshost1_ip" "/hlfdxp/vit/btshost1_ip"
run_aws_ssm_parameter_command "/hlfdxp/vit/btshost2_ip" "/hlfdxp/vit/btshost2_ip"
run_aws_ssm_parameter_command "/hlfdxp/vit/btshost1_port" "/hlfdxp/vit/btshost1_port"
run_aws_ssm_parameter_command "/hlfdxp/vit/btshost2_port" "/hlfdxp/vit/btshost2_port"
run_aws_ssm_parameter_command "/hlfdxp/vit/bp_active_instance" "/hlfdxp/vit/bp_active_instance"
run_aws_ssm_parameter_command "/hlfdxp/vit/bp_app1_url" "/hlfdxp/vit/bp_app1_url"
run_aws_ssm_parameter_command "/hlfdxp/vit/bp_app2_url" "/hlfdxp/vit/bp_app2_url"
run_aws_ssm_parameter_command "/hlfdxp/vit/ldap_authmode" "/hlfdxp/vit/ldap_authmode"
run_aws_ssm_parameter_command "/hlfdxp/vit/ldap_url" "/hlfdxp/vit/ldap_url"
run_aws_ssm_parameter_command "/hlfdxp/vit/ldap_domain" "/hlfdxp/vit/ldap_domain"
run_aws_ssm_parameter_command "/hlfdxp/vit/ldap_domainname_pattern" "/hlfdxp/vit/ldap_domainname_pattern"
run_aws_ssm_parameter_command "/hlfdxp/vit/ldap_no_ssl" "/hlfdxp/vit/ldap_no_ssl"
run_aws_ssm_parameter_command "/hlfdxp/vit/ldap_sec_protocol" "/hlfdxp/vit/ldap_sec_protocol"
run_aws_ssm_parameter_command "/hlfdxp/vit/rt_ws_svc_lb_url" "/hlfdxp/vit/rt_ws_svc_lb_url"
run_aws_ssm_parameter_command "/hlfdxp/vit/wsprocess_host_port" "/hlfdxp/vit/wsprocess_host_port"
run_aws_ssm_parameter_command "/hlfdxp/vit/wsprocess/conn_profile" "/hlfdxp/vit/wsprocess/conn_profile"
run_aws_ssm_parameter_command "/hlfdxp/vit/wsprocess/manager_channel" "/hlfdxp/vit/wsprocess/manager_channel"
run_aws_ssm_parameter_command "/hlfdxp/vit/wsprocess/queue_name" "/hlfdxp/vit/wsprocess/queue_name"
run_aws_ssm_parameter_command "/hlfdxp/vit/whitelist/wsprocess" "/hlfdxp/vit/whitelist/wsprocess"
run_aws_ssm_parameter_command "/hlfdxp/vit/wsprocess1_resp_queue" "/hlfdxp/vit/wsprocess1_resp_queue"
run_aws_ssm_parameter_command "/hlfdxp/vit/wsprocess2_resp_queue" "/hlfdxp/vit/wsprocess2_resp_queue"
run_aws_ssm_parameter_command "/hlfdxp/vit/bts_api_host" "/hlfdxp/vit/bts_api_host"
run_aws_ssm_parameter_command "/hlfdxp/vit/bts_api_trxn_sts" "/hlfdxp/vit/bts_api_trxn_sts"
# Add more Parameter Store commands as needed

run_aws_secretsmanager_command
run_aws_ssm_parameter_command 