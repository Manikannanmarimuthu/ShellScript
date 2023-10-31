#!/bin/bash
export param_path=$PORTFOLIO/$ENVIRONMENT/

print_info() {
   echo "*********************************"
   echo -e "\e[1;34m[INFO]\e[0m \e[1m$1\e[0m \e[1;32m\e[0m"
}

 environment=$ENVIRONMENT

download_ks(){

   print_info "${param_path}"

   file_path_loc=$(aws secretsmanager  get-secret-value --secret-id ${param_path}"ts/ssl" | jq --raw-output '.SecretString' | jq -r .keyFilePath)
   ts_alias=$(aws secretsmanager  get-secret-value --secret-id ${param_path}"ts/ssl" | jq --raw-output '.SecretString' | jq -r .keyAlias)
	  
    print_info "downloaing the DXP Trust store certficate: "$file_path_loc" and alias name:"$ts_alias
    aws secretsmanager get-secret-value --secret-id ${param_path}"ts/ssl/b64" | jq --raw-output '.SecretString' >$file_path_loc


    # Check the environment condition
    if [ "$environment" = "vit" ]; then
      print_info "deleting the existing DXP alias name:"$ts_alias" from java cacerts"
      #delete certficate
      keytool -delete -cacerts -alias $ts_alias -storepass changeit

      print_info "importing the new  DXP alias name:"$ts_alias" to java cacerts"
      #add certificate
       keytool -importcert -alias $ts_alias -file $file_path_loc -trustcacerts -cacerts -storepass changeit -noprompt
     else
      print_info "deleting the existing DXP alias name:"$ts_alias" from java cacerts"
      #delete certficate
      sudo keytool -delete -cacerts -alias $ts_alias -storepass changeit

      print_info "importing the new  DXP alias name:"$ts_alias" to java cacerts"
      #add certificate
      sudo keytool -importcert -alias $ts_alias -file $file_path_loc -trustcacerts -cacerts -storepass changeit -noprompt
     fi
}

echo "importing ldap cert into java cacerts"
download_ks
