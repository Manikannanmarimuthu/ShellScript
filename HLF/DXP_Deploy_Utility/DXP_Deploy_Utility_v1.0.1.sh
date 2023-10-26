#!/bin/bash

print_head() {
  #echo -e "\e[1;35m $1 \e[0m"
   echo -e "\e[1;34m[INFO]\e[0m \e[1m$1\e[0m is \e[1;32m\e[0m."
}

action_hostname1="HLFVITAPP31"
action_hostname2="HLFVITAPP232"
current_hostname=$(hostname)

NOW=$(date +%Y%m%d%H%M%S)

LOG=/hlfapp/DXPApp/Deployment/HLF_DXP-Deployment${NOW}.log

print_head "Hostname :  $current_hostname"

print_process_status() {
  echo -e "\e[4;43m $1 [0m"
}

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
        echo "$process_name is running."
    else
        echo "$process_name is not running."
    fi
}

# Define a function to format and display Java processes
format_and_display_jps() {
  # Run the jps command and store the output in a variable
  local jps_output=$(jps)
  # Check if there are any Java processes running
  if [ -n "$jps_output" ]; then
  echo "------Status of running process in $current_hostname -----------"
    # Print a header for the formatted output
    printf "%-10s %s\n" "PID" "Java Process"
    # Use awk to format and print the output
    display_color "green" "$jps_output" | awk '{ printf "%-10s %s\n", $1, $2 }'
    echo "------------------------------------------"
  else
    display_color "red" "No Java processes found."
  fi
}

shutdown_hlfdxp() {

print_head "Checking the status of the AUTH process..."
if ps aux | grep -v grep | grep StdAuthAPIApp > /dev/null; then
  display_color "yellow" " It's running... Proceeding to shut down the Auth process."
  cd /hlfapp/DXPApp/auth/bin/ &>>${LOG}; ./shutdown_auth.sh &>>${LOG};
  sleep 5s
  format_and_display_jps
  check_process_status "StdAuthAPIApp"
else
  display_color "red" "AUTH Process is not running."
  format_and_display_jps
fi

print_head "Checking the status of the DATASYNC process..."
if ps aux | grep -v grep | grep StdDSAPIApp > /dev/null; then
   display_color "yellow" " It's running... Proceeding to shut down the DATASYNC process."
  cd /hlfapp/DXPApp/datasync/bin/ &>>${LOG}; ./shutdown_ds.sh &>>${LOG};
  sleep 5s
  format_and_display_jps
    check_process_status "StdDSAPIApp"
else
  display_color "red" "DATASYNC Process is not running."
  format_and_display_jps
fi

print_head "Checking the status of the INQUIRY process..."
if ps aux | grep -v grep | grep StdInquiryAPIApp > /dev/null; then
  display_color "yellow" " It's running... Proceeding to shut down the INQUIRY process."
  cd /hlfapp/DXPApp/inquiry/bin/ &>>${LOG}; ./shutdown_inquiry.sh &>>${LOG};
  sleep 5s
  format_and_display_jps
  check_process_status "StdInquiryAPIApp"
else
   display_color "red" "INQUIRY Process is not running."
  format_and_display_jps
fi

print_head "Checking the status of the ONLINE (EnvManager,HTTPSrvrGateway, and HostGateway) process..."
if [ps aux | grep -v grep | grep EnvManager] || [ps aux | grep -v grep | grep HTTPSrvrGateway] || [ps aux | grep -v grep | grep HostGateway] > /dev/null; then
  display_color "yellow" "It's running. Proceeding to shut down the ONLINE process. "
  cd /hlfapp/DXPApp/online/mdynamics/bin/ &>>${LOG}; ./stop.sh &>>${LOG};
    display_color "yellow" "Shutdown Initiated. Hold on.... It takes time... "
 sleep 25s
  format_and_display_jps
  check_process_status "EnvManager"
  check_process_status "HTTPSrvrGateway"
  check_process_status "HostGateway"
else
  display_color "red" "ONLINE Process is not running."
  format_and_display_jps
fi

if [ "$current_hostname" = "$action_hostname1" ]; then
print_head "Checking the status of the WSPROCESS process..."
if ps aux | grep -v grep | grep WebSvcProcess > /dev/null; then
display_color "yellow" " It's running... Proceeding to shut down the WSPROCESS process."
cd /hlfapp/DXPApp/online/mdynamics/bin/ &>>${LOG}; ./stopWSP.sh &>>${LOG};
sleep 10s
format_and_display_jps
 check_process_status "WebSvcProcess"
else
  display_color "red" "WSPROCESS Process is not running."
  format_and_display_jps
fi

print_head "Checking the status of the BATCH process..."
if ps aux | grep -v grep | grep StdBatchApp > /dev/null; then
display_color "yellow" " It's running... Proceeding to shut down the BATCH process."
cd /hlfapp/DXPApp/batch/bin/ &>>${LOG}; ./shutdown_bp.sh &>>${LOG};
sleep 10s
format_and_display_jps
check_process_status "StdBatchApp"
else
  display_color "red" "BATCH Process is not running."
  format_and_display_jps
fi

print_head "Checking the status of the PARTITIONSERVICE process..."
if ps aux | grep -v grep | grep PartitionService > /dev/null; then
display_color "yellow" " It's running... Proceeding to shut down the PARTITIONSERVICE process."
cd /hlfapp/DXPApp/partitionservice/bin/ &>>${LOG}; ./shutdown_ps.sh &>>${LOG};
sleep 10s
format_and_display_jps
check_process_status "PartitionService"
else
  display_color "red" "PARTITIONSERVICE Process is not running."
  format_and_display_jps
fi

print_head "**** HLF-DXP Services are Down Now. ***** "

elif [ "$current_hostname" = "$action_hostname2" ]; then
echo "Not Necessary to stop WEB SERVICE, BATCH,PARTITIONSERVICE. Since scripts are running in $action_hostname2"
else
    echo "Hostname does not match any expected hostnames"
fi
}

start_hlfdxp() {

print_head "Checking the status of the AUTH process..."
if ![ps aux | grep -v grep | grep StdAuthAPIApp] > /dev/null; then
  display_color "yellow" " It's not running... Proceeding to start the AUTH process."
  cd /hlfapp/DXPApp/auth/bin/ &>>${LOG}; ./start_auth.sh &>>${LOG};
  sleep 5s
  format_and_display_jps
  check_process_status "StdAuthAPIApp"
else
  display_color "red" "AUTH Process is running. "
  format_and_display_jps
fi

print_head "Checking the status of the DATASYNC process..."
if ![ps aux | grep -v grep | grep StdDSAPIApp] > /dev/null; then
  display_color "yellow" " It's not running... Proceeding to start the DATASYNC process."
  cd /hlfapp/DXPApp/datasync/bin/ &>>${LOG}; ./start_ds.sh &>>${LOG};
  sleep 5s
  format_and_display_jps
  check_process_status "StdDSAPIApp"
else
  display_color "red" "DATASYNC Process is running."
  format_and_display_jps
fi

print_head "Checking the status of the INQUIRY process..."
if ![ps aux | grep -v grep | grep StdInquiryAPIApp] > /dev/null; then
  display_color "yellow" " It's not running... Proceeding to start the INQUIRY process."
  cd /hlfapp/DXPApp/inquiry/bin/ &>>${LOG}; ./start_inquiry.sh &>>${LOG};
  sleep 5s
  format_and_display_jps
  check_process_status "StdInquiryAPIApp"
else
  display_color "red" "INQUIRY Process is running."
  format_and_display_jps
fi

print_head "Checking the status of the ONLINE process..."
if [ "$current_hostname" = "$action_hostname1" ]; then
    if ![[ps aux | grep -v grep | grep EnvManager] && [ps aux | grep -v grep | grep HTTPSrvrGateway] && [ps aux | grep -v grep | grep HostGateway]] > /dev/null; then
        display_color "yellow" " It's not running... Proceeding to start the ONLINE process."
        cd /hlfapp/DXPApp/online/mdynamics/bin/ &>>${LOG}; ./start.sh P1G1_MGR1 &>>${LOG};
        sleep 25s
          check_process_status "EnvManager"
          check_process_status "HTTPSrvrGateway"
          check_process_status "HostGateway"
          format_and_display_jps
    else
        display_color "red" "ONLINE Process is running."
        format_and_display_jps
    fi
elif [ "$current_hostname" = "$action_hostname2" ]; then
    if ![[ps aux | grep -v grep | grep EnvManager] && [ps aux | grep -v grep | grep HTTPSrvrGateway] && [ps aux | grep -v grep | grep HostGateway]] > /dev/null; then
        display_color "yellow" " It's not running... Proceeding to start the ONLINE process."
        cd /hlfapp/DXPApp/online/mdynamics/bin/ &>>${LOG}; ./start.sh P1G1_MGR2 &>>${LOG};
        sleep 25s
          check_process_status "EnvManager"
          check_process_status "HTTPSrvrGateway"
          check_process_status "HostGateway"
          format_and_display_jps
     else
        display_color "red" "ONLINE Process is running."
        format_and_display_jps
    fi
else
    echo "Hostname does not match any expected hostnames"
fi

print_head "Checking the status of the WSPROCESS process..."
if [ "$current_hostname" = "$action_hostname1" ]; then
    if ![ps aux | grep -v grep | grep WebSvcProcess] > /dev/null; then
        display_color "yellow" " It's not running... Proceeding to start the WSPROCESS process."
        cd /hlfapp/DXPApp/online/mdynamics/bin/ &>>${LOG}; ./startWSP.sh P1G1_WSPROCESS1 &>>${LOG};
        sleep 25s
          check_process_status "WebSvcProcess"
          format_and_display_jps
    else
        display_color "red" "WebSvcProcess Process is running. Kindly check Manullay"
        format_and_display_jps
    fi
elif [ "$current_hostname" = "$action_hostname2" ]; then
     display_color "yellow" "Not required to start WebSvcProcess, Since scripts are running in $action_hostname2"
     sleep 5s
     format_and_display_jps
else
    echo "Hostname does not match any expected hostnames"
fi

print_head "Checking the status of the BATCH process..."
if [ "$current_hostname" = "$action_hostname1" ]; then
    if ![ps aux | grep -v grep | grep StdBatchApp] > /dev/null; then
        display_color "yellow" " It's not running... Proceeding to start the BATCH process."
        cd /hlfapp/DXPApp/batch/bin/ &>>${LOG}; ./start_bp.sh &>>${LOG};
        sleep 25s
          check_process_status "StdBatchApp"
          format_and_display_jps
    else
        display_color "red" "BATCH Process is running. Kindly check Manullay"
        format_and_display_jps
    fi
elif [ "$current_hostname" = "$action_hostname2" ]; then
     display_color "yellow" "Not required to start BATCH, Since scripts are running in $action_hostname2"
     sleep 5s
     format_and_display_jps
else
    echo "Hostname does not match any expected hostnames"
fi

print_head "Checking the status of the PARTITIONSERVICE process..."
if [ "$current_hostname" = "$action_hostname1" ]; then
    if ![ps aux | grep -v grep | grep PartitionService] > /dev/null; then
        display_color "yellow" " It's not running... Proceeding to start the PARTITIONSERVICE process."
        cd /hlfapp/DXPApp/partitionservice/bin/ &>>${LOG}; ./start_ps.sh &>>${LOG};
        sleep 25s
          check_process_status "PartitionService"
          format_and_display_jps
    else
        display_color "red" "PARTITIONSERVICE Process is running. Kindly check Manullay"
        format_and_display_jps
    fi
elif [ "$current_hostname" = "$action_hostname2" ]; then
     display_color "yellow" "Not required to start PARTITIONSERVICE, Since scripts are running in $action_hostname2"
     sleep 5s
     format_and_display_jps
else
    echo "Hostname does not match any expected hostnames"
fi

}

deploy_hlfdxp(){
shutdown_hlfdxp

print_head "Procceding to take the backup of Online Module"
cd /hlfapp/DXPApp; tar -czf online_bk_${NOW}.tar.gz online;
sleep 2s
status_check
print_head "Procceding to take the backup of Inquiry Module"
cd /hlfapp/DXPApp; tar -czf inquiry_bk_${NOW}.tar.gz inquiry;
sleep 2s
status_check
print_head "Procceding to take the backup of Datasync Module"
cd /hlfapp/DXPApp; tar -czf datasync_bk_${NOW}.tar.gz datasync;
status_check
print_head "Procceding to take the backup of Auth Module"
cd /hlfapp/DXPApp; tar -czf auth_bk_${NOW}.tar.gz auth;
status_check
if [ "$current_hostname" = "$action_hostname1" ]; then
print_head "Procceding to take the backup of Batch Module"
cd /hlfapp/DXPApp; tar -czf batch_bk_${NOW}.tar.gz batch;
status_check
print_head "Procceding to take the backup of Partition Service Module"
cd /hlfapp/DXPApp; tar -czf partitionservice_bk_${NOW}.tar.gz partitionservice;
status_check
elif [ "$current_hostname" = "$action_hostname2" ]; then
    echo "Not Necessary to take back for BATCH & PARTITIONSERVICE Since scripts are running in $action_hostname2"
else
    echo "Hostname does not match any expected hostnames"
fi

print_head "MOVING BACK UP TO /hlfapp/DXPApp/Backup/${NOW} location "

print_head "Procceding to move the backup Online file to /hlfapp/DXPApp/Backup/${NOW} location"
mv /hlfapp/DXPApp/online_bk_${NOW}.tar.gz /hlfapp/DXPApp/Backup/${NOW} >>${LOG};
sleep 2s
status_check
print_head "Procceding to move the backup Inquiry file to /hlfapp/DXPApp/Backup/${NOW} location"
mv /hlfapp/DXPApp/inquiry_bk_${NOW}.tar.gz /hlfapp/DXPApp/Backup/${NOW} >>${LOG};
sleep 2s
status_check
print_head "Procceding to move the backup Datasync file to /hlfapp/DXPApp/Backup/${NOW} location"
mv /hlfapp/DXPApp/datasync_bk_${NOW}.tar.gz /hlfapp/DXPApp/Backup/${NOW} >>${LOG};
sleep 2s
status_check
print_head "Procceding to move the backup Auth file to /hlfapp/DXPApp/Backup/${NOW} location"
mv /hlfapp/DXPApp/auth_bk_${NOW}.tar.gz /hlfapp/DXPApp/Backup/${NOW} >>${LOG};
sleep 2s
status_check
if [ "$current_hostname" = "$action_hostname1" ]; then
print_head "Procceding to move the backup Batch file to /hlfapp/DXPApp/Backup/${NOW} location"
mv /hlfapp/DXPApp/batch_bk_${NOW}.tar.gz /hlfapp/DXPApp/Backup/${NOW} >>${LOG};
sleep 2s
status_check
print_head "Procceding to move the backup Batch file to /hlfapp/DXPApp/Backup/${NOW} location"
mv /hlfapp/DXPApp/partitionservice_bk_${NOW}.tar.gz /hlfapp/DXPApp/Backup/${NOW} >>${LOG};
sleep 2s
status_check
elif [ "$current_hostname" = "$action_hostname2" ]; then
    echo "Not Necessary to move backup  for BATCH & PARTITIONSERVICE Since scripts are running in $action_hostname2"
else
    echo "Hostname does not match any expected hostnames"
fi

print_head "REMOVING the origninal folder"

print_head "Procceding to take the backup of Online Module"
cd /hlfapp/DXPApp; rm -rf online >>${LOG};
sleep 2s
status_check
print_head "Procceding to take the backup of Inquiry Module"
cd /hlfapp/DXPApp; rm -rf inquiry >>${LOG};
sleep 2s
status_check
print_head "Procceding to take the backup of Datasync Module"
cd /hlfapp/DXPApp; rm -rf datasync >>${LOG};
status_check
print_head "Procceding to take the backup of Auth Module"
cd /hlfapp/DXPApp; rm -rf auth >>${LOG};
status_check
if [ "$current_hostname" = "$action_hostname1" ]; then
print_head "Procceding to take the backup of Batch Module"
cd /hlfapp/DXPApp; rm -rf batch >>${LOG};
status_check
print_head "Procceding to take the backup of Partition Service Module"
cd /hlfapp/DXPApp; rm -rf partitionservice >>${LOG};
status_check
elif [ "$current_hostname" = "$action_hostname2" ]; then
    echo "Not Necessary to take back for BATCH & PARTITIONSERVICE Since scripts are running in $action_hostname2"
else
    echo "Hostname does not match any expected hostnames"
fi

print_head "UNTAR app.tar.gz downloaded and placed into the deployment folder"
cd /hlfapp/DXPApp/Deployment; tar -xzf  app.tar.gz >>${LOG};

print_head "copying all the folders into /hlfapp/DXPApp/ "
yes | cp -rf  /hlfapp/DXPApp/Deployment/app/*  /hlfapp/DXPApp/ &>>${LOG};
sleep 5s
status_check

print_head "Procceding to remove the app folder from the deploymnet location Since deployment Done "
cd /hlfapp/DXPApp/Deployment; rm -rf app >>${LOG};
status_check

print_head "Copying old log files from /hlfapp/DXPApp/Backup/${NOW} to /hlfapp/DXPApp/auth/logfiles"
cd /hlfapp/DXPApp/Backup/${NOW}; tar -xzf auth_bk_${NOW}.tar.gz;
yes | cp -rf /hlfapp/DXPApp/Backup/${NOW}/auth/logfiles/*  /hlfapp/DXPApp/auth/logfiles/ &>>${LOG};
status_check

print_head "Copying old log files from /hlfapp/DXPApp/Backup/${NOW} to /hlfapp/DXPApp/inquiry/logfiles"
cd /hlfapp/DXPApp/Backup/${NOW}; tar -xzf inquiry_bk_${NOW}.tar.gz;
yes | cp -rf /hlfapp/DXPApp/Backup/${NOW}/inquiry/logfiles/*  /hlfapp/DXPApp/inquiry/logfiles/ &>>${LOG};
status_check

print_head "Copying old log files from /hlfapp/DXPApp/Backup/${NOW} to /hlfapp/DXPApp/datasync/logfiles"
cd /hlfapp/DXPApp/Backup/${NOW}; tar -xzf datasync_bk_${NOW}.tar.gz;
yes | cp -rf /hlfapp/DXPApp/Backup/${NOW}/datasync/logfiles/*  /hlfapp/DXPApp/datasync/logfiles/ &>>${LOG};
status_check

print_head "Copying old log files from /hlfapp/DXPApp/Backup/${NOW} to /hlfapp/DXPApp/online/mdynamics/logfiles"
cd /hlfapp/DXPApp/Backup/${NOW}; tar -xzf online_bk_${NOW}.tar.gz;
yes | cp -rf /hlfapp/DXPApp/Backup/${NOW}/online/mdynamics/logfiles/*  /hlfapp/DXPApp/online/mdynamics/logfiles/ &>>${LOG};
status_check

if [ "$current_hostname" = "$action_hostname1" ]; then
print_head "Copying old log files from /hlfapp/DXPApp/Backup/${NOW} to /hlfapp/DXPApp/batch/logfiles"
cd /hlfapp/DXPApp/Backup/${NOW}; tar -xzf batch_bk_${NOW}.tar.gz;
yes | cp -rf /hlfapp/DXPApp/Backup/${NOW}/batch/logfiles/*  /hlfapp/DXPApp/batch/logfiles/ &>>${LOG};
status_check
elif [ "$current_hostname" = "$action_hostname2" ]; then
 echo "$action_hostname2 not required batch"
else
    echo "Hostname does not match any expected hostnames"
fi

if [ "$current_hostname" = "$action_hostname1" ]; then
print_head "Copying old log files from /hlfapp/DXPApp/Backup/${NOW} to /hlfapp/DXPApp/partitionservice/logfiles"
cd /hlfapp/DXPApp/Backup/${NOW}; tar -xzf partitionservice_bk_${NOW}.tar.gz;
yes | cp -rf /hlfapp/DXPApp/Backup/${NOW}/partitionservice/logfiles/*  /hlfapp/DXPApp/partitionservice/logfiles/ &>>${LOG};
status_check
elif [ "$current_hostname" = "$action_hostname2" ]; then
    echo "$action_hostname2 not required partition Serivce"
else
    echo "Hostname does not match any expected hostnames"
fi

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
    sed -i 's/mdyn.processId=P1L1_DATASYNC1/mdyn.processId=P1L1_DATASYNC2/g' /hlfapp/DXPApp/datasync/conf/application.properties;
    sed -i 's/mdyn.processId=P1L1_INQFE1/mdyn.processId=P1L1_INQFE2/g' /hlfapp/DXPApp/inquiry/conf/application.properties;
    sed -i 's/mdyn.processId=P1L1_AUTH1/mdyn.processId=P1L1_AUTH2/g' /hlfapp/DXPApp/auth/conf/application.properties;
    echo "$action_hostname2 not applicable. Since WSPROCESS will run only in $action_hostname1 and BATCH and PARTIITON SERVICE not applicable"
else
    echo "Hostname does not match any expected hostnames"
fi

print_head "Copying old log files from /hlfapp/DXPApp/Backup/${NOW} to /hlfapp/DXPApp/batch/logfiles"
if [ "$current_hostname" = "$action_hostname1" ]; then
echo "No need change process ID Since its running in Server 2  "
elif [ "$current_hostname" = "$action_hostname2" ]; then
  echo "Changing process ID name in Instance 2 for Datasync P1L1_DATASYNC1-> P1L1_DATASYNC2, Inquiry P1L1_INQFE1-> P1L1_INQFE2, Auth P1L1_AUTH1-> P1L1_AUTH2"
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

shutdown_auth(){
print_head "Shutting Down the AUTH Service"
sleep 3s
cd /hlfapp/DXPApp/auth/bin/ &>>${LOG}; ./shutdown_auth.sh &>>${LOG};
sleep 10s
if ps aux | grep -v grep | grep StdAuthAPIApp > /dev/null; then
  echo "AUTH Process is running."
else
  echo "AUTH Process is not running."
fi
status_check
}

start_auth(){
print_head "Starting the AUTH Service"
sleep 3s
cd /hlfapp/DXPApp/auth/bin/ &>>${LOG}; ./start_auth.sh &>>${LOG};
sleep 10s
if ps aux | grep -v grep | grep StdAuthAPIApp > /dev/null; then
  echo "AUTH Process is running."
else
  echo "AUTH Process is not running."
fi
status_check
}

restart_auth(){
shutdown_auth
start_auth
}

shutdown_datasync(){
print_head "Shutting Down the DATASYNC Service"
sleep 3s
cd /hlfapp/DXPApp/datasync/bin/ &>>${LOG}; ./shutdown_ds.sh &>>${LOG};
sleep 10s
if ps aux | grep -v grep | grep StdDSAPIApp > /dev/null; then
  echo "DATASYNC Process is running."
else
  echo "DATASYNC Process is not running."
fi
status_check
}

start_datasync(){
print_head "Starting the DATASYNC Service"
sleep 3s
cd /hlfapp/DXPApp/datasync/bin/ &>>${LOG}; ./start_ds.sh &>>${LOG};
sleep 10s
if ps aux | grep -v grep | grep StdDSAPIApp > /dev/null; then
  echo "DATASYNC Process is running."
else
  echo "DATASYNC Process is not running."
fi
status_check
}

restart_datasync(){
shutdown_datasync
start_datasync
}


start_inquiry(){
print_head "Starting the INQUIRY Service"
sleep 3s
cd /hlfapp/DXPApp/inquiry/bin/ &>>${LOG}; ./start_inquiry.sh &>>${LOG};
sleep 10s
if ps aux | grep -v grep | grep StdInquiryAPIApp > /dev/null; then
  echo "INQUIRY Process is running."
else
  echo "INQUIRY Process is not running."
fi
status_check
}

shutdown_inquiry(){
print_head "Shutting Down the INQUIRY Service"
sleep 3s
cd /hlfapp/DXPApp/inquiry/bin/ &>>${LOG}; ./shutdown_inquiry.sh &>>${LOG};
sleep 10s
if ps aux | grep -v grep | grep  StdInquiryAPIApp > /dev/null; then
  echo "INQUIRY Process is running."
else
  echo "INQUIRY Process is not running."
fi
}

restart_inquiry(){
  shutdown_inquiry
  start_inquiry
}

start_online(){
print_head "Starting the ONLINE Service"
sleep 3s
cd /hlfapp/DXPApp/online/mdynamics/bin/ &>>${LOG}; ./start.sh P1G1_MGR1 &>>${LOG};
sleep 10s
if ps aux | grep -v grep | grep EnvManager > /dev/null; then
  echo "ONLINE Process is running."
else
  echo "ONLINE Process is not running."
fi
status_check
}

shutdown_online(){
print_head "Shutting Down the ONLINE Service"
sleep 3s
cd /hlfapp/DXPApp/online/mdynamics/bin/ &>>${LOG}; ./stop.sh &>>${LOG};
sleep 10s
if ps aux | grep -v grep | grep  EnvManager > /dev/null; then
  echo "ONLINE Process is running."
else
  echo "ONLINE Process is not running."
fi
status_check
}

restart_online(){
  shutdown_online
  start_online
}

shutdown_batch(){
print_head "Shutting Down the BATCH Service"
sleep 3s
cd /hlfapp/DXPApp/batch/bin/ &>>${LOG}; ./shutdown_bp.sh &>>${LOG};
sleep 10s
if ps aux | grep -v grep | grep StdBatchApp > /dev/null; then
  echo "BATCH Process is running."
else
  echo "BATCH Process is not running."
fi
status_check
}


start_batch(){
print_head "Starting the BATCH Service"
sleep 3s
cd /hlfapp/DXPApp/batch/bin/ &>>${LOG}; ./start_bp.sh &>>${LOG};
sleep 10s
if ps aux | grep -v grep | grep StdBatchApp > /dev/null; then
  echo "BATCH Process is running."
else
  echo "BATCH Process is not running."
fi
status_check
}

restart_batch(){
  shutdown_batch
  start_batch
}


shutdown_partitionservice(){
print_head "Shutting Down the PARTITION Service"
sleep 3s
cd /hlfapp/DXPApp/partitionservice/bin/ &>>${LOG}; ./shutdown_ps.sh &>>${LOG};
sleep 10
if ps aux | grep -v grep | grep PartitionService > /dev/null; then
  echo "PARTITIONSERVICE Process is running."
else
  echo "PARTITIONSERVICE Process is not running."
fi
print_head "****HLF-DXP Services are Down Now."
}

start_partitionservice(){
print_head "Starting the PARTITION Service"
sleep 3s
cd /hlfapp/DXPApp/partitionservice/bin/ &>>${LOG}; ./start_ps.sh &>>${LOG};
sleep 10s
if ps aux | grep -v grep | grep PartitionService > /dev/null; then
  echo "PARTITIONSERVICE Process is running."
else
  echo "PARTITIONSERVICE Process is not running."
fi
status_check
}

restart_partitionservice(){
  shutdown_partitionservice
  start_partitionservice
}


# Loop until the user chooses to quit
#!/bin/bash

#!/bin/bash
function inner_select() {
    local choice="$1"  # The choice passed from the outer select
    case "$choice" in
        Deploy)
		 while true; do
            select sub_option in DEPLOY_HLFDXP backToParentMenu; do
			#select sub_option in AUTH BATCH DATASYNC INQUIRY ONLINE PARTITIONSERVICE DEPLOYALL backToCurrentMenu backToParentMenu; do
			 mkdir -p /hlfapp/DXPApp/Backup/${NOW}
                case "$sub_option" in
					DEPLOY_HLFDXP)
					    print_head "Input received from user to Deploy HLF-DXP Service(s)"
						deploy_hlfdxp
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
            select sub_option in AUTH BATCH DATASYNC INQUIRY ONLINE PARTITIONSERVICE SHUTDOWNALL backToCurrentMenu backToParentMenu; do
                case "$sub_option" in
                    AUTH)
                        print_process_status "Input received from user to SHUTDOWN HLF-DXP AUTH Service"
						shutdown_auth
                        ;;
                    BATCH)
					print_process_status "Input received from user to SHUTDOWN HLF-DXP BATCH Service"
					  if [ "$current_hostname" = "$action_hostname1" ]; then
					    shutdown_batch
                      elif [ "$current_hostname" = "$action_hostname2" ]; then
                          echo "In HLF-DXP BATCH does not run in $action_hostname2 will run only $action_hostname1"
                    else
                      echo "Hostname does not match any expected hostnames"
                     fi  
                        ;;
					DATASYNC)
                       print_process_status "Input received from user to SHUTDOWN HLF-DXP DATASYNC Service"
					   shutdown_datasync
                        ;;
					INQUIRY)
                        print_process_status "Input received from user to SHUTDOWN HLF-DXP INQUIRY Service"
						shutdown_inquiry
                        ;;
					ONLINE)
                        print_process_status "Input received from user to SHUTDOWN HLF-DXP ONLINE Service"
						shutdown_online
                        ;;				
					PARTITIONSERVICE)
					 print_process_status "Input received from user to SHUTDOWN HLF-DXP PARTITIONSERVICE Service"
					  if [ "$current_hostname" = "$action_hostname1" ]; then
					   shutdown_partitionservice
                      elif [ "$current_hostname" = "$action_hostname2" ]; then
                          echo "In HLF-DXP PARTITIONSERVICE does not run in $action_hostname2 will run only $action_hostname1"
                      else
                          echo "Hostname does not match any expected hostnames"
                     fi  
                        ;;
					SHUTDOWNALL)
                        print_process_status "Input received from user to SHUTDOWN HLF-DXP Service(s)"
						shutdown_hlfdxp
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
            select sub_option in AUTH BATCH DATASYNC INQUIRY ONLINE PARTITIONSERVICE STARTALL backToCurrentMenu backToParentMenu; do
                case "$sub_option" in
                    AUTH)
                        print_process_status "Input received from user to start HLF-DXP AUTH Serivce"
						start_auth
                        ;;
                    BATCH)
					print_process_status "Input received from user to start HLF-DXP BATCH Service"
					  if [ "$current_hostname" = "$action_hostname1" ]; then
					    start_batch
                      elif [ "$current_hostname" = "$action_hostname2" ]; then
                          echo "In HLF-DXP BATCH does not run in $action_hostname2 will run only $action_hostname1"
                    else
                      echo "Hostname does not match any expected hostnames"
                     fi  
                        ;;
					DATASYNC)
                       print_process_status "Input received from user to start HLF-DXP DATASYNC Serivce"
					   start_datasync
                        ;;
					INQUIRY)
                        print_process_status "Input received from user to start HLF-DXP INQUIRY Serivce"
						start_inquiry
                        ;;
					ONLINE)
                        print_process_status "Input received from user to start HLF-DXP ONLINE Serivce"
						start_online
                        ;;
					PARTITIONSERVICE)
					 print_process_status "Input received from user to start HLF-DXP PARTITIONSERVICE Serivce"
					  if [ "$current_hostname" = "$action_hostname1" ]; then
					   start_partitionservice
                      elif [ "$current_hostname" = "$action_hostname2" ]; then
                          echo "In HLF-DXP PARTITIONSERVICE does not run in $action_hostname2 will run only $action_hostname1"
                      else
                          echo "Hostname does not match any expected hostnames"
                     fi  
                        ;;
					STARTALL)
                        print_process_status "Input received from user to start HLF-DXP Serivce(s)"
						start_hlfdxp
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
            select sub_option in AUTH BATCH DATASYNC INQUIRY ONLINE PARTITIONSERVICE RESTARTALL backToCurrentMenu backToParentMenu; do
                case "$sub_option" in
                    AUTH)
                        print_process_status "Input received from user to restart HLF-DXP AUTH Service"
						restart_auth
                        ;;
                    BATCH)
					print_process_status "Input received from user to restart HLF-DXP BATCH Service"
					  if [ "$current_hostname" = "$action_hostname1" ]; then
					    restart_batch
                      elif [ "$current_hostname" = "$action_hostname2" ]; then
                          echo "In HLF-DXP BATCH does not run in $action_hostname2 will run only $action_hostname1"
                    else
                      echo "Hostname does not match any expected hostnames"
                     fi  
                        ;;
					DATASYNC)
                        print_process_status "Input received from user to restart HLF-DXP DATASYNC Service"
						 restart_datasync
                        ;;
					INQUIRY)
                        print_process_status "Input received from user to restart HLF-DXP INQUIRY Service"
						restart_inquiry
                        ;;
					ONLINE)
                        print_process_status "Input received from user to restart HLF-DXP ONLINE Service"
						restart_online
                        ;;
					PARTITIONSERVICE)
					print_process_status "Input received from user to restart HLF-DXP PARTITIONSERVICE Service"
					  if [ "$current_hostname" = "$action_hostname1" ]; then
					    restart_partitionservice
                      elif [ "$current_hostname" = "$action_hostname2" ]; then
                          echo "In HLF-DXP PARTITIONSERVICE does not run in $action_hostname2 will run only $action_hostname1"
                    else
                      echo "Hostname does not match any expected hostnames"
                     fi  
                        ;;
					RESTARTALL)
                        print_process_status "Input received from user to restart HLF-DXP Service(s)"
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
