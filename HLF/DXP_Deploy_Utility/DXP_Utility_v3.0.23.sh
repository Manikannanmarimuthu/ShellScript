#!/bin/bash

#set -x  #debug mode
#set -e  #If any error available will exit abrubtly.
#set -o pipefail #To catch the pipe failiure

###################################
#Author : MVI
#
#Date : 24-NOV-2023
#
#This script is used to Deploy DXP Application
####################################

export param_path=$PORTFOLIO/$ENVIRONMENT/

print_info() {
   echo "*********************************"
   echo -e "\e[1;34m[INFO]\e[0m \e[1m$1\e[0m \e[1;32m\e[0m"
}

print_error() {
   echo "*********************************"
   echo -e "\e[1;31m[ERROR]\e[0m \e[1m$1\e[0m \e[1;32m\e[0m"
}

# action_hostname1 refers all Auth,DataSync,Inquiry, batch, WS Process, online and PartitionService services are  avaialble
action_hostname1=""
# action_hostname2 refers all Auth,DataSync,Inquiry, and online only avaialble
action_hostname2=""

# Set the environment variable to specify the desired environment
environment=$ENVIRONMENT

# Check the environment variable to determine the hostname
if [ "$environment" = "vit" ]; then
  action_hostname1="HLFVITAPP31"
  action_hostname2="HLFVITAPP232"
  mysql_connector_jar="/opt/mysql-connector-java-8.0.30/mysql-connector-j-8.0.33.jar"
elif [ "$environment" = "sit" ]; then
  action_hostname1="dxp-app1-sit"
  mysql_connector_jar="/hlfapp/lib/mysql-connector/mysql-connector-j-commercial-8.0.33/mysql-connector-j-8.0.33.jar"
elif [ "$environment" = "uat" ]; then
  action_hostname1="uat-dxp-online-app-01a"
  action_hostname2="uat-dxp-online-app-01b"
  mysql_connector_jar="/hlfapp/lib/mysql-connector/mysql-connector-j-commercial-8.0.33/mysql-connector-j-8.0.33.jar"
elif [ "$environment" = "prd" ]; then
  action_hostname1="prd-dxp-online-app-01a"
  action_hostname2="prd-dxp-online-app-01b"
  mysql_connector_jar="/hlfapp/lib/mysql-connector/mysql-connector-j-commercial-8.0.33/mysql-connector-j-8.0.33.jar"
else
  echo "Invalid environment: $environment"
  exit 1
fi

current_hostname=$(hostname)

NOW=$(date +%Y%m%d%H%M%S)

create_folder() {
    folder="$1"
    if [ ! -d "$folder" ]; then
        mkdir -p "$folder"
        print_info "Folder $folder created."
    else
        print_info "Folder $folder exists."
    fi
}

# List of folders to create
folders=("/hlfapp/Deploy/backup" "/hlfapp/Deploy/log" "/hlfapp/ssl")

# Create folders using the function
  print_info "Pre requesite folder verification"
for folder in "${folders[@]}"; do
    create_folder "$folder"
done

LOG=/hlfapp/Deploy/log/HLF_DXP-Deployment${NOW}.log

print_info "Env :  $environment"
print_info "Hostname :  $current_hostname"

status_check() {
  if [ $? -eq 0 ]; then
    echo -e "\e[1;32mSUCCESS! TaskDone!\e[0m"
  else
    echo -e "\e[1;31mFAILURE\e[0m"
    echo "Refer Log file for more information, LOG - ${LOG}"
    exit 1
  fi
}

function display_color() {
    local color_code
    case "$1" in
        "red") color_code="\e[31m";;
        "green") color_code="\e[32m";;
        "yellow") color_code="\e[33m";;
        "blue") color_code="\e[34m";;
        "purple") color_code="\e[35m";;
        "cyan") color_code="\e[36m";;
        "white") color_code="\e[37m";;
        *) color_code="\e[0m";;  # Default to reset color
    esac
    echo -e "${color_code}$2\e[0m"  # Set color, then reset color after text
}

check_process_status() {
    local process_name="$1"
    if ps aux | grep -v grep | grep -q "$process_name"; then
        display_color "green" "$process_name is running now."
    else
        display_color "red" "$process_name is not running now."
        echo "*********************************"  
    fi
}

# Define a function to format and display Java processes
format_and_display_jps() {
  # Run the jps command and store the output in a variable
  local jps_output=$(jps)
  # Check if there are any Java processes running
  if [ -n "$jps_output" ]; then
  display_color "yellow" "---Status of running now process in Server $current_hostname---"
    # Print a header for the formatted output
    printf "%-10s %s\n" "PID" "Java Process"
    # Use awk to format and print the output
    display_color "green" "$jps_output" | awk '{ printf "%-10s %s\n", $1, $2 }'
  else
    display_color "red" "No Java processes found."
  fi
}

shutdown_auth(){
print_info "Checking the status of the AUTH process..."
if ps aux | grep -v grep | grep StdAuthAPIApp > /dev/null; then
  display_color "yellow" "It is running now."
  display_color "red" "Proceeding to shutdown the Auth process."
  sh /hlfapp/DXPApp/auth/bin/shutdown_auth.sh  >> "${LOG}" 2>&1;
  sleep 5s
  check_process_status "StdAuthAPIApp"
else
  display_color "red" "AUTH Process is not running now."
  sleep 5s
fi
}

start_auth(){
print_info "Checking the status of the AUTH process..."
if ! ps aux | grep -v grep | grep -q StdAuthAPIApp >> "${LOG}" 2>&1; then
  display_color "yellow" "It is not running now."
  display_color "green" "Proceeding to start the AUTH process."
  cd /hlfapp/DXPApp/auth/bin/ >> "${LOG}" 2>&1; ./start_auth.sh >> "${LOG}" 2>&1;
  sleep 5s
  check_process_status "StdAuthAPIApp"
else
  display_color "red" "AUTH Process is running now. "
fi
}

restart_auth(){
shutdown_auth
start_auth
}

shutdown_datasync(){
print_info "Checking the status of the DATASYNC process..."
if ps aux | grep -v grep | grep StdDSAPIApp > /dev/null; then
   display_color "yellow" "It is running now."
   display_color "red" "Proceeding to shutdown the DATASYNC process."
   sh /hlfapp/DXPApp/datasync/bin/shutdown_ds.sh >> "${LOG}" 2>&1;
  sleep 5s
    check_process_status "StdDSAPIApp"
else
  display_color "red" "DATASYNC Process is not running now."
  sleep 5s
fi
}

start_datasync(){
print_info "Checking the status of the DATASYNC process..."
if ! ps aux | grep -v grep | grep StdDSAPIApp >> "${LOG}" 2>&1; then
  display_color "yellow" "It is not running now."
  display_color "green" "Proceeding to start the DATASYNC process."
  cd /hlfapp/DXPApp/datasync/bin/ >> "${LOG}" 2>&1; ./start_ds.sh >> "${LOG}" 2>&1;
  sleep 5s
  check_process_status "StdDSAPIApp"
else
  display_color "red" "DATASYNC Process is running now."
fi
}

restart_datasync(){
shutdown_datasync
start_datasync
}

start_inquiry(){
print_info "Checking the status of the INQUIRY process..."
if ! ps aux | grep -v grep | grep StdInquiryAPIApp >> "${LOG}" 2>&1; then
  display_color "yellow" "It is not running now."
  display_color "green" "Proceeding to start the INQUIRY process."
  cd /hlfapp/DXPApp/inquiry/bin/ >> "${LOG}" 2>&1; ./start_inquiry.sh >> "${LOG}" 2>&1;
  sleep 5s
  check_process_status "StdInquiryAPIApp"
else
  display_color "red" "INQUIRY Process is running now."
fi
}

shutdown_inquiry(){
  print_info "Checking the status of the INQUIRY process..."
if ps aux | grep -v grep | grep StdInquiryAPIApp > /dev/null; then
  display_color "yellow" "It is running now."
  display_color "red" "Proceeding to shutdown the INQUIRY process."
  sh /hlfapp/DXPApp/inquiry/bin/shutdown_inquiry.sh >> "${LOG}" 2>&1;
  sleep 5s
  check_process_status "StdInquiryAPIApp"
else
   display_color "red" "INQUIRY Process is not running now."
   sleep 5s
fi
}

restart_inquiry(){
  shutdown_inquiry
  start_inquiry
}

start_online(){
print_info "Checking the status of the ONLINE process..."
    if  ps aux | grep -v grep | grep EnvManager > /dev/null ||  ps aux | grep -v grep | grep HTTPSrvrGateway > /dev/null  ||  ps aux | grep -v grep | grep DXPHostGateway > /dev/null; then
        display_color "red" "ONLINE Process is not running now."
    else
        display_color "yellow" "It is not running now."
        display_color "green" "Proceeding to start the ONLINE process."
        cd /hlfapp/DXPApp/online/mdynamics/bin/ >> "${LOG}" 2>&1;
          if [ "$current_hostname" = "$action_hostname1" ]; then
           ./start.sh P1G1_MGR1 >> "${LOG}" 2>&1;
        else 
           ./start.sh P1G1_MGR2 >> "${LOG}" 2>&1;
        fi
        sleep 40s
          check_process_status "EnvManager"
          check_process_status "HTTPSrvrGateway"
          check_process_status "DXPHostGateway"
    fi
}

shutdown_online(){
print_info "Checking the status of the ONLINE (EnvManager,HTTPSrvrGateway, and DXPHostGateway) process..."
if  ps aux | grep -v grep | grep EnvManager > /dev/null ||  ps aux | grep -v grep | grep HTTPSrvrGateway > /dev/null  ||  ps aux | grep -v grep | grep DXPHostGateway > /dev/null; then
  display_color "yellow" "It is running now."
  display_color "red" "Proceeding to shutdown the ONLINE process. "
  sh /hlfapp/DXPApp/online/mdynamics/bin/stop.sh &>>${LOG};
  display_color "yellow" "Shutdown Initiated. Hold on.... It takes time... "
 sleep 25s
  check_process_status "EnvManager"
  check_process_status "HTTPSrvrGateway"
  check_process_status "DXPHostGateway"
else
  display_color "red" "ONLINE Process is not running."
  sleep 5s
fi
}

restart_online(){
  shutdown_online
  sleep 15s
  start_online
}

shutdown_batch(){
print_info "Checking the status of the BATCH process..."
    if ps aux | grep -v grep | grep StdBatchApp > /dev/null; then
      display_color "yellow" "It is running now."
      display_color "red" "Proceeding to shutdown the BATCH process."
      sh /hlfapp/DXPApp/batch/bin/shutdown_bp.sh >> "${LOG}" 2>&1;
      sleep 10s
      check_process_status "StdBatchApp"
else
     display_color "red" "BATCH Process is not running now."
     sleep 5s
fi
}

start_batch(){
print_info "Checking the status of the BATCH process..."
    if ! ps aux | grep -v grep | grep StdBatchApp >> "${LOG}" 2>&1; then
        display_color "yellow" "It is not running now."
        display_color "green" "Proceeding to start the BATCH process."
        cd /hlfapp/DXPApp/batch/bin/ >> "${LOG}" 2>&1; ./start_bp.sh >> "${LOG}" 2>&1;
        sleep 25s
          check_process_status "StdBatchApp"
    else
        display_color "red" "BATCH Process is running now. Kindly check Manually"
    fi
}

restart_batch(){
  shutdown_batch
  start_batch
}

shutdown_partitionservice(){
print_info "Checking the status of the PARTITIONSERVICE process..."
  if ps aux | grep -v grep | grep PartitionService > /dev/null; then
     display_color "yellow" "It is running now."
     display_color "red" "Proceeding to shutdown the PARTITIONSERVICE process."
     sh /hlfapp/DXPApp/partitionservice/bin/shutdown_ps.sh >> "${LOG}" 2>&1;
     sleep 10s
    check_process_status "PartitionService"
  else
    display_color "red" "PARTITIONSERVICE Process is not running now."
    sleep 5s
fi
}

start_partitionservice(){
print_info "Checking the status of the PARTITIONSERVICE process..."
    if ! ps aux | grep -v grep | grep PartitionService >> "${LOG}" 2>&1; then
        display_color "yellow" "It is not running now."
        display_color "green" "Proceeding to start the PARTITIONSERVICE process."
        cd /hlfapp/DXPApp/partitionservice/bin/ >> "${LOG}" 2>&1; ./start_ps.sh >> "${LOG}" 2>&1;
        sleep 25s
          check_process_status "PartitionService"
    else
        display_color "red" "PARTITIONSERVICE Process is running now. Kindly check Manually"
    fi
}

restart_partitionservice(){
  shutdown_partitionservice
  start_partitionservice
}

restart_wsprocess(){
shutdown_wsprocess
start_wsprocess
}

shutdown_wsprocess(){
   print_info "Checking the status of the WSPROCESS service..."
    if ps aux | grep -v grep | grep WebSvcProcess > /dev/null; then
        display_color "yellow" " It is running now."
        display_color "red" "Proceeding to shutdown the WSPROCESS service."
          cd /hlfapp/DXPApp/online/mdynamics/bin/ >> "${LOG}" 2>&1; ./stopWSP.sh >> "${LOG}" 2>&1;
        sleep 10s
        check_process_status "WebSvcProcess"
     else
        display_color "red" "WSPROCESS service is not running now."
        sleep 5s
fi
}

start_wsprocess(){
print_info "Checking the status of the WSPROCESS service..."
    if ! ps aux | grep -v grep | grep WebSvcProcess >> "${LOG}" 2>&1; then
        display_color "yellow" "It is not running now."
        display_color "green" "Proceeding to start the WSPROCESS service."
        cd /hlfapp/DXPApp/online/mdynamics/bin/ >> "${LOG}" 2>&1; ./startWSP.sh P1G1_WSPROCESS1 >> "${LOG}" 2>&1;
        sleep 10s
          check_process_status "WebSvcProcess"
    else
        display_color "red" "WebSvcProcess service is running now. Kindly check Manually"
    fi
}

shutdown_hlfdxp() {
shutdown_auth
shutdown_datasync
shutdown_inquiry
shutdown_online
if [ "$current_hostname" = "$action_hostname1" ]; then
shutdown_wsprocess
shutdown_batch 
shutdown_partitionservice
elif [ "$current_hostname" = "$action_hostname2" ]; then
   print_info "Not required to Shutdown the WSPROCESS,PARTITIONSERVICE and BATCH. Since scripts are running now in $action_hostname2"
else
    echo "Hostname does not match any expected hostnames"
fi  
}

start_hlfdxp() {
start_auth
start_datasync
start_inquiry
start_online
if [ "$current_hostname" = "$action_hostname1" ]; then
   start_wsprocess
   start_batch 
   start_partitionservice
elif [ "$current_hostname" = "$action_hostname2" ]; then
   print_info "Not required to start the WSPROCESS,PARTITIONSERVICE and BATCH. Since scripts are running now in $action_hostname2"
else
    echo "Hostname does not match any expected hostnames"
fi  

}

enable_soft_link() {
    local module_name="$1"
    local lib_loc="$2"
    local mysql_jar="mysql-connector-j-8.0.33.jar"

    print_info "Enabling Soft Link for $module_name"

    local file_path="$lib_loc/$mysql_jar"

    if [ -f "$file_path" ]; then
        display_color "yellow" "$mysql_jar exists: $file_path :: Proceeding to delete $mysql_jar then enable soft link"
        rm -rf "$file_path"
        cd "$lib_loc/" || exit
        ln -s "$mysql_connector_jar"
    else
        display_color "yellow" "$mysql_jar does not exist: $file_path :: Proceeding to enable soft link"
        cd "$lib_loc/" || exit
        ln -s "$mysql_connector_jar"
    fi
}


deploy_hlfdxp(){

# Get user input for the .zip folder name
read -p "Enter the name of the .zip folder: " zip_folder_name

#Construct the full path to the .zip folder
zip_folder_path="/hlfapp/Deploy/$zip_folder_name.zip"

extract_path="/hlfapp/Deploy/$zip_folder_name"

# Check if the environment is not UAT
if [ "$environment" = "vit" ]; then
    vit_directory="/hlfapp/Deploy/"
    vit_filename="app.tar.gz"
    if [ -e "$vit_directory/$vit_filename" ]; then
        print_info "$vit_filename exists in $vit_directory."
        cd /hlfapp/Deploy
        mkdir -p "/hlfapp/Deploy/$zip_folder_name"
        mv  app.tar.gz /hlfapp/Deploy/$zip_folder_name
        yes|zip -r $zip_folder_name.zip $zip_folder_name
        #Unzip the folder into /hlfapp/Deploy
        rm -rf /hlfapp/Deploy/$zip_folder_name
        yes|unzip "$zip_folder_path" -d "/hlfapp/Deploy"
        echo "Folder $zip_folder_name.zip has been successfully extracted to /hlfapp/Deploy."
    else
     print_error "$vit_filename does not exist in $directory. Kindly place valid app.tar.gz "
    fi
else
     if [ -e "$zip_folder_path" ]; then
        # Unzip the folder into /hlfapp/Deploy
        unzip "$zip_folder_path" -d "/hlfapp/Deploy"
        echo "Folder $zip_folder_name.zip has been successfully extracted to /hlfapp/Deploy."
    else
        echo "Error: Folder $zip_folder_name.zip not found."
    fi
fi

shutdown_hlfdxp

format_and_display_jps

DIRECTORY="/hlfapp/DXPApp"

print_info "Proceeding to take the backup of DXPApp Module"
if [ -d "$DIRECTORY" ]; then
  print_info "$DIRECTORY available. Proceeding to take the backup of DXPApp Module"
  cd /hlfapp/ && tar -czPf DXPApp_bk_${NOW}.tar.gz DXPApp;
  status_check
  sleep 2s
  print_info "Proceeding to move the backup /hlfapp/Deploy/backup/${NOW} location"
  mv /hlfapp/DXPApp_bk_${NOW}.tar.gz /hlfapp/Deploy/backup/${NOW}/ >>${LOG};
  status_check
  sleep 2s
  print_info "Procceding to remove the DXPApp Module. Since backup done and moved backup file /hlfapp/Deploy/backup/${NOW}"
  cd /hlfapp/; rm -rf DXPApp >>${LOG};
  status_check
  sleep 2s
  print_info "untar DXPApp.tar.gz backup Since we need restore log files"
  cd /hlfapp/Deploy/backup/${NOW}; tar -xzf  DXPApp_bk_${NOW}.tar.gz >>${LOG};
  sleep 5s
status_check
else
  print_info "The 'DXPApp' directory does not exist. Still proceeding further.Considering this as the first time deployment."
fi

print_info "untar app.tar.gz downloaded deployment package from s3 bucket"
cd "$extract_path"; 
tar -xzf  app.tar.gz >>${LOG}; 
mv app DXPApp;
sleep 5s
status_check

print_info "copying all the folders into /hlfapp/DXPApp/ "
cp -rf  $extract_path/DXPApp  /hlfapp/ >>${LOG};
sleep 5s
status_check

print_info "Proceeding to remove the app folder from the deploymnet location Since deployment Done "
rm -rf $extract_path >>${LOG};
status_check

copy_log_files "/hlfapp/Deploy/backup/${NOW}/DXPApp/auth/logfiles/" "/hlfapp/DXPApp/auth/"
copy_log_files "/hlfapp/Deploy/backup/${NOW}/DXPApp/inquiry/logfiles/" "/hlfapp/DXPApp/inquiry/"
copy_log_files "/hlfapp/Deploy/backup/${NOW}/DXPApp/datasync/logfiles/" "/hlfapp/DXPApp/datasync/"
copy_log_files "/hlfapp/Deploy/backup/${NOW}/DXPApp/online/mdynamics/logfiles/" "/hlfapp/DXPApp/online/mdynamics/"
copy_log_files "/hlfapp/Deploy/backup/${NOW}/DXPApp/batch/logfiles/" "/hlfapp/DXPApp/batch/"
copy_log_files "/hlfapp/Deploy/backup/${NOW}/DXPApp/partitionservice/logfiles/" "/hlfapp/DXPApp/partitionservice/"

print_info "Proceeding to move the $zip_folder_path /hlfapp/Deploy/backup/${NOW} location"
mv $zip_folder_path /hlfapp/Deploy/backup/${NOW}/ >>${LOG};
sleep 2s
status_check

if [ "$current_hostname" = "$action_hostname2" ]; then
   echo "Changing process ID name in $current_hostname for Datasync P1L1_DATASYNC1-> P1L1_DATASYNC2, Inquiry P1L1_INQFE1-> P1L1_INQFE2, Auth P1L1_AUTH1-> P1L1_AUTH2"
   sed -i 's/mdyn.processId=P1L1_DATASYNC1/mdyn.processId=P1L1_DATASYNC2/g' /hlfapp/DXPApp/datasync/conf/application.properties
   sed -i 's/mdyn.processId=P1L1_INQFE1/mdyn.processId=P1L1_INQFE2/g' /hlfapp/DXPApp/inquiry/conf/application.properties
   sed -i 's/mdyn.processId=P1L1_AUTH1/mdyn.processId=P1L1_AUTH2/g' /hlfapp/DXPApp/auth/conf/application.properties
echo "Changing jms.client.id in Instance 2 $current_hostname"
   sed -i 's/ext.jms.client.id = inquiry/ext.jms.client.id = inquiry_b/g' /hlfapp/DXPApp/inquiry/conf/extBroker.properties
   sed -i 's/ext.jms.client.id = auth/ext.jms.client.id = auth_b/g' /hlfapp/DXPApp/auth/conf/extBroker.properties
   sed -i 's/ext.jms.client.id = datasync/ext.jms.client.id = datasync_b/g' /hlfapp/DXPApp/datasync/conf/extBroker.properties
   sed -i 's/ext.jms.client.id = P1G1_BTSGW1_1/ext.jms.client.id = P1G1_BTSGW1_2/g' /hlfapp/DXPApp/online/mdynamics/bin/notifBroker.properties
fi

if [ "$environment" = "uat" ]; then
 enable_relic
else
  print_info " Since scripts are running $environment not required to enable New Relic"
fi


if [ "$environment" = "vit" ]; then
print_info "Updating Memory related changes"
 sed -i 's/export JAVA_OPTS="-Xmx2048m"/export JAVA_OPTS="-Xmx512m"/g' /hlfapp/DXPApp/inquiry/bin/setenv.sh
 sed -i 's/export JAVA_OPTS="-Xmx2048m"/export JAVA_OPTS="-Xmx512m"/g' /hlfapp/DXPApp/auth/bin/setenv.sh
 sed -i 's/export JAVA_OPTS="-Xmx2048m"/export JAVA_OPTS="-Xmx512m"/g' /hlfapp/DXPApp/datasync/bin/setenv.sh
 sed -i 's/export JAVA_OPTS="-Xmx1024m"/export JAVA_OPTS="-Xmx512m"/g' /hlfapp/DXPApp/partitionservice/bin/setenv.sh
else
  print_info "Not required any changes with respect Memory related changes"
fi

enable_soft_link "BATCH" "/hlfapp/DXPApp/batch/lib"
enable_soft_link "WSPROCESS" "/hlfapp/DXPApp/online/mdynamics/process/wsprocess/3rdparty"
enable_soft_link "AUTH" "/hlfapp/DXPApp/auth/lib"
enable_soft_link "DATASYNC" "/hlfapp/DXPApp/datasync/lib"
enable_soft_link "PARTITIONSERVICE" "/hlfapp/DXPApp/partitionservice/lib"
enable_soft_link "ONLINE" "/hlfapp/DXPApp/online/mdynamics/lib/3rdparty"
enable_soft_link "INQUIRY" "/hlfapp/DXPApp/inquiry/lib"

print_info "Procceding to remove the DXPApp Module from backup folder . Since Back Done and moved backup file /hlfapp/Deploy/backup/${NOW}"
cd /hlfapp/Deploy/backup/${NOW}/; rm -rf DXPApp >>${LOG};
sleep 2s
status_check

download_ks_for_dxp
download_ks_for_bts

start_hlfdxp

}

restart_hlfdxp(){
  shutdown_hlfdxp
  format_and_display_jps
  start_hlfdxp
}

copy_log_files() {
    local source_folder="$1"
    local destination_folder="$2"

    # Check if the source folder is empty
    if [ -z "$(ls -A "$source_folder")" ]; then
        echo "Source folder '$source_folder' is empty. Nothing to copy."
    else
        # Print source and destination folders
        echo "Copying log files from '$source_folder' to '$destination_folder'..."

        # Copy the entire source folder to the destination
        cp -r "$source_folder" "$destination_folder"

        echo "Log files copied successfully."
    fi
}

insert_command_after_word() {
    local search_word="$1"
    local insert_command="$2"
    local input_file="$3"
    local insert_empty_line="$4"

    # Find the line number of the search word
    local word_line_number=$(grep -n "$search_word" "$input_file" | cut -d':' -f1)

    if [ -z "$word_line_number" ]; then
        echo "Word '$search_word' not found in the file."
    else
        # Increase the line number by 1
        word_line_number=$((word_line_number + 1))

        # Check if an empty line should be inserted
        if [ "$insert_empty_line" == "yes" ]; then
            # Insert an empty line at the specified line number
            sed -i "${word_line_number}a\\" "$input_file"
            # Increase the line number again
            word_line_number=$((word_line_number + 1))
        fi

        # Insert the command at the increased line number directly into the source file
        sed -i "${word_line_number}i$insert_command" "$input_file"

        echo "Command inserted after line number $word_line_number in '$input_file'."
    fi
}

enable_relic_auth(){
print_info "Adding NewRelic APM for AUTH"
# Define variables
search_word="CLASSPATH=\$APP_HOME"  # Note: Escaping the dollar sign
insert_command="# NewRelic APM for Auth"
input_file="/hlfapp/DXPApp/auth/bin/proj-hlfdxp-auth"
insert_empty_line="yes"
# Call the function with defined variables
insert_command_after_word "$search_word" "$insert_command" "$input_file" "$insert_empty_line"

# Define variables
search_word="# NewRelic APM for Auth"
insert_command='export JAVA_OPTS="$JAVA_OPTS -javaagent:/opt/newrelic-dxp-auth/newrelic.jar -Dnewrelic.environment=uat"'
insert_empty_line="no"

# Call the function with defined variables
insert_command_after_word "$search_word" "$insert_command" "$input_file" "$insert_empty_line"
}

enable_relic_batch(){
if [ "$current_hostname" = "$action_hostname1" ]; then
print_info "Adding NewRelic APM for BATCH"
# Define variables
search_word="CLASSPATH=\$APP_HOME"  # Note: Escaping the dollar sign
insert_command="# NewRelic APM for Batch"
input_file="/hlfapp/DXPApp/batch/bin/proj-hlfdxp-batch"
insert_empty_line="yes"
# Call the function with defined variables
insert_command_after_word "$search_word" "$insert_command" "$input_file" "$insert_empty_line"

# Define variables
search_word="# NewRelic APM for Batch"
insert_command='export JAVA_OPTS="$JAVA_OPTS -javaagent:/opt/newrelic-dxp-batch/newrelic.jar -Dnewrelic.environment=uat"'
insert_empty_line="no"

# Call the function with defined variables
insert_command_after_word "$search_word" "$insert_command" "$input_file" "$insert_empty_line"

else
   print_info "New Relic not required to configure Batch. Since scripts are running $current_hostname" 
fi
}

enable_relic_datasync(){
print_info "Adding NewRelic APM for DataSync"
# Define variables
search_word="CLASSPATH=\$APP_HOME"  # Note: Escaping the dollar sign
insert_command="# NewRelic APM for DataSync"
input_file="/hlfapp/DXPApp/datasync/bin/proj-hlfdxp-datasync"
insert_empty_line="yes"
# Call the function with defined variables
insert_command_after_word "$search_word" "$insert_command" "$input_file" "$insert_empty_line"

# Define variables
search_word="# NewRelic APM for DataSync"
insert_command='export JAVA_OPTS="$JAVA_OPTS -javaagent:/opt/newrelic-dxp-datasync/newrelic.jar -Dnewrelic.environment=uat"'
insert_empty_line="no"

# Call the function with defined variables
insert_command_after_word "$search_word" "$insert_command" "$input_file" "$insert_empty_line"
}


enable_relic_inquiry(){
print_info "Adding NewRelic APM for Inquiry"
# Define variables
search_word="CLASSPATH=\$APP_HOME"  # Note: Escaping the dollar sign
insert_command="# NewRelic APM for Inquiry"
input_file="/hlfapp/DXPApp/inquiry/bin/proj-hlfdxp-inquiry"
insert_empty_line="yes"
# Call the function with defined variables
insert_command_after_word "$search_word" "$insert_command" "$input_file" "$insert_empty_line"

# Define variables
search_word="# NewRelic APM for Inquiry"
insert_command='export JAVA_OPTS="$JAVA_OPTS -javaagent:/opt/newrelic-dxp-inquiry/newrelic.jar -Dnewrelic.environment=uat"'
insert_empty_line="no"

# Call the function with defined variables
insert_command_after_word "$search_word" "$insert_command" "$input_file" "$insert_empty_line"
}


enable_relic_online(){
print_info "Adding NewRelic APM for Online"
# Define variables
search_word="export CLASSPATH"
insert_command="# Add NewRelic APM (online-app)"
input_file="/hlfapp/DXPApp/online/mdynamics/bin/runApp"
insert_empty_line="yes"
# Call the function with defined variables
insert_command_after_word "$search_word" "$insert_command" "$input_file" "$insert_empty_line"

# Define variables
search_word="# Add NewRelic APM (online-app)"
insert_command='JVM_OPTION="$JVM_OPTION -javaagent:/opt/newrelic-dxp-online-app/newrelic.jar -Dnewrelic.environment=uat"'
insert_empty_line="no"

# Call the function with defined variables
insert_command_after_word "$search_word" "$insert_command" "$input_file" "$insert_empty_line"
}

enable_relic_wsprocess(){
if [ "$current_hostname" = "$action_hostname1" ]; then
print_info "Adding NewRelic APM for WSPROCESS"
# Define variables
search_word="export CLASSPATH"
insert_command="#NewRelic APM (online-wsapp)"
input_file="/hlfapp/DXPApp/online/mdynamics/bin/runWSApp"
insert_empty_line="yes"
# Call the function with defined variables
insert_command_after_word "$search_word" "$insert_command" "$input_file" "$insert_empty_line"

# Define variables
search_word="#NewRelic APM (online-wsapp)"
insert_command='JVM_OPTION="$JVM_OPTION -javaagent:/opt/newrelic-dxp-online-wsapp/newrelic.jar -Dnewrelic.environment=uat"'
insert_empty_line="no"

# Call the function with defined variables
insert_command_after_word "$search_word" "$insert_command" "$input_file" "$insert_empty_line"

else
   print_info "New Relic not required to configure for WSPROCESS. Since scripts are running $action_hostname2" 
fi
}

enable_relic(){

enable_relic_auth
enable_relic_batch
enable_relic_datasync
enable_relic_inquiry
enable_relic_online
enable_relic_wsprocess

}


download_ks_for_dxp(){

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


download_ks_for_bts(){

   print_info "${param_path}"

   file_path_loc=$(aws secretsmanager  get-secret-value --secret-id ${param_path}"bts/ts/ssl" | jq --raw-output '.SecretString' | jq -r .keyFilePath)
   ts_alias=$(aws secretsmanager  get-secret-value --secret-id ${param_path}"bts/ts/ssl" | jq --raw-output '.SecretString' | jq -r .keyAlias)
	  
    print_info "downloaing the DXP Trust store certficate: "$file_path_loc" and alias name:"$ts_alias
    aws secretsmanager get-secret-value --secret-id ${param_path}"bts/ts/ssl/b64" | jq --raw-output '.SecretString' >$file_path_loc

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


# Function to prompt for confirmation
confirm_action() {
    local action="$1"
    local service="$2"
    while true; do
        read -p "Are you sure you want to $action the $service service? (yes/no): " choice
        case "$choice" in
            [Yy]|[Yy][Ee][Ss])
                return 0  # Confirmation is yes, continue
                ;;
            [Nn]|[Nn][Oo])
                return 1  # Confirmation is no, do not proceed
                ;;
            *)
                echo "Please enter 'yes' or 'no'."
                ;;
        esac
    done
}

# Loop until the user chooses to quit
#!/bin/bash
function inner_select() {
    local choice="$1"  # The choice passed from the outer select
    case "$choice" in
        Deploy)
		 while true; do
          PS3="Select an option from the listed above : " # Customize the prompt
          options=("DEPLOY_HLFDXP" "backToParentMenu")
          select choice in "${options[@]}"; do
          case "$choice" in
					"DEPLOY_HLFDXP")
              mkdir -p /hlfapp/Deploy/backup/${NOW};
					    print_info "Input received from user to Deploy HLF-DXP Service(s)"
              if confirm_action "Deploy" "HLF_DXP"; then
                            format_and_display_jps
						                deploy_hlfdxp
                            echo "#####********************************####"
                            format_and_display_jps
                            echo "#####*********************************###"
                            break;
                        else
                          echo "Deploy HLF-DXP Service(s) aborted."
                       fi
						           ;;						
					"backToParentMenu")
                        break 2 # return to current (main) menu
                            ;;
                    *)
                        echo "Invalid option"
                        ;;
                esac
            done
		done
        ;;
        Shutdown)
            while true; do
          PS3="Select an option from the listed above: "  # Customize the prompt
          options=("AUTH" "BATCH" "DATASYNC" "INQUIRY" "ONLINE" "WSPROCESS" "PARTITIONSERVICE" "SHUTDOWNALL" "backToParentMenu")
          select choice in "${options[@]}"; do
          case "$choice" in
                "AUTH")
                    print_info "Input received from user to SHUTDOWN HLF-DXP AUTH Service"
                    format_and_display_jps
                       if confirm_action "Shutdown" "AUTH"; then
						                shutdown_auth
                        else
                          echo "SHUTDOWN AUTH Service aborted."
                       fi
                    format_and_display_jps
                       break;
                        ;;
                "BATCH")
					              print_info "Input received from user to SHUTDOWN HLF-DXP BATCH Service"
                        format_and_display_jps
                        if confirm_action "Shutdown" "BATCH"; then
						                if [ "$current_hostname" = "$action_hostname1" ]; then
					                  shutdown_batch
                            elif [ "$current_hostname" = "$action_hostname2" ]; then
                             echo "In HLF-DXP BATCH does not run in $action_hostname2 will run only $action_hostname1"
                            else
                             echo "Hostname does not match any expected hostnames"
                            fi  
                        else
                          echo "SHUTDOWN BATCH Service aborted."
                       fi
                        format_and_display_jps
                       break;
                        ;;
					      "DATASYNC")
                       print_info "Input received from user to SHUTDOWN HLF-DXP DATASYNC Service"
                       format_and_display_jps
                       if confirm_action "Shutdown" "DATASYNC"; then
						                shutdown_datasync
                        else
                          echo "SHUTDOWN DATASYNC Service aborted."
                       fi
                       format_and_display_jps
                       break;
                        ;;
					      "INQUIRY")
                        print_info "Input received from user to SHUTDOWN HLF-DXP INQUIRY Service"
                        format_and_display_jps
                        if confirm_action "Shutdown" ,"INQUIRY"; then
						                shutdown_inquiry
                        else
                          echo "SHUTDOWN INQUIRY Service aborted."
                       fi
                       format_and_display_jps
                       break;
                        ;;
					      "ONLINE")
                        print_info "Input received from user to SHUTDOWN HLF-DXP ONLINE Service"
                        format_and_display_jps
                         if confirm_action "Shutdown" "INQUIRY"; then
                            format_and_display_jps
						                shutdown_online
                        else
                          echo "SHUTDOWN ONLINE Service aborted."
                       fi
                       format_and_display_jps
                       break;
                        ;;		
                "WSPROCESS")
					             print_info "Input received from user to SHUTDOWN HLF-DXP WSPROCESS Service"
                      format_and_display_jps
                        if confirm_action "Shutdown" "WSPROCESS"; then
                            if [ "$current_hostname" = "$action_hostname1" ]; then
					                       shutdown_wsprocess
                            elif [ "$current_hostname" = "$action_hostname2" ]; then
                                echo "In HLF-DXP WSPROCESS does not run in $action_hostname2 will run only $action_hostname1"
                            else
                             echo "Hostname does not match any expected hostnames"
                            fi  
                        else
                          echo "SHUTDOWN WSPROCESS Service aborted."
                        fi
                       format_and_display_jps
                       break;
                        ;;		
					"PARTITIONSERVICE")
					           print_info "Input received from user to SHUTDOWN HLF-DXP PARTITIONSERVICE Service"
                     format_and_display_jps
                       if confirm_action "Shutdown" "PARTITIONSERVICE"; then
                            if [ "$current_hostname" = "$action_hostname1" ]; then
					                      shutdown_partitionservice
                            elif [ "$current_hostname" = "$action_hostname2" ]; then
                                echo "In HLF-DXP PARTITIONSERVICE does not run in $action_hostname2 will run only $action_hostname1"
                            else
                                 echo "Hostname does not match any expected hostnames"
                             fi  
                        else
                          echo "SHUTDOWN ONLINE Service aborted."
                       fi
                      format_and_display_jps
                       break;
                        ;;
					"SHUTDOWNALL")
                        print_info "Input received from user to SHUTDOWN HLF-DXP Service(s)"
                        format_and_display_jps
                        if confirm_action "Shutdown" "HLF-DXP Service(s)"; then   
						                shutdown_hlfdxp
                            echo "#####********************************####"
                            format_and_display_jps
                            echo "#####*********************************###"
                            break;
                        else
                          echo "SHUTDOWN ALL HSHUTDOWN HLF-DXP Service(s) aborted."
                       fi
                       format_and_display_jps
                       break;
                        ;;
					"backToParentMenu")
                        break 2 # return to current (main) menu
                            ;;
                    *)
                        echo "Invalid option"
                        ;;
                esac
            done
		done
        ;;
        Start)
             while true; do
             PS3="Select an option from the listed above: "  # Customize the prompt
          options=("AUTH" "BATCH" "DATASYNC" "INQUIRY" "ONLINE" "WSPROCESS" "PARTITIONSERVICE" "STARTALL" "backToParentMenu")
          select choice in "${options[@]}"; do
          case "$choice" in
          "AUTH")
                    print_info "Input received from user to start HLF-DXP AUTH Serivce"
                          format_and_display_jps
                        if confirm_action "Start" "AUTH"; then
						                start_auth
                        else
                          echo "Start AUTH aborted."
                        fi
                       format_and_display_jps
                       break;
                        ;;
          "BATCH")
					          print_info "Input received from user to start HLF-DXP BATCH Service"
                       format_and_display_jps
                       if confirm_action "Start" "BATCH"; then
                          if [ "$current_hostname" = "$action_hostname1" ]; then
					                      start_batch
                          elif [ "$current_hostname" = "$action_hostname2" ]; then
                               echo "In HLF-DXP BATCH does not run in $action_hostname2 will run only $action_hostname1"
                           else
                              echo "Hostname does not match any expected hostnames"
                          fi  
                        else
                          echo "Start AUTH aborted."
                       fi
                      format_and_display_jps
                      break;
                        ;;
					"DATASYNC")
                       print_info "Input received from user to start HLF-DXP DATASYNC Serivce"
                        format_and_display_jps
                        if confirm_action "Start" "DATASYNC"; then
						                start_datasync
                        else
                          echo "Start DATASYNC aborted."
                        fi
                       format_and_display_jps
                      break;
                        ;;
					"INQUIRY")
                        print_info "Input received from user to start HLF-DXP INQUIRY Serivce"
                        format_and_display_jps
                        if confirm_action "Start" "INQUIRY"; then
						                start_inquiry
                        else
                          echo "Start INQUIRY aborted."
                        fi
                        format_and_display_jps
                        break;
                        ;;
					"ONLINE")
                        print_info "Input received from user to start HLF-DXP ONLINE Serivce"
                        format_and_display_jps
                        if confirm_action "Start" "ONLINE"; then
						                start_online
                        else
                          echo "Start ONLINE aborted."
                        fi
                        format_and_display_jps
                        break
                        ;;
          "WSPROCESS")
					             print_info "Input received from user to start HLF-DXP WSPROCESS Serivce"
                        format_and_display_jps
                       if confirm_action "Start" "WSPROCESS"; then
                              if [ "$current_hostname" = "$action_hostname1" ]; then
					                        start_wsprocess
                              elif [ "$current_hostname" = "$action_hostname2" ]; then
                                  echo "In HLF-DXP WSPROCESS does not run in $action_hostname2 will run only $action_hostname1"
                              else
                                  echo "Hostname does not match any expected hostnames"
                              fi  
                        else
                          echo "Start WSPROCESS aborted."
                        fi
                       format_and_display_jps
                        break
                        ;;
					"PARTITIONSERVICE")
					              print_info "Input received from user to start HLF-DXP PARTITIONSERVICE Serivce"
                        format_and_display_jps
                         if confirm_action "Start" "PARTITIONSERVICE"; then
                            if [ "$current_hostname" = "$action_hostname1" ]; then
					                     start_partitionservice
                            elif [ "$current_hostname" = "$action_hostname2" ]; then
                               echo "In HLF-DXP PARTITIONSERVICE does not run in $action_hostname2 will run only $action_hostname1"
                            else
                               echo "Hostname does not match any expected hostnames"
                            fi
                        else
                          echo "Start PARTITIONSERVICE aborted."
                        fi
                        format_and_display_jps
                        break
                        ;;
					"STARTALL")
                    print_info "Input received from user to start HLF-DXP Serivce(s)"
                       format_and_display_jps
                       if confirm_action "STARTALL" "HLF-DXP Serivce(s)"; then
						                start_hlfdxp
                          echo "#####********************************####"
                           format_and_display_jps
                           echo "#####*********************************###"
                            break;
                        else
                          echo "Start HLF-DXP Serivce(s) aborted."
                        fi
                        format_and_display_jps
                        break
						            ;;
					"backToParentMenu")
                        break 2 # return to current (main) menu
                            ;;
                    *)
                        echo "Invalid option"
                        ;;
                esac
            done
		done
        ;;
        Restart)
            while true; do
          PS3="Select an option from the listed above: "  # Customize the prompt
          options=("AUTH" "BATCH" "DATASYNC" "INQUIRY" "ONLINE" "WSPROCESS" "PARTITIONSERVICE" "RESTARTALL" "backToParentMenu")
          select choice in "${options[@]}"; do
          case "$choice" in
                  "AUTH")
                        print_info "Input received from user to restart HLF-DXP AUTH Service"
                        format_and_display_jps
                        if confirm_action "RESTART" "AUTH"; then
						                restart_auth
                        else
                          echo "Restart AUTH aborted."
                        fi
                        format_and_display_jps
                        break
                        ;;
          "BATCH")
					             print_info "Input received from user to restart HLF-DXP BATCH Service"
                        format_and_display_jps
                        if confirm_action "RESTART" "BATCH"; then
                            if [ "$current_hostname" = "$action_hostname1" ]; then
					                     restart_batch
                            elif [ "$current_hostname" = "$action_hostname2" ]; then
                               echo "In HLF-DXP BATCH does not run in $action_hostname2 will run only $action_hostname1"
                            else
                                echo "Hostname does not match any expected hostnames"
                              fi  
                        else
                          echo "Restart BATCH aborted."
                        fi
                         format_and_display_jps
                        break;
                        ;;
					        "DATASYNC")
                        print_info "Input received from user to restart HLF-DXP DATASYNC Service"
                        format_and_display_jps
                        if confirm_action "RESTART" "DATASYNC"; then
						                restart_datasync
                        else
                          echo "Restart DATASYNC aborted."
                        fi
                        format_and_display_jps
                        break;
                        ;;
					        "INQUIRY")
                        print_info "Input received from user to restart HLF-DXP INQUIRY Service"
                        format_and_display_jps
                        if confirm_action "RESTART" "INQUIRY"; then
						                restart_inquiry
                        else
                          echo "Restart INQUIRY aborted."
                        fi
                        format_and_display_jps
                        break;
                        ;;
					        "ONLINE")
                        print_info "Input received from user to restart HLF-DXP ONLINE Service"
                        format_and_display_jps
                        if confirm_action "RESTART" "ONLINE"; then
						                restart_online
                        else
                          echo "Restart ONLINE aborted."
                        fi
                        format_and_display_jps
                        break;
                        ;;
                  "WSPROCESS")
					             print_info "Input received from user to restart HLF-DXP WSPROCESS Service"
                       format_and_display_jps
                         if confirm_action "RESTART" "WSPROCESS"; then
						                  if [ "$current_hostname" = "$action_hostname1" ]; then
					                        restart_wsprocess
                              elif [ "$current_hostname" = "$action_hostname2" ]; then
                                echo "In HLF-DXP WSPROCESS does not run in $action_hostname2 will run only $action_hostname1"
                              else
                                 echo "Hostname does not match any expected hostnames"
                              fi  
                        else
                          echo "Restart WSPROCESS aborted."
                        fi
                        format_and_display_jps
                        break;
                        ;;
					        "PARTITIONSERVICE")
					              print_info "Input received from user to restart HLF-DXP PARTITIONSERVICE Service"
                            format_and_display_jps
                            if confirm_action "RESTART" "ONLINE"; then
						                  if [ "$current_hostname" = "$action_hostname1" ]; then
					                        restart_partitionservice
                              elif [ "$current_hostname" = "$action_hostname2" ]; then
                                echo "In HLF-DXP PARTITIONSERVICE does not run in $action_hostname2 will run only $action_hostname1"
                               else
                                echo "Hostname does not match any expected hostnames"
                             fi  
                            else
                              echo "Restart PARTITIONSERVICE aborted."
                            fi
                            format_and_display_jps
                             break;
                        ;;
					        "RESTARTALL")
                        print_info "Input received from user to restart HLF-DXP Service(s)"
                        format_and_display_jps
                        if confirm_action "RESTART" " HLF-DXP Service(s)"; then
						                restart_hlfdxp
                            echo "#####********************************####"
                            format_and_display_jps
                            echo "#####*********************************###"
                            break;
                        else
                          echo "Restart  HLF-DXP Service(s) aborted."
                        fi
                        format_and_display_jps
                        break;
                        ;;
					        "backToParentMenu")
                        break 2 # return to current (main) menu
                            ;;
                    *)
                        echo "Invalid option"
                        ;;
                esac
            done
		done
        ;;
         TrustStore)
             while true; do
             PS3="Select an option from the listed above: "  # Customize the prompt
          options=("InstallTrustoreforDXP" "InstallTrustoreforBTS" "backToParentMenu")
          select choice in "${options[@]}"; do
          case "$choice" in
          "InstallTrustoreforDXP")
                    print_info "Input received from user to Remove and Insert Trustore"
                        if confirm_action "Install" "TrustStore"; then
						                download_ks_for_dxp
                        else
                          echo "Install TrustStore action aborted."
                        fi
                       break;
                        ;;
          "InstallTrustoreforBTS")
                    print_info "Input received from user to Remove and Insert Trustore"
                        if confirm_action "Install" "TrustStore"; then
						                download_ks_for_bts
                        else
                          echo "Install TrustStore action aborted."
                        fi
                       break;
                        ;;
					"backToParentMenu")
                        break 2 # return to current (main) menu
                            ;;
                    *)
                        echo "Invalid option"
                        ;;
                esac
            done
		done
        ;;
        ForceShutdown"(1b)")
          while true; do
          PS3="Select an option from the listed above: "  # Customize the prompt
          options=("BATCH" "WSPROCESS" "PARTITIONSERVICE" "backToParentMenu")
          select choice in "${options[@]}"; do
          case "$choice" in
         "BATCH")
					      print_info "Input received from user to SHUTDOWN HLF-DXP BATCH Service"
                    if confirm_action "Shutdown" "BATCH"; then
						          if [ "$current_hostname" = "$action_hostname1" ]; then
                        echo "Force Start not applicable for $action_hostname1 applicable only $action_hostname2 if need start in $action_hostname1,
                        Kindly use Option 2 (SHUTDOWN)"
                        elif [ "$current_hostname" = "$action_hostname2" ]; then
                            shutdown_batch
                            else
                             echo "Hostname does not match any expected hostnames"
                            fi  
                        else
                          echo "SHUTDOWN BATCH Service aborted."
                       fi
                        format_and_display_jps
                       break;
                        ;;
          "WSPROCESS")
					             print_info "Input received from user to SHUTDOWN HLF-DXP WSPROCESS Service"
                        if confirm_action "Shutdown" "WSPROCESS"; then
                            if [ "$current_hostname" = "$action_hostname1" ]; then
                              echo "Force Start not applicable for $action_hostname1 applicable only $action_hostname2 if need start in $action_hostname1,
                        Kindly use Option 2 (SHUTDOWN)"
                            elif [ "$current_hostname" = "$action_hostname2" ]; then
                                shutdown_wsprocess
                            else
                             echo "Hostname does not match any expected hostnames"
                            fi  
                        else
                          echo "SHUTDOWN WSPROCESS Service aborted."
                        fi
                       format_and_display_jps
                       break;
                        ;;		
					"PARTITIONSERVICE")
					           print_info "Input received from user to SHUTDOWN HLF-DXP PARTITIONSERVICE Service"
                       if confirm_action "Shutdown" "PARTITIONSERVICE"; then
                            if [ "$current_hostname" = "$action_hostname1" ]; then
					                    echo "Force Start not applicable for $action_hostname1 applicable only $action_hostname2 if need start in $action_hostname1,
                        Kindly use Option 2 (SHUTDOWN)"
                            elif [ "$current_hostname" = "$action_hostname2" ]; then
                                     shutdown_partitionservice
                            else
                                 echo "Hostname does not match any expected hostnames"
                             fi  
                        else
                          echo "SHUTDOWN ONLINE Service aborted."
                       fi
                      format_and_display_jps
                       break;
                        ;;
				"backToParentMenu")
                        break 2 # return to current (main) menu
                            ;;
                    *)
                        echo "Invalid option"
                        ;;
         ForceStart"(1b)")
          while true; do
          PS3="Select an option from the listed above: "  # Customize the prompt
          options=("BATCH" "WSPROCESS" "PARTITIONSERVICE" "backToParentMenu")
          select choice in "${options[@]}"; do
          case "$choice" in
        "BATCH")
					    print_info "Input received from user to start HLF-DXP BATCH Service"
                  if confirm_action "Start" "BATCH"; then
                    if [ "$current_hostname" = "$action_hostname1" ]; then
					          echo "Force Start not applicable for $action_hostname1 applicable only $action_hostname2 if need start in $action_hostname1,
                     Kindly use Option 3 (START)"
                    elif [ "$current_hostname" = "$action_hostname2" ]; then
                          start_batch
                  else
                      echo "Hostname does not match any expected hostnames"
                    fi  
                    else
                    echo "Start AUTH aborted."
                    fi
                    format_and_display_jps
                    break;
                    ;;
         "WSPROCESS")
					             print_info "Input received from user to start HLF-DXP WSPROCESS Serivce"
                       if confirm_action "Start" "WSPROCESS"; then
                              if [ "$current_hostname" = "$action_hostname1" ]; then
                              echo "Force Start not applicable for $action_hostname1 applicable only $action_hostname2 if need start in $action_hostname1,
                              Kindly use Option 3 (START)"
					                        start_wsprocess
                              elif [ "$current_hostname" = "$action_hostname2" ]; then
                                  start_wsprocess
                              else
                                  echo "Hostname does not match any expected hostnames"
                              fi  
                        else
                          echo "Start WSPROCESS aborted."
                        fi
                       format_and_display_jps
                        break
                        ;;
					"PARTITIONSERVICE")
					              print_info "Input received from user to start HLF-DXP PARTITIONSERVICE Serivce"
                         if confirm_action "Start" "PARTITIONSERVICE"; then
                            if [ "$current_hostname" = "$action_hostname1" ]; then
                             echo "Force Start not applicable for $action_hostname1 applicable only $action_hostname2 if need start in $action_hostname1,
                              Kindly use Option 3 (START)"
                            elif [ "$current_hostname" = "$action_hostname2" ]; then
                            	start_partitionservice
                            else
                               echo "Hostname does not match any expected hostnames"
                            fi
                        else
                          echo "Start PARTITIONSERVICE aborted."
                        fi
                        format_and_display_jps
                        break
                        ;;
				"backToParentMenu")
                        break 2 # return to current (main) menu
                            ;;
                    *)
                        echo "Invalid option"
                        ;;
                esac
            done
		done
        ;;
    ForceRestart"(1b)")
          while true; do
          PS3="Select an option from the listed above: "  # Customize the prompt
          options=("BATCH" "WSPROCESS" "PARTITIONSERVICE" "backToParentMenu")
          select choice in "${options[@]}"; do
          case "$choice" in
          "BATCH")
					        print_info "Input received from user to restart HLF-DXP BATCH Service"
                      if confirm_action "RESTART" "BATCH"; then
                          if [ "$current_hostname" = "$action_hostname1" ]; then
					                 echo "Force Restart not applicable for $action_hostname1 applicable only $action_hostname2 if need start in $action_hostname1,
                           Kindly use Option 4 (RESTART)"
                           elif [ "$current_hostname" = "$action_hostname2" ]; then
                           restart_batch
                           echo "In HLF-DXP BATCH does not run in $action_hostname2 will run only $action_hostname1"
                           else
                           echo "Hostname does not match any expected hostnames"
                              fi  
                        else
                          echo "Restart BATCH aborted."
                        fi
                         format_and_display_jps
                        break;
                        ;;
                  "WSPROCESS")
					             print_info "Input received from user to restart HLF-DXP WSPROCESS Service"
                         if confirm_action "RESTART" "WSPROCESS"; then
						                  if [ "$current_hostname" = "$action_hostname1" ]; then
                               echo "Force Restart not applicable for $action_hostname1 applicable only $action_hostname2 if need start in $action_hostname1,
                               Kindly use Option 4 (RESTART)"
                              elif [ "$current_hostname" = "$action_hostname2" ]; then
                                restart_wsprocess
                              else
                                 echo "Hostname does not match any expected hostnames"
                              fi  
                        else
                          echo "Restart WSPROCESS aborted."
                        fi
                        format_and_display_jps
                        break;
                        ;;
					        "PARTITIONSERVICE")
					              print_info "Input received from user to restart HLF-DXP PARTITIONSERVICE Service"
                            if confirm_action "RESTART" "ONLINE"; then
						                  if [ "$current_hostname" = "$action_hostname1" ]; then
                              print_info "Force Restart not applicable for $action_hostname1 applicable only $action_hostname2 if need start in $action_hostname1,
                               Kindly use Option 4 (RESTART)"   
                              elif [ "$current_hostname" = "$action_hostname2" ]; then
                                restart_partitionservice
                               else
                                echo "Hostname does not match any expected hostnames"
                             fi  
                            else
                              echo "Restart PARTITIONSERVICE aborted."
                            fi
                            format_and_display_jps
                             break;
                        ;;
				"backToParentMenu")
                        break 2 # return to current (main) menu
                            ;;
                    *)
                        echo "Invalid option"
                        ;;
                esac
            done
		done
        ;;
                esac
            done
		done
        ;;
		Quit)
		    print_info "Thanks ******"
			exit;
            ;;
        *)
            print_info "Invalid option"
            ;;
    esac
}
while true; do
 PS3="Select an option from the listed above : "  # Customize the prompt
    options=("Deploy" "Shutdown" "Start" "Restart" "TrustStore" "ForceStart(1b)" "ForceShutdown(1b)" "ForceRestart(1b)" "Quit")
    select option in "${options[@]}"; do
        if [[ "$option" ]]; then
            inner_select "$option"  # Pass the selected option to the inner_select function
            break
        else
            echo "Invalid option"
        fi
		break  
    done
done