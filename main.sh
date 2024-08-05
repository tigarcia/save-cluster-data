#!/usr/bin/env bash


# Getting current epoch
# TODO: Making this a parameter
TESTNET_RPC=""

# TODO: Making this data dir a parameter
DATA_DIR=""

# TODO: Make this a parameter
VALIDATORS_APP_KEY=""

EPOCH=$(solana --url $TESTNET_RPC epoch-info | grep Epoch: | awk '{print $2}')
DATE_AND_TIME=$(date -u +"%Y-%m-%dT%H-%M")
EPOCH_INFO_FILENAME="${DATA_DIR}/testnet-epoch-${EPOCH}-info-${DATE_AND_TIME}.json"
solana --url $TESTNET_RPC epoch-info --output json-compact > $EPOCH_INFO_FILENAME
LAST_EPOCH=$((EPOCH-1))



# Info about the epoch and the run
echo "Epoch: $EPOCH"
echo "Date and time: $DATE_AND_TIME"


# Validators.app file 
echo "Saving Validator App Data"
VALIDATOR_APP_FILE="${DATA_DIR}/validators-app-data-epoch-$EPOCH-${DATE_AND_TIME}.json"
curl -X GET "https://www.validators.app/api/v1/validators/testnet.json?order=stake" \
    -s \
    -H "Token: $VALIDATORS_APP_KEY" \
    -H "Accept: application/json" > $VALIDATOR_APP_FILE


# solana validators
echo "Getting solana -ut validators"
TESTNET_VALIDATORS_FILENAME="${DATA_DIR}/testnet-validators-epoch-${EPOCH}-${DATE_AND_TIME}.json"
solana --url $TESTNET_RPC validators --keep-unstaked-delinquents \
    --output json-compact > ${TESTNET_VALIDATORS_FILENAME}


# solana gossip
echo "Getting solana -um gossip"
TESTNET_GOSSIP_FILENAME="${DATA_DIR}/testnet-gossip-epoch-${EPOCH}-${DATE_AND_TIME}.json"
solana --url $TESTNET_RPC gossip --output json-compact > $TESTNET_GOSSIP_FILENAME


# leader schedule
echo "Getting solana -um leader-schedule"
LEADER_FILE="${DATA_DIR}/testnet-leader-schedule-epoch-${EPOCH}.json"
LEADER_FILE_GZ=${LEADER_FILE}.gz
if [ -f "$LEADER_FILE_GZ" ]; then
    echo "File $LEADER_FILE_GZ already exists. Nothing to do"
else
    solana --url $TESTNET_RPC leader-schedule --epoch $EPOCH --output json-compact > $LEADER_FILE
fi


# block proudction
echo "Getting solana -ut block-production epoch $LAST_EPOCH"
BLOCK_PRODUCTION_FILE="${DATA_DIR}/testnet-block-production-epoch-${LAST_EPOCH}.json"
BLOCK_PRODUCTION_FILE_GZ="${BLOCK_PRODUCTION_FILE}.gz"
if [ -f "$BLOCK_PRODUCTION_FILE_GZ" ]; then
    echo "File $BLOCK_PRODUCTION_FILE_GZ already exists. Nothing to do"
else
    solana --url $TESTNET_RPC block-production --epoch $LAST_EPOCH --output json-compact > $BLOCK_PRODUCTION_FILE
fi


# Stakes
echo "Getting solana -ut stakes $EPOCH"
STAKES_FILE="${DATA_DIR}/testnet-stakes-epoch-${EPOCH}-${DATE_AND_TIME}.json"
solana --url $TESTNET_RPC stakes --output json-compact > $STAKES_FILE


# Gzip all json files
echo "Gzip all json files"
gzip ${DATA_DIR}/*.json
