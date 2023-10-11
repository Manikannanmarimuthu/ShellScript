#!/bin/bash

export param_path=$PORTFOLIO/$ENVIRONMENT/

download_ks(){
#download rt trust store certficate and import to java cacerts
file_path_loc=$(aws secretsmanager  get-secret-value --secret-id ${param_path}"ks/pass_batch" | jq --raw-output '.SecretString' | jq -r .keyFilePath)
ts_alias=$(aws secretsmanager  get-secret-value --secret-id ${param_path}"ks/pass_batch" | jq --raw-output '.SecretString' | jq -r .keyAlias)

echo "downloaing the DXP Trust store certficate: "$file_path_loc" and DXP alias name:"$ts_alias

aws secretsmanager get-secret-value --secret-id ${param_path}"ks/pass_batch" --query SecretBinary --output text | base64 --decode >$file_path_loc

echo "deleting the existing DXP alias name:"$ts_alias" from java cacerts"
#delete certficate
keytool -delete -cacerts -alias $ts_alias -storepass changeit

echo "importing the new DXP alias name:"$ts_alias" to java cacerts"
#add certificate
keytool -importcert -alias $ts_alias -file $file_path_loc -trustcacerts -cacerts -storepass changeit -noprompt

}

function dwlBatchAdmUITs(){
#download batch admin ui trust store certficate and import to java cacerts
file_path_loc=$(aws secretsmanager  get-secret-value --secret-id ${param_path}"ts/bpadmui/ssl" | jq --raw-output '.SecretString' | jq -r .keyFilePath)
ts_alias=$(aws secretsmanager  get-secret-value --secret-id ${param_path}"ts/bpadmui/ssl" | jq --raw-output '.SecretString' | jq -r .keyAlias)

echo "downloaing the batch admin ui Trust store certficate: "$file_path_loc" and rt alias name:"$ts_alias

aws secretsmanager get-secret-value --secret-id ${param_path}"ts/bpadmui/ssl/b64" --query SecretBinary --output text | base64 --decode >$file_path_loc

echo "deleting the existing batch admin ui alias name:"$ts_alias" from java cacerts"
#delete certficate
keytool -delete -cacerts -alias $ts_alias -storepass changeit

echo "importing the new  batch admin ui alias name:"$ts_alias" to java cacerts"
#add certificate
keytool -importcert -alias $ts_alias -file $file_path_loc -trustcacerts -cacerts -storepass changeit -noprompt

}


function dwlBatchAdmUITs(){

#download batch admin ui trust store certficate and import to java cacerts
file_path_loc=$(aws secretsmanager  get-secret-value --secret-id ${param_path}"ts/bpadmui/ssl" | jq --raw-output '.SecretString' | jq -r .keyFilePath)
ts_alias=$(aws secretsmanager  get-secret-value --secret-id ${param_path}"ts/bpadmui/ssl" | jq --raw-output '.SecretString' | jq -r .keyAlias)

echo "downloaing the batch admin ui Trust store certficate: "$file_path_loc" and rt alias name:"$ts_alias

aws secretsmanager get-secret-value --secret-id ${param_path}"ts/bpadmui/ssl/b64" --query SecretBinary --output text | base64 --decode >$file_path_loc

echo "deleting the existing batch admin ui alias name:"$ts_alias" from java cacerts"
#delete certficate
keytool -delete -cacerts -alias $ts_alias -storepass changeit

echo "importing the new  batch admin ui alias name:"$ts_alias" to java cacerts"
#add certificate
keytool -importcert -alias $ts_alias -file $file_path_loc -trustcacerts -cacerts -storepass changeit -noprompt

}

sudo keytool -export -alias localhost -file localhost.cer -keystore HLFVITKS.jks

sudo keytool -delete -cacerts -alias localhost -storepass changeit

sudo keytool -importcert -alias localhost -file /hlfapp/SSL/localhost.cer -trustcacerts -cacerts -storepass changeit -noprompt

ls -l /usr/lib/jvm/java-11-openjdk-11.0.17.0.8-2.el9.x86_64/lib/security/cacerts

sudo keytool -importcert -alias localhost -file /hlfapp/SSL/localhost.cer -trustcacerts -cacerts -storepass changeit -noprompt

aws secretsmanager create-secret --name "sgps/bp/{env}/sftp/sshkey" --description "Private key file" --secret-binary fileb://./CIMB-BP-SFTP.pem


# https://chat.openai.com/c/d8407726-8e6d-44aa-9095-90059d10628a


#hlfdxp/vit/ts/ssl -Refer Value in Secret Manager


export param_path=$PORTFOLIO/$ENVIRONMENT/

   file_path_loc=$(aws secretsmanager  get-secret-value --secret-id ${param_path}"ks/pass_batch" | jq --raw-output '.SecretString' | jq -r .keyFilePath)

   echo "downloaing the  Key store: "$file_path_loc
   aws secretsmanager get-secret-value --secret-id ${param_path}"ks/pass_batch/b64" | jq --raw-output '.SecretString' | base64 --decode >$file_path_loc
   keytool -importkeystore -srckeystore HLFVITKS.jks -destkeystore localhost.pkcs   -srcstoretype JKS -deststoretype PKCS12
   openssl pkcs12 -in localhost.pkcs -out localhost.cer
   sudo keytool -delete -cacerts -alias localhost -storepass changeit
   sudo keytool -importcert -alias localhost -file /hlfapp/SSL/localhost.cer -trustcacerts -cacerts -storepass changeit -noprompt

   #Not required as of now
   #aws secretsmanager create-secret --name "hlfdxp/vit/ts/ssl/b64" --description "Private key file" --secret-binary fileb://./client.pem
download_ks


   file_path_loc=$(aws secretsmanager  get-secret-value --secret-id "/hlfdxp/vit/ks/pass_batch" | jq --raw-output '.SecretString' | jq -r .keyFilePath)

   echo "downloaing the  Key store: "$file_path_loc
   aws secretsmanager get-secret-value --secret-id ${param_path}"ks/pass_batch/b64" | jq --raw-output '.SecretString' | base64 --decode >$file_path_loc
   keytool -importkeystore -srckeystore HLFVITKS.jks -destkeystore localhost.pkcs   -srcstoretype JKS -deststoretype PKCS12
   openssl pkcs12 -in localhost.pkcs -out localhost.cer
   sudo keytool -delete -cacerts -alias localhost -storepass changeit
   sudo keytool -importcert -alias localhost -file /hlfapp/SSL/localhost.cer -trustcacerts -cacerts -storepass changeit -noprompt
