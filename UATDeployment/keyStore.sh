#!/bin/bash

export param_path=$PORTFOLIO/$ENVIRONMENT/

download_ks(){
#download rt trust store certficate and import to java cacerts
file_path_loc=$(aws secretsmanager  get-secret-value --secret-id ${param_path}"ks/pass_batch" | jq --raw-output '.SecretString' | jq -r .keyFilePath)
ts_alias=$(aws secretsmanager  get-secret-value --secret-id ${param_path}"ks/pass_batch" | jq --raw-output '.SecretString' | jq -r .keyAlias)

echo "downloaing the DXP Trust store certficate: "$file_path_loc" and rt alias name:"$ts_alias

aws secretsmanager get-secret-value --secret-id ${param_path}"ks/pass_batch" --query SecretBinary --output text | base64 --decode >$file_path_loc

echo "deleting the existing DXP alias name:"$ts_alias" from java cacerts"
#delete certficate
keytool -delete -cacerts -alias $ts_alias -storepass changeit

echo "importing the new DXP alias name:"$ts_alias" to java cacerts"
#add certificate
keytool -importcert -alias $ts_alias -file $file_path_loc -trustcacerts -cacerts -storepass changeit -noprompt

}


download_ks


keytool -export -alias your_alias -file your_certificate.cer -keystore your_keystore.jks

openssl x509 -inform der -in your_certificate.cer -out your_certificate.pem