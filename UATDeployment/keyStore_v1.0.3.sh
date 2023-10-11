#!/bin/bash

export param_path=$PORTFOLIO/$ENVIRONMENT/

download_ks(){

   file_path_loc=$(aws secretsmanager  get-secret-value --secret-id ${param_path}"ks/pass_batch" | jq --raw-output '.SecretString' | jq -r .keyFilePath)

   echo "downloaing the  Key store: "$file_path_loc
   aws secretsmanager get-secret-value --secret-id ${param_path}"ks/pass_batch/b64" | jq --raw-output '.SecretString' | base64 --decode >$file_path_loc

   echo "Import Key"
   keytool -importkeystore -srckeystore HLFVITKS.jks -destkeystore localhost.pkcs   -srcstoretype JKS -deststoretype PKCS12

   echo "OpenSSl"
   openssl pkcs12 -in localhost.pkcs -out localhost.cer
 
   echo "Delete"
   sudo keytool -delete -cacerts -alias localhost -storepass changeit

   echo "Import Cert"
   sudo keytool -importcert -alias localhost -file /hlfapp/SSL/localhost.cer -trustcacerts -cacerts -storepass changeit -noprompt

}

download_ks