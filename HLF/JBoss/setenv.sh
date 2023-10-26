#!/bin/bash

export cloud_enabled=Y
export cloud_region=ap-southeast-1
export cloud_param_path=/$PORTFOLIO/$ENVIRONMENT/
export cloud_sm_ttl=0
export cloud_ps_ttl=0
export cloud_param_reload=N

echo "cloud_enabled= $cloud_enabled"
echo "cloud_region= $cloud_region"
echo "cloud_param_path= $cloud_param_path"
echo "cloud_sm_ttl= $cloud_sm_ttl"
echo "cloud_ps_ttl= $cloud_ps_ttl"
echo "cloud_param_reload= $cloud_param_reload"

if [ $cloud_enabled = "Y" ]
then
echo "Colud is enabled"
./cloud_download.sh
else
echo "Colud is not enabled"
fi