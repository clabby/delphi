# Delphi :crystal_ball::last_quarter_moon_with_face: ![Test Workflow](https://github.com/clabby/delphi/actions/workflows/forgetests.yml/badge.svg) [![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

Delphi is a set of contracts that allows anyone to permissionlessly create
oracles which perform an arbitrary mathematical operation on data from
[ChainLink](https://chain.link/) Aggregators.

Utilizes a modified version of [Band Protocol's equation evaluation library](https://medium.com/bandprotocol/encoding-and-evaluating-mathematical-expression-in-solidity-f1bb062fa86e)
that allows for multiple variables to be used.

## Specification
* `DelphiFactoryV1`
  * `createOracle(string _name, address[] _aggregators, uint256[] _expressions)`
    * Creates an oracle that uses the given aggregators and evaluates the equation defined in _expressions.
    * `_expressions` is an array of Opcodes and their children. (See `src/math/Equation.sol` for more info)
  * `setAllowAggregator(address _aggregator, bool _allow)`
    * **ADMIN FUNCTION:** Allows/disallows an aggregator for usage in creation of future oracles.
  * `setEndorsed(address _oracle, bool _endorsed)`
    * **ADMIN FUNCTION:** Endorses/Unendorses an oracle that was created by the factory.
  * `transferOwnership(address _newOwner)`
    * **ADMIN FUNCTION:** Transfers the ownership of the factory to `_newOwner`
* `DelphiOracleV1`
  * `init(address _factory, address[] _aggregators, uint256[] _expressions)`
    * Called by the `DelphiFactoryV1` contract upon creation of the oracle. Can only be called once.
  * `getLatestValue() view returns (int256)`
    * Returns the latest value of the oracle by executing the equation with the most recent data from ChainLink Aggregators.
  * `latestRoundData() & latestAnswer()`
    * Provided for use as an `AggregatorV2V3Interface`
  * `getAggregators() view returns (AggregatorV2V3Interface[] memory)`
    * Get the addresses of the aggregators that the oracle's equation utilizes.
  * `getNodes() view returns (Equation.Node[] memory)`
    * Get the oracle's equation nodes.

## Deployments
See [DEPLOYMENTS.md](./DEPLOYMENTS.md)

## Contribute
See [CONTRIBUTE.md](./CONTRIBUTE.md)

<p align="middle">
  <a href="https://chain.link">
    <img src="https://i.imgur.com/ITUP3qt.png" width=400 />  
  </a>
</p>
