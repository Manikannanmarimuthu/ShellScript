#!/bin/bash

export param_path=$PORTFOLIO/$ENVIRONMENT/

download_ks(){

file="/hlfapp/SSL/localhost.cer"

if [ -e "$file" ]; then
    rm -rf "$file"
    echo "File '$file' deleted."
else
    echo "File '$file' does not exist."
fi

   file_path_loc=$(aws secretsmanager  get-secret-value --secret-id ${param_path}"ts/ssl" | jq --raw-output '.SecretString' | jq -r .keyFilePath)
   ts_alias=$(aws secretsmanager  get-secret-value --secret-id ${param_path}"ts/ssl" | jq --raw-output '.SecretString' | jq -r .keyAlias)

    echo "downloaing the batch admin ui Trust store certficate: "$file_path_loc" and rt alias name:"$ts_alias
    aws secretsmanager get-secret-value --secret-id ${param_path}"ts/ssl/b64" | jq --raw-output '.SecretString' >$file_path_loc
   
    echo "deleting the existing batch admin ui alias name:"$ts_alias" from java cacerts"
    #delete certficate
    sudo /usr/bin/keytool -delete -cacerts -alias $ts_alias -storepass changeit

    echo "importing the new  batch admin ui alias name:"$ts_alias" to java cacerts"
    #add certificate
    sudo /usr/bin/keytool -importcert -alias $ts_alias -file $file_path_loc -trustcacerts -cacerts -storepass changeit -noprompt

}
   
download_ks