#!/bin/bash

export param_path=$PORTFOLIO/$ENVIRONMENT/

downloadlTs(){
#download batch admin ui trust store certficate and import to java cacerts
file_path_loc=$(aws secretsmanager  get-secret-value --secret-id ${param_path}"ks/pass_batch" | jq --raw-output '.SecretString' | jq -r .keyFilePath)
ts_alias=$(aws secretsmanager  get-secret-value --secret-id ${param_path}"ks/pass_batch" | jq --raw-output '.SecretString' | jq -r .keyAlias)

echo "downloaing the batch admin ui Trust store certficate: "$file_path_loc" and rt alias name:"$ts_alias
aws secretsmanager get-secret-value --secret-id ${param_path}"ks/pass_batch/b64" --query SecretBinary --output text | base64 --decode >$file_path_loc

echo "deleting the existing batch admin ui alias name:"$ts_alias" from java cacerts"
#delete certficate
keytool -delete -cacerts -alias $ts_alias -storepass changeit

echo "importing the new  batch admin ui alias name:"$ts_alias" to java cacerts"

#add certificate
keytool -importcert -alias $ts_alias -file $file_path_loc -trustcacerts -cacerts -storepass changeit -noprompt

}

downloadlTs