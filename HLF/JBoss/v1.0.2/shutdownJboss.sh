
#!/bin/bash

# Set the path to the JBoss bin directory
JBOSS_BIN_DIR="/hlfapp/JBossEAP-7.4/bin"

# Connect to the server and issue the shutdown command
$JBOSS_BIN_DIR/jboss-cli.sh --connect --controller=localhost:9990