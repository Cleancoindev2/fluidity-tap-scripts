NOTE: WORK IN PROGRESS - NOT COMPLETE


This document contains a consolidation of scripts to interact with the MCD system with a custom collateral type. It assumes familiarily with dapp tools and the installation for now. More details will be added.

Scripts for deploying Col-Tea

git clone https://github.com/makerdao/dss-deploy-scripts

cd dss-deploy-scripts

## Deploying to Testchain

Step 1.
git clone `https://github.com/makerdao/test-chain`

`cd test-chain`

`scripts/launch`

That will create a Ganache instance running at localhost:2000. In addition, all deployed addresses are stored in the test-chain/out/*.json file.


Step 2.
Build ColTea


Build the contracts first:
    dapp --use solc:0.5.10 build --extract

Step 3.
Deploy ColTea

USDT=$(seth send --create out/ColTea.bin 'ColTea(string memory ,string memory,uint8,bytes9,uint256,uint256,address,uint256)' "TOKEN" "T" 5 0x393132373934534c34 1 1 0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef 2)

Check name of token

seth call USDT "name()"
seth call USDT "totalSupply()"

seth call $USDT "balanceOf(address)(uint256)" $ETH_FROM

Step 4.
Mint tokesn for ColTea by ETH_FROM
seth send $TOKEN 'mint(address,uint256)' $ETH_FROM $(seth --to-uint256 5000)

Step 4.

`bin/deploy-col-tea`

Step 5.
Follow 10 steps from
https://github.com/makerdao/dss-add-ilk-spell


Step 6.
Make some call to ensure that this ilk is recognized
_______________________________________________

Interacting with MCD (requires that MCD can take custom ILKs if not need to write the underlying SETH commands)

1. Convert some of the USDT to the USDT Adapter

mcd --ilk=USDT gem join 60

2. Lock the USDT Adapter tokens not into the VAT and withdraw X dai. X dai < less than collateralization ratio set up

mcd --ilk=COL1-A frob 60 X

3.  Remove the X dai and place it into your account. At this point the USDT is locked in MCD system and your external wallet will have Dai

mcd dai exit X

4. When you're ready to close the CDP. Send the Dai back by calling join.

mcd dai join X

5. Withdraw the collateral with the negative value. You're inserting X Dai and now withdrawing
the USDT. It's still in the adapter format.

mcd --ilk=USDT frob -- -60 -X

6. Finally, remove your collateral USDT token from the USDT adapter.

mcd --ilk=USDT gem exit 60


7. ERC20 should now be in the wallet

8. Burn the ERC20 tokens on selling the real world asset.

seth send $USDT 'burn(address,uint256)(bool)' $ETH_FROM 100000
 seth send $TOKEN 'burn(uint256)' $(seth --to-uint256 5000)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Interacting with the Price Feed

In the first part when deploying col-tea, there is a PIP_USDT contract deployed. This contract can take in prices.

can just call this on the PIP_USDT file need to determine what the actualy number of zeros need to be...


seth send $PIP_USDT 'poke(bytes32)' $(seth --to-uint256 99583)

seth send $PIP_OMG 'poke(bytes32)' '12o3c33323423400000000000000000000000000000000000000000000000000' -> this works

Checks that the price has been updated
seth call $PIP_OMG 'read()(bytes32)'

The Spotter is what gets updated and then files this prie to the VAT ie CDP engine

seth send $MCD_SPOT 'poke(bytes32)' "$ilk"


