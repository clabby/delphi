# Contributing :hammer_and_wrench:

First of all, thanks for your interest in contributing! :yellow_heart:

## Get set up
1. Clone the repo: `git clone git@github.com:baofinance/delphi.git`
2. Install [Foundry](https://github.com/gakonst/foundry)* or [DappTools](https://github.com/dapphub/dapptools) if you haven't already. 
   1. \* Recommended
3. Create a branch `git checkout -b my-new-delphi-feature`

## Testing
All tests that call the DelphiOracle's `getLatestValue()` function are pinned to the block `#14305846` on Ethereum mainnet.

The following command can be used to run forge tests locally with max verbosity and output a gas report:  
`forge test --fork-url <alchemy-url> --fork-block-number 14305846 -vvv --gas-report`

You can use any RPC that has access to archival state for `<alchemy-url>`. We just recommend [Alchemy](https://alchemy.com), it's free!

## Pull Request Format
When creating a pull request, ensure the following requirements are met:
1. Clearly explain the purpose of your pull request and what it adds/removes in the description.
2. All test cases should pass in the GitHub workflow (forge tests). _If you added any new logic, create a test case for it._
3. Ensure your code is well commented.
4. `.gas-report` is up-to-date after your changes are completed.