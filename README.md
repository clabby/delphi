# Delphi 🔮🌜

Delphi is a set of contracts that allows anyone to permissionlessly create
oracles which perform an arbitrary mathematical operation on data from
[ChainLink](https://chain.link/) Aggregators.

Utilizes a modified version of [Band Protocol's equation evaluation library](https://medium.com/bandprotocol/encoding-and-evaluating-mathematical-expression-in-solidity-f1bb062fa86e)
that allows for multiple variables to be used **(well, not yet- see TODO)**. 

## Specification
* `OracleFactoryV1`
  * `createOracle(address[] _aggregators, uint256[] _expressions)`
    * _TODO_
  * `getOracles(bool _isEndorsed) view returns (address[] memory _oracles)`
    * Returns all endorsed/non-endorsed oracles created by the factory.
  * `setAllowAggregator(address _aggregator, bool _allow)`
    * **ADMIN FUNCTION:** Allows/disallows an aggregator for usage in creation of future oracles.
  * `setEndorsed(address _oracle, bool _endorsed)`
    * **ADMIN FUNCTION:** Endorses/Unendorses an oracle that was created by the factory.
* `DelphiOracleV1`
  * `init(address _factory, address[] _oracles, uint256[] _expressions)`
    * Called by the `DelphiFactoryV1` contract upon creation of the oracle. Can only be called once.
  * `getLatestValue() view returns (int256)`
    * Returns the latest value of the oracle by executing the equation with the most recent data from ChainLink Aggregators.
  * `latestRoundData()`
    * _TODO_

## Application
*TODO*

## TODO
- [ ] **Add ability to use multiple variables in oracle's equation.**
- [ ] Design Front-End for easy oracle creation. (See: [Shunting-yard Algorithm](https://en.wikipedia.org/wiki/Shunting-yard_algorithm) & [polish notation](https://en.wikipedia.org/wiki/Polish_notation))
- [ ] Make a subgraph, everybody likes subgraphs.