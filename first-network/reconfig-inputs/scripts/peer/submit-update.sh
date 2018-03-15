#!/bin/bash

# Set defaults if not overridden
ORDERER_TLS_CA=${ORDERER_TLS_CA:-/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem}
ORDERER_ADDRESS=${ORDERER_ADDRESS:-orderer.example.com:7050}
CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID:-Org1MSP}
CORE_PEER_MSPCONFIGDIR=${CORE_PEER_MSPCONFIGDIR:-/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp}
CHANNEL_ID=${CHANNEL_ID:-mychannel}
RECONFIG_DIRECTORY=${RECONFIG_DIRECTORY:-/opt/reconfig-inputs}

OUTPUTS="${RECONFIG_DIRECTORY}/outputs"

#set -x
set -e

peer channel update -o ${ORDERER_ADDRESS} -c "${CHANNEL_ID}" -f ${OUTPUTS}/config_update_in_envelope.pb --tls true --cafile "${ORDERER_TLS_CA}"
