# Fluidity TAP Scripts: Interacting with MCD
[Fluidity Tokenized Asset Portfolio (TAP)](https://tap.fluidity.io/) is a model to obtain leverage on real world assets using the MakerDAO Multi-Collateral Dai (MCD) credit system. This repository contains scripts to use MCD with a custom collateral type. It assumes familiarity with dapp tools and installations and is a work in progress.

More information on the MakerDAO MCD terminology can be found: https://github.com/makerdao/developerguides/blob/master/mcd/mcd-101/mcd-101.md
More information on the dapp.tools can be found: https://dapp.tools/

Specifically that a .sethrc file should contain

```bash
export ETH_FROM=0x
export ETH_KEYSTORE=path/secret/keystore
export ETH_PASSWORD=path/secret/secretpassword
export ETH_RPC_URL=http://localhost:8545
export ETH_GAS=7000000
```

## Deploying to MakerDAO Testchain


### Step 1. Clone and run

```bash
git clone https://github.com/makerdao/testchain
cd testchain
scripts/launch
export MCD_CONFIG=~/testchain/out/addresses-mcd.json
export SCD_CONFIG=~/testchain/out/addresses.json
```

This runs a Ganache instance at http://localhost:2000. All deployed addresses are stored in the `testchain/out/*.json file`.

### Step 2. Build and deploy the token

```bash
./bin/deploy-fluidity-tap
export COLT_CONFIG=~/fluidity-tap-scripts/out/addressesFluidityTap.json
```
Step 3.
Adds the collateral type into the testchain MCD system.

```bash
./bin/deploy-spell
```
Step 4.
Mint tokens for FluidityTapToken for the primary account

```bash
./bin/mint-fluidity-tap
```
_______________________________________________

## Interacting with MCD
(requires that MCD can take custom ILKs if not need to write the underlying SETH commands)

1. Deposits all of the FluidityTapTokens to the FluidityTapTokens Adapter. The adapter contract us a trusted smart contract that is used to deposit unlocked collateral into the CDP engine.

```bash
./bin/join-fluidity-tap
```

there shouldn't be tokens in the CDP engine yet. The tokens have merely moved from the deployer's address into the Adapter contract.

2. Ensure that a spot price is set. Additional steps for updating prices are available in the bottom section "Interacting with the Price Feed".

```bash
./bin/poke-pip-fluidity-tap
```

2. Lock the FluidityTap Adapter tokens into the CDP engine and withdraw X Dai. X Dai < less than collateralization ratio set up. THe default value in these scripts is 110%.

```bash
./bin/frob-fluidity-tap
```

3.  Remove the X Dai and place it into your account. At this point the collateral is locked in MCD system and your external wallet will have Dai

```bash
./bin/exit-dai
```

4. When you're ready to close the CDP. Send the Dai back by calling join.

```bash
./bin/join-dai
```

5. Withdraw the collateral with the negative value. You're depositing X Dai and now withdrawing
the FluidityTap adapter tokens from the CDP engine.


```bash
./bin/neg-frob-fluidity-tap
```


6. Finally, remove your collateral token from the adapter. The tokens will be deposited into the primary account.

```bash
./bin/exit-fluidity-tap
```

7. FluidityTap should now be in the wallet and can be burned once the real world assets are sold.

```bash
./bin/burn-fluidity-tap
```

-----------------------------------------------------------------------------

## Interacting with the Price Feed

In the first part when deploying fluidity-tap, price feed contract created. This script will update the price as well as ensure that the spot price is updated as well. The spot price impacts how much Dai/collateral can be withdrawn to stay above the initialized collateralization ratio. There will at some point be restrictions on who can provide prices but right now it is updated by the same contract deployer.

```bash
./bin/poke-pip-fluidity-tap
```