#!/bin/bash

print_head() {
   echo "*********************************"
   echo -e "\e[1;34m[INFO]\e[0m \e[1m$1\e[0m \e[1;32m\e[0m"
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
elif [ "$environment" = "sit" ]; then
  action_hostname1="LIC_dxp-app1-sit"
elif [ "$environment" = "uat" ]; then
  action_hostname1="LIC_uat-dxp-online-app-01a"
  action_hostname2="LIC_uat-dxp-online-app-01b"
else
  echo "Invalid environment: $environment"
  exit 1
fi

current_hostname=$(hostname)

NOW=$(date +%Y%m%d%H%M%S)

mkdir -p /hlfapp/Deploy/backup;
mkdir -p /hlfapp/Deploy/backup/${NOW};
mkdir -p /hlfapp/Deploy/log;

LOG=/hlfapp/Deploy/log/HLF_DXP-Deployment${NOW}.log

print_head "Env :  $environment"
print_head "Hostname :  $current_hostname"

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
        echo "$process_name is running now."
    else
        echo "$process_name is not running now."
        echo
        echo "*********************************"
         
    fi
}

# Define a function to format and display Java processes
format_and_display_jps() {
  # Run the jps command and store the output in a variable
  local jps_output=$(jps)
  # Check if there are any Java processes running
  if [ -n "$jps_output" ]; then
  echo "---Status of running now process in Server $current_hostname---"
    # Print a header for the formatted output
    printf "%-10s %s\n" "PID" "Java Process"
    # Use awk to format and print the output
    display_color "green" "$jps_output" | awk '{ printf "%-10s %s\n", $1, $2 }'
  else
    display_color "red" "No Java processes found."
  fi
}


shutdown_auth(){
print_head "Checking the status of the AUTH process..."
if ps aux | grep -v grep | grep StdAuthAPIApp > /dev/null; then
  display_color "yellow" " It is running now. Proceeding to shut down the Auth process."
  sh /hlfapp/DXPApp/auth/bin/shutdown_auth.sh  >> "${LOG}" 2>&1;
  sleep 5s
  format_and_display_jps
  check_process_status "StdAuthAPIApp"
else
  display_color "red" "AUTH Process is not running now."
  sleep 5s
  format_and_display_jps
fi
}

start_auth(){
print_head "Checking the status of the AUTH process..."
if ! ps aux | grep -v grep | grep -q StdAuthAPIApp >> "${LOG}" 2>&1; then
  display_color "yellow" " It is not running now. Proceeding to start the AUTH process."
  cd /hlfapp/DXPApp/auth/bin/ >> "${LOG}" 2>&1; ./start_auth.sh >> "${LOG}" 2>&1;
  sleep 5s
  format_and_display_jps
  check_process_status "StdAuthAPIApp"
else
  display_color "red" "AUTH Process is running now. "
  format_and_display_jps
fi
}

restart_auth(){
shutdown_auth
start_auth
}


shutdown_datasync(){
print_head "Checking the status of the DATASYNC process..."
if ps aux | grep -v grep | grep StdDSAPIApp > /dev/null; then
   display_color "yellow" " It is running now. Proceeding to shut down the DATASYNC process."
   sh /hlfapp/DXPApp/datasync/bin/shutdown_ds.sh >> "${LOG}" 2>&1;
  sleep 5s
  format_and_display_jps
    check_process_status "StdDSAPIApp"
else
  display_color "red" "DATASYNC Process is not running now."
  sleep 5s
  format_and_display_jps
fi
}

start_datasync(){
print_head "Checking the status of the DATASYNC process..."
if ! ps aux | grep -v grep | grep StdDSAPIApp >> "${LOG}" 2>&1; then
  display_color "yellow" " It is not running now. Proceeding to start the DATASYNC process."
  cd /hlfapp/DXPApp/datasync/bin/ >> "${LOG}" 2>&1; ./start_ds.sh >> "${LOG}" 2>&1;
  sleep 5s
  format_and_display_jps
  check_process_status "StdDSAPIApp"
else
  display_color "red" "DATASYNC Process is running now."
  format_and_display_jps
fi
}

restart_datasync(){
shutdown_datasync
start_datasync
}

start_inquiry(){
print_head "Checking the status of the INQUIRY process..."
if ! ps aux | grep -v grep | grep StdInquiryAPIApp >> "${LOG}" 2>&1; then
  display_color "yellow" " It is not running now. Proceeding to start the INQUIRY process."
  cd /hlfapp/DXPApp/inquiry/bin/ >> "${LOG}" 2>&1; ./start_inquiry.sh >> "${LOG}" 2>&1;
  sleep 5s
  format_and_display_jps
  check_process_status "StdInquiryAPIApp"
else
  display_color "red" "INQUIRY Process is running now."
  format_and_display_jps
fi
}

shutdown_inquiry(){
  print_head "Checking the status of the INQUIRY process..."
if ps aux | grep -v grep | grep StdInquiryAPIApp > /dev/null; then
  display_color "yellow" " It is running now. Proceeding to shut down the INQUIRY process."
  sh /hlfapp/DXPApp/inquiry/bin/shutdown_inquiry.sh >> "${LOG}" 2>&1;
  sleep 5s
  format_and_display_jps
  check_process_status "StdInquiryAPIApp"
else
   display_color "red" "INQUIRY Process is not running now."
   sleep 5s
  format_and_display_jps
fi
}

restart_inquiry(){
  shutdown_inquiry
  start_inquiry
}


start_online(){
print_head "Checking the status of the ONLINE process..."
if [ "$current_hostname" = "$action_hostname1" ]; then
    if  ps aux | grep -v grep | grep EnvManager > /dev/null ||  ps aux | grep -v grep | grep HTTPSrvrGateway > /dev/null  ||  ps aux | grep -v grep | grep HostGateway > /dev/null; then
        display_color "red" "ONLINE Process is not running now."
        format_and_display_jps
    else
        display_color "yellow" "It is not running now. Proceeding to start the ONLINE process."
        cd /hlfapp/DXPApp/online/mdynamics/bin/ >> "${LOG}" 2>&1; ./start.sh P1G1_MGR1 >> "${LOG}" 2>&1;
        sleep 25s
          check_process_status "EnvManager"
          check_process_status "HTTPSrvrGateway"
          check_process_status "HostGateway"
          format_and_display_jps
    fi
elif [ "$current_hostname" = "$action_hostname2" ]; then
     if  ps aux | grep -v grep | grep EnvManager > /dev/null ||  ps aux | grep -v grep | grep HTTPSrvrGateway > /dev/null  ||  ps aux | grep -v grep | grep HostGateway > /dev/null; then
        display_color "red" "ONLINE Process is not running now."
        format_and_display_jps
    else
        display_color "yellow" "It is not running now. Proceeding to start the ONLINE process."
        cd /hlfapp/DXPApp/online/mdynamics/bin/ >> "${LOG}" 2>&1; ./start.sh P1G1_MGR2 >> "${LOG}" 2>&1;
        sleep 25s
          check_process_status "EnvManager"
          check_process_status "HTTPSrvrGateway"
          check_process_status "HostGateway"
          format_and_display_jps
    fi
else
    echo "Hostname does not match any expected hostnames"
fi
}

shutdown_online(){
print_head "Checking the status of the ONLINE (EnvManager,HTTPSrvrGateway, and HostGateway) process..."
if  ps aux | grep -v grep | grep EnvManager > /dev/null ||  ps aux | grep -v grep | grep HTTPSrvrGateway > /dev/null  ||  ps aux | grep -v grep | grep HostGateway > /dev/null; then
  display_color "yellow" "It is running now. Proceeding to shut down the ONLINE process. "
  sh /hlfapp/DXPApp/online/mdynamics/bin/stop.sh &>>${LOG};
    display_color "yellow" "Shutdown Initiated. Hold on.... It takes time... "
 sleep 25s
  format_and_display_jps
  check_process_status "EnvManager"
  check_process_status "HTTPSrvrGateway"
  check_process_status "HostGateway"
else
  display_color "red" "ONLINE Process is not running."
  sleep 5s
  format_and_display_jps
fi
}

restart_online(){
  shutdown_online
  start_online
}

shutdown_batch(){
if [ "$current_hostname" = "$action_hostname1" ]; then
print_head "Checking the status of the BATCH process..."
    if ps aux | grep -v grep | grep StdBatchApp > /dev/null; then
      display_color "yellow" " It is running now. Proceeding to shut down the BATCH process."
      sh /hlfapp/DXPApp/batch/bin/shutdown_bp.sh >> "${LOG}" 2>&1;
      sleep 10s
      format_and_display_jps
      check_process_status "StdBatchApp"
else
     display_color "red" "BATCH Process is not running now."
     sleep 5s
     format_and_display_jps
fi
elif [ "$current_hostname" = "$action_hostname2" ]; then
display_color "cyan" "Not Necessary to stop BATCH Process. Since scripts are running now in $action_hostname2"
else
    echo "Hostname does not match any expected hostnames"
fi
}

start_batch(){
print_head "Checking the status of the BATCH process..."
if [ "$current_hostname" = "$action_hostname1" ]; then
    if ! ps aux | grep -v grep | grep StdBatchApp >> "${LOG}" 2>&1; then
        display_color "yellow" " It is not running now. Proceeding to start the BATCH process."
        cd /hlfapp/DXPApp/batch/bin/ >> "${LOG}" 2>&1; ./start_bp.sh >> "${LOG}" 2>&1;
        sleep 25s
          check_process_status "StdBatchApp"
          format_and_display_jps
    else
        display_color "red" "BATCH Process is running now. Kindly check Manullay"
        format_and_display_jps
    fi
elif [ "$current_hostname" = "$action_hostname2" ]; then
     display_color "yellow" "Not required to start BATCH, Since scripts are running now in $action_hostname2"
     sleep 5s
     format_and_display_jps
else
    echo "Hostname does not match any expected hostnames"
fi
}

restart_batch(){
  shutdown_batch
  start_batch
}

shutdown_partitionservice(){
if [ "$current_hostname" = "$action_hostname1" ]; then
print_head "Checking the status of the PARTITIONSERVICE process..."
  if ps aux | grep -v grep | grep PartitionService > /dev/null; then
     display_color "yellow" " It is running now. Proceeding to shut down the PARTITIONSERVICE process."
     sh /hlfapp/DXPApp/partitionservice/bin/shutdown_ps.sh >> "${LOG}" 2>&1;
     sleep 10s
     format_and_display_jps
    check_process_status "PartitionService"
  else
    display_color "red" "PARTITIONSERVICE Process is not running now."
    sleep 5s
   format_and_display_jps
fi
elif [ "$current_hostname" = "$action_hostname2" ]; then
display_color "cyan" "Not Necessary to stop PARTITIONSERVICE Process. Since scripts are running now in $action_hostname2"
else
    echo "Hostname does not match any expected hostnames"
fi
}

start_partitionservice(){
print_head "Checking the status of the PARTITIONSERVICE process..."
if [ "$current_hostname" = "$action_hostname1" ]; then
    if ! ps aux | grep -v grep | grep PartitionService >> "${LOG}" 2>&1; then
        display_color "yellow" " It is not running now Proceeding to start the PARTITIONSERVICE process."
        cd /hlfapp/DXPApp/partitionservice/bin/ >> "${LOG}" 2>&1; ./start_ps.sh >> "${LOG}" 2>&1;
        sleep 25s
          check_process_status "PartitionService"
          format_and_display_jps
    else
        display_color "red" "PARTITIONSERVICE Process is running now. Kindly check Manullay"
        format_and_display_jps
    fi
elif [ "$current_hostname" = "$action_hostname2" ]; then
     display_color "yellow" "Not required to start PARTITIONSERVICE, Since scripts are running now in $action_hostname2"
     sleep 5s
     format_and_display_jps
else
    echo "Hostname does not match any expected hostnames"
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
  if [ "$current_hostname" = "$action_hostname1" ]; then
print_head "Checking the status of the WSPROCESS process..."
    if ps aux | grep -v grep | grep WebSvcProcess > /dev/null; then
        display_color "yellow" " It is running now Proceeding to shut down the WSPROCESS process."
        sh /hlfapp/DXPApp/online/mdynamics/bin/stopWSP.sh >> "${LOG}" 2>&1;
        sleep 10s
        format_and_display_jps
        check_process_status "WebSvcProcess"
     else
        display_color "red" "WSPROCESS Process is not running now."
        sleep 5s
        format_and_display_jps
fi
elif [ "$current_hostname" = "$action_hostname2" ]; then
display_color "cyan"  "Not Necessary to stop WSPROCESS Process. Since scripts are running now in $action_hostname2"
else
    echo "Hostname does not match any expected hostnames"
fi
}

start_wsprocess(){
print_head "Checking the status of the WSPROCESS process..."
if [ "$current_hostname" = "$action_hostname1" ]; then
    if ! ps aux | grep -v grep | grep WebSvcProcess >> "${LOG}" 2>&1; then
        display_color "yellow" " It is not running now. Proceeding to start the WSPROCESS process."
        cd /hlfapp/DXPApp/online/mdynamics/bin/ >> "${LOG}" 2>&1; ./startWSP.sh P1G1_WSPROCESS1 >> "${LOG}" 2>&1;
        sleep 10s
          check_process_status "WebSvcProcess"
          format_and_display_jps
    else
        display_color "red" "WebSvcProcess Process is running now. Kindly check Manullay"
        format_and_display_jps
    fi
elif [ "$current_hostname" = "$action_hostname2" ]; then
     display_color "yellow" "Not required to start WebSvcProcess, Since scripts are running now in $action_hostname2"
     sleep 5s
     format_and_display_jps
else
    echo "Hostname does not match any expected hostnames"
fi
}

shutdown_hlfdxp() {
shutdown_auth
shutdown_datasync
shutdown_inquiry
shutdown_online
shutdown_wsprocess
shutdown_batch 
shutdown_partitionservice
}

start_hlfdxp() {
start_auth
start_datasync
start_inquiry
start_online
start_wsprocess
start_batch 
start_partitionservice
}

deploy_hlfdxp(){

shutdown_hlfdxp

print_head "Proceeding to take the backup of DXPApp Module"
cd /hlfapp/; tar -czPf DXPApp_bk_${NOW}.tar.gz DXPApp;
sleep 5s
status_check

print_head "Proceeding to move the backup /hlfapp/Deploy/backup/${NOW} location"
mv /hlfapp/DXPApp_bk_${NOW}.tar.gz /hlfapp/Deploy/backup/${NOW}/ >>${LOG};
sleep 2s
status_check

print_head "Procceding to remove the DXPApp Module. Since Back Done and moved backup file /hlfapp/Deploy/backup/${NOW} "
cd /hlfapp/; rm -rf DXPApp >>${LOG};
sleep 2s
status_check

print_head "untar app.tar.gz downloaded deployment package from s3 bucket"
cd /hlfapp/Deploy/; tar -xzf  app.tar.gz >>${LOG};
cd /hlfapp/Deploy/; mv app DXPApp;
sleep 5s
status_check

print_head "copying all the folders into /hlfapp/DXPApp/ "
yes | cp -rf  /hlfapp/Deploy/DXPApp  /hlfapp/ >> "${LOG}" 2>&1;
sleep 5s
status_check

print_head "Procceding to remove the app folder from the deploymnet location Since deployment Done "
rm -rf /hlfapp/Deploy/DXPApp >>${LOG};
status_check

print_head "untar DXPApp.tar.gz downloaded deployment package from s3 bucket"
cd /hlfapp/Deploy/backup/${NOW}; tar -xzf  DXPApp_bk_${NOW}.tar.gz >>${LOG};
sleep 5s
status_check

print_head "Copying old log files from /hlfapp/Deploy/backup/${NOW}/DXPApp/auth/logfiles/ to /hlfapp/DXPApp/auth/logfiles"
cd /hlfapp/Deploy/backup/${NOW}/DXPApp/auth/logfiles/; 
if find . -maxdepth 1 -type f -name "*.log*" -o -name "*lck*" | grep -q .; then
  yes | cp -rf "/hlfapp/Deploy/backup/${NOW}/DXPApp/auth/logfiles/"* "/hlfapp/DXPApp/auth/logfiles/" >> "${LOG}" 2>&1
  sleep 3s
  status_check
else
  echo "Log Files not exits in: "/hlfapp/Deploy/backup/${NOW}/DXPApp/auth/logfiles/". So we are skipping the process copying old files to new deployment package:"
fi

print_head "Copying old log files from /hlfapp/Deploy/backup/${NOW}/DXPApp/inquiry/logfiles/ to /hlfapp/DXPApp/inquiry/logfiles"
cd /hlfapp/Deploy/backup/${NOW}/DXPApp/inquiry/logfiles/;
if [ -n "$(find . -maxdepth 1 -type f \( -name "*.log" -o -name "*_c.log" -o -name "*_default.log" \))" ]; then
  yes | cp -rf "/hlfapp/Deploy/backup/${NOW}/DXPApp/inquiry/logfiles/"* "/hlfapp/DXPApp/inquiry/logfiles/" >> "${LOG}" 2>&1
  status_check
else
  echo "Log Files not exits in: /hlfapp/Deploy/backup/${NOW}/DXPApp/inquiry/logfiles/. So we are skipping the process copying old files to new deployment package"
fi

print_head "Copying old log files from /hlfapp/Deploy/backup/${NOW}/DXPApp/datasync/logfile to /hlfapp/DXPApp/datasync/logfiles"
cd /hlfapp/Deploy/backup/${NOW}/DXPApp/datasync/logfiles/;
if [ -n "$(find . -maxdepth 1 -type f \( -name "*.log" -o -name "*_c.log" -o -name "*_default.log" \))" ]; then
  yes | cp -rf "/hlfapp/Deploy/backup/${NOW}/DXPApp/datasync/logfiles/"* "/hlfapp/DXPApp/datasync/logfiles/" >> "${LOG}" 2>&1
  status_check
else
  echo "Log Files not exits in: /hlfapp/Deploy/backup/${NOW}/DXPApp/datasync/logfiles/. So we are skipping the process copying old files to new deployment package"
fi

print_head "Copying old log files from /hlfapp/Deploy/backup/${NOW}/DXPApp/online/mdynamics/logfiles/ to /hlfapp/DXPApp/online/mdynamics/logfiles"
cd /hlfapp/Deploy/backup/${NOW}/DXPApp/online/mdynamics/logfiles/;
if [ -n "$(find . -maxdepth 1 -type f \( -name "*.log" -o -name "*_c.log" -o -name "*_default.log" \))" ]; then
  yes | cp -rf "/hlfapp/Deploy/backup/${NOW}/DXPApp/online/mdynamics/logfiles/"* "/hlfapp/DXPApp/online/mdynamics/logfiles/" >> "${LOG}" 2>&1
  status_check
else
  echo "Log Files not exits in: /hlfapp/Deploy/backup/${NOW}/DXPApp/online/mdynamics/logfiles/"
fi

if [ "$current_hostname" = "$action_hostname1" ]; then
print_head "Copying old log files from /hlfapp/Deploy/backup/${NOW}/batch/logfiles/ to /hlfapp/DXPApp/batch/logfiles"
cd /hlfapp/Deploy/backup/${NOW}/DXPApp/batch/logfiles/;
if [ -n "$(find . -maxdepth 1 -type f \( -name "*.log" -o -name "*_c.log" -o -name "*_default.log" \))" ]; then
       yes | cp -rf "/hlfapp/Deploy/backup/${NOW}/DXPApp/batch/logfiles/"* "/hlfapp/DXPApp/batch/logfiles/" >> "${LOG}" 2>&1
  status_check
    else
        echo "Log Files not exits in: /hlfapp/Deploy/backup/${NOW}/batch/logfiles/. So we are skipping the process copying old files to new deployment package"
    fi
elif [ "$current_hostname" = "$action_hostname2" ]; then
 echo "Not required to copy the log files for BATCH, Since scripts are running now in $action_hostname2"
else
    echo "Hostname does not match any expected hostnames"
fi

if [ "$current_hostname" = "$action_hostname1" ]; then
print_head "Copying old log files from /hlfapp/Deploy/backup/${NOW}/DXPApp/partitionservice/logfiles/ to /hlfapp/DXPApp/partitionservice/logfiles"
cd /hlfapp/Deploy/backup/${NOW}/DXPApp/partitionservice/logfiles/;
if [ -n "$(find . -maxdepth 1 -type f \( -name "*.log" -o -name "*_c.log" -o -name "*_default.log" \))" ]; then
  yes | cp -r "/hlfapp/Deploy/backup/${NOW}/DXPApp/partitionservice/logfiles/"* "/hlfapp/DXPApp/partitionservice/logfiles/" >> "${LOG}" 2>&1
else
  echo "Log Files not exits in: /hlfapp/Deploy/backup/${NOW}/DXPApp/partitionservice/logfiles/. So we are skipping the process copying old files to new deployment package"
fi
status_check
elif [ "$current_hostname" = "$action_hostname2" ]; then
   echo "Not required to copy the log files for PARTITIONSERVICE, Since scripts are running now in $action_hostname2"
else
    echo "Hostname does not match any expected hostnames"
fi

print_head "Procceding to remove the DXPApp Module from backup folder . Since Back Done and moved backup file /hlfapp/Deploy/backup/${NOW} "
cd /hlfapp/Deploy/backup/${NOW}/; rm -rf DXPApp >>${LOG};
sleep 2s
status_check

print_head "Proceeding to move the Deployed app.tar.gz /hlfapp/Deploy/backup/${NOW} location"
mv /hlfapp/Deploy/app.tar.gz /hlfapp/Deploy/backup/${NOW}/ >>${LOG};
sleep 2s
status_check

print_head "Enabling Soft Link for Online"
file_path="/hlfapp/DXPApp/online/mdynamics/lib/3rdparty/mysql-connector-j-8.0.33.jar"
if [ -f "$file_path" ]; then
    echo "MYSQL-CONNECTOR-J-8.0.33.JAR exists: $file_path :: Proceeding to delete mysql-connector-j-8.0.33.jar then enable soft link "
	rm -rf /hlfapp/DXPApp/online/mdynamics/lib/3rdparty/mysql-connector-j-8.0.33.jar;
	cd /hlfapp/DXPApp/online/mdynamics/lib/3rdparty/; 
	ln -s /opt/mysql-connector-java-8.0.30/mysql-connector-j-8.0.33.jar mysqlconnector.jar;	
else
    echo "MYSQL-CONNECTOR-J-8.0.33.JAR does not exist: $file_path  :: Proceeding to enable soft link"
	rm -rf /hlfapp/DXPApp/online/mdynamics/lib/3rdparty/mysql-connector-j-8.0.33.jar;
	cd /hlfapp/DXPApp/online/mdynamics/lib/3rdparty/; 
	ln -s /opt/mysql-connector-java-8.0.30/mysql-connector-j-8.0.33.jar mysqlconnector.jar;	
fi

print_head "Enabling Soft Link for AUTH"
file_path="/hlfapp/DXPApp/auth/lib/mysql-connector-j-8.0.33.jar"
if [ -f "$file_path" ]; then
    echo "MYSQL-CONNECTOR-J-8.0.33.JAR exists: $file_path :: Proceeding to delete mysql-connector-j-8.0.33.jar then enable soft link "
    rm -rf /hlfapp/DXPApp/auth/lib/mysql-connector-j-8.0.33.jar;
    cd /hlfapp/DXPApp/auth/lib/; 
	ln -s /opt/mysql-connector-java-8.0.30/mysql-connector-j-8.0.33.jar mysqlconnector.jar;
else
    echo "MYSQL-CONNECTOR-J-8.0.33.JAR does not exist: $file_path  :: Proceeding to enable soft link"
	cd /hlfapp/DXPApp/auth/lib/; ln -s /opt/mysql-connector-java-8.0.30/mysql-connector-j-8.0.33.jar mysqlconnector.jar;
fi

print_head "Enabling Soft Link for INQUIRY"
file_path="/hlfapp/DXPApp/inquiry/lib/mysql-connector-j-8.0.33.jar"
if [ -f "$file_path" ]; then
    echo "MYSQL-CONNECTOR-J-8.0.33.JAR exists: $file_path :: Proceeding to delete mysql-connector-j-8.0.33.jar then enable soft link "
    rm -rf /hlfapp/DXPApp/inquiry/lib/mysql-connector-j-8.0.33.jar;
    cd /hlfapp/DXPApp/inquiry/lib/;
	ln -s /opt/mysql-connector-java-8.0.30/mysql-connector-j-8.0.33.jar mysqlconnector.jar;
else
    echo "MYSQL-CONNECTOR-J-8.0.33.JAR does not exist: $file_path  :: Proceeding to enable soft link"
	cd /hlfapp/DXPApp/inquiry/lib/; 
	ln -s /opt/mysql-connector-java-8.0.30/mysql-connector-j-8.0.33.jar mysqlconnector.jar;
fi

print_head "Enabling Soft Link for Datasync"
file_path="/hlfapp/DXPApp/datasync/lib/mysql-connector-j-8.0.33.jar"
if [ -f "$file_path" ]; then
    echo "MYSQL-CONNECTOR-J-8.0.33.JAR exists: $file_path :: Proceeding to delete mysql-connector-j-8.0.33.jar then enable soft link "
     rm -rf /hlfapp/DXPApp/datasync/lib/mysql-connector-j-8.0.33.jar;
     cd /hlfapp/DXPApp/datasync/lib/;
	 ln -s /opt/mysql-connector-java-8.0.30/mysql-connector-j-8.0.33.jar mysqlconnector.jar;
else
    echo "MYSQL-CONNECTOR-J-8.0.33.JAR does not exist: $file_path  :: Proceeding to enable soft link"
	cd /hlfapp/DXPApp/datasync/lib/; 
	ln -s /opt/mysql-connector-java-8.0.30/mysql-connector-j-8.0.33.jar mysqlconnector.jar;
fi

if [ "$current_hostname" = "$action_hostname1" ]; then
print_head "Enabling Soft Link for PARTITIONSERVICE"
file_path="/hlfapp/DXPApp/partitionservice/lib/mysql-connector-j-8.0.33.jar"
if [ -f "$file_path" ]; then
    echo "MYSQL-CONNECTOR-J-8.0.33.JAR exists: $file_path :: Proceeding to delete mysql-connector-j-8.0.33.jar then enable soft link "
     rm -rf /hlfapp/DXPApp/partitionservice/lib/mysql-connector-j-8.0.33.jar;
     cd /hlfapp/DXPApp/partitionservice/lib;
     ln -s /opt/mysql-connector-java-8.0.30/mysql-connector-j-8.0.33.jar mysqlconnector.jar;
else
    echo "MYSQL-CONNECTOR-J-8.0.33.JAR does not exist: $file_path  :: Proceeding to enable soft link"
	cd /hlfapp/DXPApp/partitionservice/lib;
    ln -s /opt/mysql-connector-java-8.0.30/mysql-connector-j-8.0.33.jar mysqlconnector.jar;
fi

print_head "Enabling Soft Link for WSPROCESS"
file_path="/hlfapp/DXPApp/online/mdynamics/process/wsprocess/3rdparty/mysql-connector-j-8.0.33.jar"
if [ -f "$file_path" ]; then
    echo "MYSQL-CONNECTOR-J-8.0.33.JAR exists: $file_path :: Proceeding to delete mysql-connector-j-8.0.33.jar then enable soft link "
	rm -rf /hlfapp/DXPApp/online/mdynamics/process/wsprocess/3rdparty/mysql-connector-j-8.0.33.jar;
    cd /hlfapp/DXPApp/online/mdynamics/process/wsprocess/3rdparty/;
    ln -s /opt/mysql-connector-java-8.0.30/mysql-connector-j-8.0.33.jar mysqlconnector.jar;
else
    echo "MYSQL-CONNECTOR-J-8.0.33.JAR does not exist: $file_path  :: Proceeding to enable soft link"
	rm -rf /hlfapp/DXPApp/online/mdynamics/process/wsprocess/3rdparty/mysql-connector-j-8.0.33.jar;
	cd /hlfapp/DXPApp/online/mdynamics/process/wsprocess/3rdparty/;
    ln -s /opt/mysql-connector-java-8.0.30/mysql-connector-j-8.0.33.jar mysqlconnector.jar;
fi

print_head "Enabling Soft Link for BATCH"
file_path="/hlfapp/DXPApp/batch/lib/mysql-connector-j-8.0.33.jar"
if [ -f "$file_path" ]; then
    echo "MYSQL-CONNECTOR-J-8.0.33.JAR exists: $file_path :: Proceeding to delete mysql-connector-j-8.0.33.jar then enable soft link "
	rm -rf /hlfapp/DXPApp/batch/lib/mysql-connector-j-8.0.33.jar;
    cd /hlfapp/DXPApp/batch/lib/;
    ln -s /opt/mysql-connector-java-8.0.30/mysql-connector-j-8.0.33.jar mysqlconnector.jar;
else
    echo "MYSQL-CONNECTOR-J-8.0.33.JAR does not exist: $file_path  :: Proceeding to enable soft link"
	cd /hlfapp/DXPApp/batch/lib/;
    ln -s /opt/mysql-connector-java-8.0.30/mysql-connector-j-8.0.33.jar mysqlconnector.jar;
fi

elif [ "$current_hostname" = "$action_hostname2" ]; then
  echo "Changing process ID name in Instance 2 for Datasync P1L1_DATASYNC1-> P1L1_DATASYNC2, Inquiry P1L1_INQFE1-> P1L1_INQFE2, Auth P1L1_AUTH1-> P1L1_AUTH2 $current_hostname"
sed -i 's/mdyn.processId=P1L1_DATASYNC1/mdyn.processId=P1L1_DATASYNC2/g' /hlfapp/DXPApp/datasync/conf/application.properties
sed -i 's/mdyn.processId=P1L1_INQFE1/mdyn.processId=P1L1_INQFE2/g' /hlfapp/DXPApp/inquiry/conf/application.properties
sed -i 's/mdyn.processId=P1L1_AUTH1/mdyn.processId=P1L1_AUTH2/g' /hlfapp/DXPApp/auth/conf/application.properties
else
    echo "Hostname does not match any expected hostnames"
fi

start_hlfdxp

}

restart_hlfdxp(){
  shutdown_hlfdxp
  start_hlfdxp
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
            select sub_option in DEPLOY_HLFDXP backToParentMenu; do
                case "$sub_option" in
					DEPLOY_HLFDXP)
					    print_head "Input received from user to Deploy HLF-DXP Service(s)"
              if confirm_action "Deploy" ,"HLF_DXP"; then
                           format_and_display_jps
						                deploy_hlfdxp
                        else
                          echo "Deploy HLF-DXP Service(s) aborted."
                       fi
						  ;;						
					backToCurrentMenu)
                        break # return to current (main) menu
						  ;;
					backToParentMenu)
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
            select sub_option in AUTH BATCH DATASYNC INQUIRY ONLINE WSPROCESS PARTITIONSERVICE SHUTDOWNALL backToCurrentMenu backToParentMenu; do
              case "$sub_option" in
                AUTH)
                    print_head "Input received from user to SHUTDOWN HLF-DXP AUTH Service"
                       if confirm_action "Shutdown" ,"AUTH"; then
                            format_and_display_jps
						                shutdown_auth
                        else
                          echo "SHUTDOWN AUTH Service aborted."
                       fi
                        ;;
                BATCH)
					              print_head "Input received from user to SHUTDOWN HLF-DXP BATCH Service"
                        if confirm_action "Shutdown" ,"BATCH"; then
                            format_and_display_jps
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
                        ;;
					      DATASYNC)
                       print_head "Input received from user to SHUTDOWN HLF-DXP DATASYNC Service"
                       if confirm_action "Shutdown" ,"DATASYNC"; then
                            format_and_display_jps
						                shutdown_datasync
                        else
                          echo "SHUTDOWN DATASYNC Service aborted."
                       fi
                        ;;
					      INQUIRY)
                        print_head "Input received from user to SHUTDOWN HLF-DXP INQUIRY Service"
                        if confirm_action "Shutdown" ,"INQUIRY"; then
                            format_and_display_jps
						                shutdown_inquiry
                        else
                          echo "SHUTDOWN INQUIRY Service aborted."
                       fi
                        ;;
					      ONLINE)
                        print_head "Input received from user to SHUTDOWN HLF-DXP ONLINE Service"
                         if confirm_action "Shutdown" ,"INQUIRY"; then
                            format_and_display_jps
						                shutdown_online
                        else
                          echo "SHUTDOWN ONLINE Service aborted."
                       fi
                        ;;		
                WSPROCESS)
					             print_head "Input received from user to SHUTDOWN HLF-DXP WSPROCESS Service"
                        if confirm_action "Shutdown" ,"WSPROCESS"; then
                            format_and_display_jps
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
                        ;;		
					PARTITIONSERVICE)
					           print_head "Input received from user to SHUTDOWN HLF-DXP PARTITIONSERVICE Service"
                     format_and_display_jps
                       if confirm_action "Shutdown" ,"PARTITIONSERVICE"; then
                            format_and_display_jps
                            if [ "$current_hostname" = "$action_hostname1" ]; then
					                      shutdown_partitionservice
                            elif [ "$current_hostname" = "$action_hostname2" ]; then
                                echo "In HLF-DXP PARTITIONSERVICE does not run in $action_hostname2 will run only $action_hostname1"
                            else
                                 echo "Hostname does not match any expected hostnames"
                             fi  
						                shutdown_online
                        else
                          echo "SHUTDOWN ONLINE Service aborted."
                       fi
                        ;;
					SHUTDOWNALL)
                        print_head "Input received from user to SHUTDOWN HLF-DXP Service(s)"
                        if confirm_action "Shutdown" ,"HLF-DXP Service(s)"; then
                            format_and_display_jps
						                shutdown_hlfdxp
                        else
                          echo "SHUTDOWN ALL HSHUTDOWN HLF-DXP Service(s) aborted."
                       fi 
                        ;;
					backToCurrentMenu)
                        break # return to current (main) menu
						                ;;
					backToParentMenu)
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
            select sub_option in AUTH BATCH DATASYNC INQUIRY ONLINE WSPROCESS PARTITIONSERVICE STARTALL backToCurrentMenu backToParentMenu; do
                case "$sub_option" in
          AUTH)
                    print_head "Input received from user to start HLF-DXP AUTH Serivce"
                        if confirm_action "Start" ,"AUTH"; then
                            format_and_display_jps
						                start_auth
                        else
                          echo "Start AUTH aborted."
                        fi
                        ;;
          BATCH)
					          print_head "Input received from user to start HLF-DXP BATCH Service"
                       format_and_display_jps
                       if confirm_action "Start" ,"AUTH"; then
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
                        ;;
					DATASYNC)
                       print_head "Input received from user to start HLF-DXP DATASYNC Serivce"
                        if confirm_action "Start" ,"DATASYNC"; then
                            format_and_display_jps
						                start_datasync
                        else
                          echo "Start DATASYNC aborted."
                        fi
                        ;;
					INQUIRY)
                        print_head "Input received from user to start HLF-DXP INQUIRY Serivce"
                        if confirm_action "Start" ,"INQUIRY"; then
                            format_and_display_jps
						                start_inquiry
                        else
                          echo "Start INQUIRY aborted."
                        fi
                        ;;
					ONLINE)
                        print_head "Input received from user to start HLF-DXP ONLINE Serivce"
                        if confirm_action "Start" ,"ONLINE"; then
                            format_and_display_jps
						                start_online
                        else
                          echo "Start ONLINE aborted."
                        fi
                        ;;
          WSPROCESS)
					             print_head "Input received from user to start HLF-DXP WSPROCESS Serivce"
                       if confirm_action "Start" ,"WSPROCESS"; then
                           format_and_display_jps
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
                        ;;
					PARTITIONSERVICE)
					              print_head "Input received from user to start HLF-DXP PARTITIONSERVICE Serivce"
                         if confirm_action "Start" ,"PARTITIONSERVICE"; then
                            format_and_display_jps
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
                        ;;
					STARTALL)
                    print_head "Input received from user to start HLF-DXP Serivce(s)"
                       format_and_display_jps
                       if confirm_action "STARTALL" ,"HLF-DXP Serivce(s)"; then
						                start_hlfdxp
                        else
                          echo "Start HLF-DXP Serivce(s) aborted."
                        fi
                        ;;
					backToCurrentMenu)
                        break # return to current (main) menu
						                ;;
					backToParentMenu)
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
            select sub_option in AUTH BATCH DATASYNC INQUIRY ONLINE WSPROCESS PARTITIONSERVICE RESTARTALL backToCurrentMenu backToParentMenu; do
                case "$sub_option" in
                    AUTH)
                        print_head "Input received from user to restart HLF-DXP AUTH Service"
                        format_and_display_jps
						restart_auth
                        ;;
                    BATCH)
					print_head "Input received from user to restart HLF-DXP BATCH Service"
                       format_and_display_jps
					  if [ "$current_hostname" = "$action_hostname1" ]; then
					    restart_batch
                      elif [ "$current_hostname" = "$action_hostname2" ]; then
                          echo "In HLF-DXP BATCH does not run in $action_hostname2 will run only $action_hostname1"
                    else
                      echo "Hostname does not match any expected hostnames"
                     fi  
                        ;;
					DATASYNC)
                        print_head "Input received from user to restart HLF-DXP DATASYNC Service"
                        format_and_display_jps
						 restart_datasync
                        ;;
					INQUIRY)
                        print_head "Input received from user to restart HLF-DXP INQUIRY Service"
                        format_and_display_jps
						restart_inquiry
                        ;;
					ONLINE)
                        print_head "Input received from user to restart HLF-DXP ONLINE Service"
                        format_and_display_jps
						restart_online
                        ;;
          WSPROCESS)
					print_head "Input received from user to restart HLF-DXP WSPROCESS Service"
          format_and_display_jps
					  if [ "$current_hostname" = "$action_hostname1" ]; then
					    restart_wsprocess
                      elif [ "$current_hostname" = "$action_hostname2" ]; then
                          echo "In HLF-DXP WSPROCESS does not run in $action_hostname2 will run only $action_hostname1"
                    else
                      echo "Hostname does not match any expected hostnames"
                     fi  
                        ;;
					PARTITIONSERVICE)
					print_head "Input received from user to restart HLF-DXP PARTITIONSERVICE Service"
          format_and_display_jps
					  if [ "$current_hostname" = "$action_hostname1" ]; then
					    restart_partitionservice
                      elif [ "$current_hostname" = "$action_hostname2" ]; then
                          echo "In HLF-DXP PARTITIONSERVICE does not run in $action_hostname2 will run only $action_hostname1"
                    else
                      echo "Hostname does not match any expected hostnames"
                     fi  
                        ;;
					RESTARTALL)
                        print_head "Input received from user to restart HLF-DXP Service(s)"
                        format_and_display_jps
						 restart_hlfdxp
                        ;;
					backToCurrentMenu)
                        break # return to current (main) menu
						                ;;
					backToParentMenu)
                        break 2 # return to current (main) menu
                            ;;
                    *)
                        echo "Invalid option"
                        ;;
                esac
            done
		done
        ;;
		Quit)
		    print_head "Thanks ******"
			exit;
            ;;
        *)
            print_head "Invalid option"
            ;;
    esac
}

while true; do
    select option in Deploy Shutdown Start Restart Quit; do
        inner_select "$option"  # Pass the selected option to the inner_select function
		break  
    done
done