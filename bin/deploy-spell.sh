#!/usr/bin/env bash

# Do the steps for add new token via the Dss Add Ilk Spell and not fuck up the GemJoin decimals

# Make sure all the env variables have been correctly extracted from the out directory of testchain
config-init-scd() {
  path=${SCD_CONFIG:-$1}
  if [[ ! -e "$path" ]]; then
    echo "Config file not found: $path not found"
    exit 1
  fi
  exports=$(cat $path | jq -r ".deploy_data // . | \
    to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]")
  for e in $exports; do export "$e"; done
}

config-init-mcd() {
  path=${MCD_CONFIG:-$1}
  if [[ ! -e "$path" ]]; then
    echo "Config file not found: $path not found"
    exit 1
  fi
  exports=$(cat $path | jq -r ".deploy_data // . | \
    to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]")
  for e in $exports; do export "$e"; done
}

config-init-colt() {
  path=${COLT_CONFIG:-$1}
  if [[ ! -e "$path" ]]; then
    echo "Config file not found: $path not found"
    exit 1
  fi
  echo ${COLT_CONFIG}
  exports=$(cat $path | jq -r ".deploy_data // . | \
    to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]")
  for e in $exports; do export "$e"; done
}

config-init-scd
config-init-mcd # how to run scripts in bash if you're incompetant like moi
config-init-colt

export ILK=$NAME
export urn=$ETH_FROM
echo $NAME
echo $PIP
echo $MCD_VAT
echo $USDT
echo $DECIMALS
echo $MCD_VAT
echo $ILK
echo $TOKEN
echo $DECIMALS

# 2) Deploy Adapter (e.g. [GemJoin](https://github.com/makerdao/dss/blob/master/src/join.sol))

cp -r ~/Documents/Git/MCDPResearch/secondAttempp/dss-add-ilk-spell/out/* ~/Documents/Git/TBillProject/col-tea-scripts/out/
# Make sure decimals match what was coming from the deployed token
# decimals=(seth call $USDT "decimals()")
export JOIN=$(dapp create GemJoin3 "$MCD_VAT" "$ILK" "$TOKEN" $DECIMALS)
echo "JOIN is ${JOIN} "

# TODO need to append correctly
# tmp=$(mktemp)
# jq '.JOIN="${JOIN}"' $COLT_CONFIG > "$tmp" && mv "$tmp" $COLT_CONFIG

# # 3) Deploy Flip Auction and set permissions (e.g. [Flipper](https://github.com/makerdao/dss/blob/master/src/flip.sol))

export FLIP=$(dapp create Flipper "$MCD_VAT" "$ILK")
seth send "$FLIP" 'rely(address)' "$MCD_PAUSE_PROXY"
seth send "$FLIP" 'deny(address)' "$ETH_FROM"

# # 4) Export New Collateral Type variables
export LINE="$(seth --to-uint256 $(echo "5000000"*10^45 | bc))" # debt ceiling #5M DAI
export MAT="$(seth --to-uint256 $(echo "150"*10^25 | bc))" # liquidation ratio 150%
export DUTY="$(seth --to-uint256 1000000000315522921573372069)"  # stability fee value 1% yearly
export CHOP="$(seth --to-uint256 $(echo "110"*10^25 | bc))" # Liquidation penalty of 10%
export LUMP="$(seth --to-uint256 $(echo "1000"*10^18 | bc))" # liquidation quantity value


# # 5) Deploy Spell

export SPELL=$(seth send --create out/DssAddIlkSpell.bin 'DssAddIlkSpell(bytes32,address,address[8] memory,uint256[5] memory)' $ILK $MCD_PAUSE ["${MCD_VAT#0x}","${MCD_CAT#0x}","${MCD_JUG#0x}","${MCD_SPOT#0x}","${MCD_END#0x}","${JOIN#0x}","${PIP#0x}","${FLIP#0x}"] ["$LINE","$MAT","$DUTY","$CHOP","$LUMP"])

# # 6) Create slate

seth send "$MCD_ADM" 'etch(address[] memory)' ["${SPELL#0x}"]

# # 7) Wait for the Spell to be elected

seth send "$MCD_GOV" 'approve(address,uint256)' "$MCD_ADM" $(seth --to-uint256 1)
seth send "$MCD_ADM" 'lock(uint256)' $(seth --to-uint256 1)
seth send "$MCD_ADM" 'vote(address[] memory)' ["${SPELL#0x}"]
seth send "$MCD_ADM" 'lift(address)' "$SPELL"

# # 8) Schedule Spell

seth send "$SPELL" 'schedule()'

# # 9) Wait for Pause delay
# # Default is 0 so no behavior really needs to be done on testnet
# #10) Cast Spell

seth send "$SPELL" 'cast()'

# # Confirm that ILK has been added by querying the ILK

seth call ${MCD_VAT?} 'ilks(bytes32)(uint256, uint256, uint256, uint256)' $ILK

echo "Successfully deploy COL-T into ${MCD_VAT} with name ${ILK}"