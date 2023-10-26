
#SIT
. ./setenv.sh
nohup ./standalone.sh -Djboss.socket.binding.port-offset=2 -b 0.0.0.0 &


#VIT/UAT
. ./setenv.sh
nohup ./standalone.sh -b 0.0.0.0 &
