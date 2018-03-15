#!/bin/bash

#######################################################################
#                                                                     #
# This script provides an example of adding a new CA and intermediate #
# CA to an existing MSP definition.  It assumes that there is a       #
# volume mounted at /opt/reconfig-inputs which maps to the directory  #
# of the same name in this folder (thought this may be overridden).   #
# The config is modified to add each certificate in the folder        #
# reconfig-inputs/certs/rootcerts to the root_certs of the target     #
# organization.  The config is also modified to add each certificate  #
# in the folder reconfig-inputs/certs/interemdiatecerts to the        #
# intermediate_certs for that org.                                    #
#                                                                     #
# All commands are executed relative to the CLI container, but the    #
# exec commands referencing the 'peer' folder contain only commands   #
# using the 'peer' binary, while the execs referencing the            #
# 'configtxlator' folder utilize only the jq and configtxlator        #
# commands.  Please map these to appropriate containers for your      #
# environment.                                                        #
#                                                                     #
# Note, there is no requirement that the containers persist between   #
# the execs, so an appropriate docker run command would work as well. #
# The execs were used because it is a convenient way to bind into a   #
# docker-compose network.                                             #
#                                                                     #
# For peer commands you must override the variables:                  #
#                                                                     #
#    CORE_PEER_LOCALMSPID                                             #
#    CORE_PEER_MSPCONFIGDIR (must contain org admin's cert)           #
#    ORDERER_ADDRESS                                                  #
#    ORDERER_TLS_CA                                                   #
#    CHANNEL_ID                                                       #
#    RECONFIG_DIRECTORY (defaults to /opt/reconfig-inputs)            #
#                                                                     #
#    You may also need to override other variables for HSM            #
#                                                                     #
# For configtxlator commands you must override the variables:         #
#                                                                     #
#    TARGET_ORG (Note, this is the org name, not the MSP ID though    #
#                they may be the same depening on your config)        #
#    CHANNEL_ID                                                       #
#    RECONFIG_DIRECTORY (defaults to /opt/reconfig-inputs)            #
#                                                                     #
#######################################################################
echo Y | ./byfn.sh -m down
echo Y | ./byfn.sh -m up -i 1.1.0-rc1

set -e

# Get the current config
docker exec cli /opt/reconfig-inputs/scripts/peer/fetch-config.sh

# Perform the config update computation
docker exec cli /opt/reconfig-inputs/scripts/configtxlator/compute-update.sh

# Submit the update
docker exec cli /opt/reconfig-inputs/scripts/peer/submit-update.sh
