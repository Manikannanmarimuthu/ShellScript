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

   keytool -trustcacerts -cacerts -storepass changeit -noprompt

   keytool -importkeystore -srckeystore HLFVITKS.jks -destkeystore client.pkcs   -srcstoretype JKS -deststoretype PKCS12

   openssl pkcs12 -in client.pkcs -out client.pem

   keytool -export -alias your_alias -file your_certificate.cer -keystore your_keystore.jks

   aws secretsmanager create-secret --name "hlfdxp/vit/ts/ssl/b64" --description "Private key file" --secret-binary fileb://./client.pem

   sed  's/server.ssl.enabled: true/server.ssl.enabled: false/g' /hlfapp/DXPApp/auth/conf/application.properties

   Select * from commonparamconfig where PARAM_SUB_KEY= 'ACCESS_URL';

   Select * from commonparamconfig where PARAM_SUB_KEY= 'BACKEND_API_URL1';


   @~Clement Lim  @~Xue Ting @~Sam   - Can we restart DXP for some configuration changes? It will take 5 - 10 min only.

   @~Clement Lim  thanks. 
@~Arthur Tham  - can help to restart both DXP online process only after the script execution.
   
}

download_ks