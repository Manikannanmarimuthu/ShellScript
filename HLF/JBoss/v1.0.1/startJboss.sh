
#!/bin/bash
 export cloud_param_path=/$PORTFOLIO/$ENVIRONMENT/

 environment=$ENVIRONMENT

 . ./setenv.sh

# Check the environment condition
if [ "$environment" = "sit" ]; then
    nohup ./standalone.sh -Djboss.socket.binding.port-offset=2 -b 0.0.0.0 &
else
    nohup ./standalone.sh -b 0.0.0.0 &
fi