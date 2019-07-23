# Fluidity TAP Scripts: Interacting with MCD
[Fluidity Tokenized Asset Portfolio (TAP)](https://tap.fluidity.io/) is a model to obtain leverage on real world assets using the MakerDAO Multi-Collateral Dai (MCD) credit system. This repository contains scripts to use MCD with a custom collateral type. It assumes familiarity with dapp tools and installations and is a work in progress.

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
Incorporates the collateral type into the testchain MCD system

```bash
./bin/deploy-spell
```
Step 4.
Mint tokens for FluidityTapToken by ETH_FROM

```bash
./bin/mint-fluidity-tap
```
_______________________________________________

## Interacting with MCD
(requires that MCD can take custom ILKs if not need to write the underlying SETH commands)

1. Convert all of the USTR to the USTR Adapter

```bash
./bin/join-fluidity-tap
```

there shouldn't be tokens in the CDP engine yet

2. Ensure that a spot price is set. Additional steps for updating prices are available in the bottom section "Interacting with the Price Feed".

```bash
./bin/poke-pip-fluidity-tap
```

2. Lock the USTR Adapter tokens not into the VAT and withdraw X dai. X dai < less than collateralization ratio set up

```bash
./bin/frob-fluidity-tap
```

3.  Remove the X dai and place it into your account. At this point the USTR is locked in MCD system and your external wallet will have Dai

```bash
./bin/exit-dai
```

4. When you're ready to close the CDP. Send the Dai back by calling join.

```bash
./bin/join-dai
```

5. Withdraw the collateral with the negative value. You're inserting X Dai and now withdrawing
the USTR. It's still in the adapter format.


```bash
./bin/neg-frob-fluidity-tap
```


6. Finally, remove your collateral USTR token from the USTR adapter.

```bash
./bin/exit-fluidity-tap
```

7. ERC20 should now be in the wallet and can be burned once they are sold.

```bash
./bin/burn-fluidity-tap
```

-----------------------------------------------------------------------------

## Interacting with the Price Feed

In the first part when deploying fluidity-tap, there is a PIP_USTR contract deployed. This contract can take in prices.

```bash
./bin/poke-pip-fluidity-tap
```