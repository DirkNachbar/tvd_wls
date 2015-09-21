#!/bin/bash
#================================================================
#
# Author: Dirk Nachbar, Trivadis AD, Bern Switzerland
#
# Purpose: Starting up the Node Manager and create a Machine
#          within the Admin Server
#
#================================================================

# Add Dweblogic.security.SSL.ignoreHostnameVerification=true to JVM Args
CONFIG_JVM_ARGS="${CONFIG_JVM_ARGS} -Dweblogic.security.SSL.ignoreHostnameVerification=true"
# reference wlst command with skipWLSModuleScanning
WLST_SKIP="wlst.sh -skipWLSModuleScanning"

# Startup the Node Manager
nohup startNodeManager.sh > log.nm &
# Sleep for 15 seconds in order to allow the Node Manager to be up and running
sleep 15

# Add a Machine to the AdminServer by calling add-machine.py script
$WLST_SKIP /u00/oracle/add-machine.py

