#!/bin/bash

#set -x
set -e
set -o pipefail

TARGET_ORG=${TARGET_ORG:-Org1MSP}
CHANNEL_ID=${CHANNEL_ID:-mychannel}
RECONFIG_DIRECTORY=${RECONFIG_DIRECTORY:-/opt/reconfig-inputs}
OUTPUTS_DIRECTORY="${RECONFIG_DIRECTORY}/outputs"

# Install jq as a prereq
apt-get update && apt-get install -y jq moreutils

cd "${OUTPUTS_DIRECTORY}"

# Decode the config
configtxlator proto_decode --type common.Block --input config_block.pb | jq .data.data[0].payload.data.config > original_config.json

cp original_config.json modified_config.json

# Modify the config by adding any root certs found in the cacerts dir
for ROOT_CERT in ${RECONFIG_DIRECTORY}/certs/cacerts/* ; do
  ROOT_CERT_B64=$(cat $ROOT_CERT | base64)
  jq ".channel_group.groups.Application.groups.${TARGET_ORG}.values.MSP.value.config.root_certs += [\"${ROOT_CERT_B64}\"] " modified_config.json | sponge modified_config.json
done

# Modify the config by adding any intermediate certs found in the intermediatecerts dir
for INTERMEDIATE_CERT in ${RECONFIG_DIRECTORY}/certs/intermediatecerts/* ; do
  INTERMEDIATE_CERT_B64=$(cat $INTERMEDIATE_CERT | base64)
  jq ".channel_group.groups.Application.groups.${TARGET_ORG}.values.MSP.value.config.intermediate_certs += [\"${INTERMEDIATE_CERT_B64}\"] " modified_config.json | sponge modified_config.json
done

# Compute the config update
configtxlator proto_encode --input original_config.json --type common.Config --output original_config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id "${CHANNEL_ID}" --original original_config.pb --updated modified_config.pb --output config_update.pb
configtxlator proto_decode --input config_update.pb  --type common.ConfigUpdate --output config_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL_ID'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . > config_update_in_envelope.json
configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output config_update_in_envelope.pb
