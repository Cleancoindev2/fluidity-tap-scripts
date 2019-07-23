NOTE: WORK IN PROGRESS - NOT COMPLETE


This document contains a consolidation of scripts to interact with the MCD system with a custom collateral type. It assumes familiarily with dapp tools and the installation for now. More details will be added.


```bash
export MCD_CONFIG=~/testchain/out/addresses-mcd.json
export SCD_CONFIG=~/testchain/out/addresses.json
```

## Deploying to Testchain

Step 1.
git clone `https://github.com/makerdao/test-chain`

`cd test-chain`

Run `scripts/launch`

That will create a Ganache instance running at localhost:2000. In addition, all deployed addresses are stored in the `test-chain/out/*.json file`.


Step 2.
Build the ERC20 token and deploy contract address

```bash
./bin/deploy-col-tea
export COLT_CONFIG=~/col-tea-scripts/out/addressesColtT.json
```
Step 3.
Incorporates the collateral type into the testchain

```bash
./bin/deploy-spell
```
Step 4.
Mint tokens for ColTea by ETH_FROM

```bash
./bin/mint-col-tea
```
_______________________________________________

## Interacting with MCD
(requires that MCD can take custom ILKs if not need to write the underlying SETH commands)

1. Convert all of the USDT to the USDT Adapter

```bash
./bin/join-col-t
```

sig="gem(bytes32,address)(uint256)"
$(seth call ${MCD_VAT?} "$sig" "$ILK" "$urn")

there shouldn't be tokens in the CDP engine yet

2. Ensure that a spot price is set. Additional steps for updating prices are available in the bottom section "Interacting with the Price Feed".

```bash
./bin/poke-pip-col-t
```

2. Lock the USDT Adapter tokens not into the VAT and withdraw X dai. X dai < less than collateralization ratio set up

dink2=$(seth --to-uint256 $(seth --to-hex $wad))

dart3=$(seth --to-uint256 '0x9c40')
sig="frob(bytes32, address, address, address, int, int)"
seth send ${MCD_VAT} "$sig" "$ILK" "$urn" "$urn" "$urn" "$dink2" "$dart3"

seth send ${MCD_VAT} "$sig" "$ILK" "$urn" "$urn" "$urn" "$dink2" "$dart3" this failed not sure why yet though

3.  Remove the X dai and place it into your account. At this point the USDT is locked in MCD system and your external wallet will have Dai

mcd dai exit X

approval to move Dai from the vat

otherwise works pretty simple

wad=$(seth --to-word $(seth --to-wei $1 eth))
sig="exit(address usr, uint256 wad)"
seth send $MCD_JOIN_DAI "$sig" $usr $wad

4. When you're ready to close the CDP. Send the Dai back by calling join.

mcd dai join X

need to approve $MCD_JOIN_DAI to transfer dai on your behalf

Now just call Dai

urn=$(mcd --get-urn dai)
wad=$(seth --to-uint256 $(seth --to-wei $1 eth))
seth send "$MCD_JOIN_DAI" "join(address, uint)" $urn $wad

5. Withdraw the collateral with the negative value. You're inserting X Dai and now withdrawing
the USDT. It's still in the adapter format.

mcd --ilk=USDT frob -- -60 -X

seth --to-int256 $(seth --to-dec )

dink2=$(seth --to-uint256 $(seth --to-hex $wad))

Art is the dai amount
dartReturn=$(seth --to-int256 -$(seth --to-dec 0000000000000000000000000000000000000000000000000000000010000001))

dinkReturn=$(seth --to-int256 -$(seth --to-dec 000000000000000000000000000000000000000000000000001ff973cafa7fff))

retrun back should be negative values

dart3=$(seth --to-uint256 '0x9c40')
sig="frob(bytes32, address, address, address, int, int)"
seth send ${MCD_VAT} "$sig" "$ILK" "$urn" "$urn" "$urn" "$dink2" "$dart3"

sig="frob(bytes32, address, address, address, int, int)"
seth send ${MCD_VAT} "$sig" "$ILK" "$urn" "$urn" "$urn" "$dinkReturn" "$dartReturn"

6. Finally, remove your collateral USDT token from the USDT adapter.

mcd --ilk=USDT gem exit 60

usr=$(mcd --get-from gem)

wad=$(seth --to-word $(seth --to-wei $1 eth))
sig="exit(address, uint)"
seth send $JOIN "$sig" "$urn" 000000000000000000000000000000000000000000000000003ff2e795f4fffe

[[ $SETH_ASYNC != yes ]] && mcd gem balance

7. ERC20 should now be in the wallet

seth send "$MCD_GOV" 'approve(address,uint256)' "$MCD_ADM" $(seth --to-uint256 1)
seth send "$MCD_ADM" 'lock(uint256)' (seth --to-uint256 1)
seth send "$MCD_ADM" 'vote(address[] memory)' ["${SPELL#0x}"]
seth send "$MCD_ADM" 'lift(address)' "$SPELL"

8. Burn the ERC20 tokens on selling the real world asset.

seth send $USDT 'burn(address,uint256)(bool)' $ETH_FROM 100000
 seth send $TOKEN 'burn(uint256)' $(seth --to-uint256 5000)

-----------------------------------------------------------------------------

## Interacting with the Price Feed

In the first part when deploying col-tea, there is a PIP_USDT contract deployed. This contract can take in prices.

can just call this on the PIP_USDT file need to determine what the actualy number of zeros need to be...


seth send $PIP 'poke(bytes32)' "$ilk" $(seth --to-uint256 99541222)

seth send $PIP_OMG 'poke(bytes32)' '12o3c33323423400000000000000000000000000000000000000000000000000' -> this works

Checks that the price has been updated
seth call $PIP_OMG 'read()(bytes32)'

The Spotter is what gets updated and then files this prie to the VAT ie CDP engine

seth send $MCD_SPOT 'poke(bytes32)' "$ilk"


seth send $PIP_USDT 'poke(bytes32)'


seth send $PIP_USDT 'poke(bytes32)' '12o3c33323423400000000000000000000000000000000000000000000000000'
