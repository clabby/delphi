# Delphi 🔮🌜

Delphi is a set of contracts that allows anyone to permissionlessly create
oracles which perform an arbitrary mathematical operation on data from
[ChainLink](https://chain.link/) Aggregators.

Utilizes a modified version of [Band Protocol's equation evaluation library](https://medium.com/bandprotocol/encoding-and-evaluating-mathematical-expression-in-solidity-f1bb062fa86e)
that allows for multiple variables to be used.

## Specification
* `OracleFactoryV1`
  * `createOracle(string _name, address[] _aggregators, uint256[] _expressions)`
    * Creates an oracle that uses the given aggregators and evaluates the equation defined in _expressions.
    * `_expressions` is an array of Opcodes and their children. (See `src/math/Equation.sol` for more info)
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

## Application
*TODO*

## Test Deployments
*Testnet deployments are subject to frequent change while in development*

| Contract         | Network | Address                                    | Explorer                                                                              |
|------------------|---------|--------------------------------------------|---------------------------------------------------------------------------------------|
| DelphiFactoryV1  | Kovan   | 0xfbb23eef7dbf575c156798533bf52be482d235e5 | [Link](https://kovan.etherscan.io/address/0xfbb23eef7dbf575c156798533bf52be482d235e5) |
| Equation Library | Kovan   | 0xff9b4dd7c88442255f720b2611bda8a91bf661bf | [Link](https://kovan.etherscan.io/address/0xff9b4dd7c88442255f720b2611bda8a91bf661bf) |
| 2xETH Oracle     | Kovan   | 0xb2d1D494cA62a5d8220AFf9372cEe61A354C7c1c | [Link](https://kovan.etherscan.io/address/0xb2d1D494cA62a5d8220AFf9372cEe61A354C7c1c) |

## TODO
Contracts:
- [x] **Add ability to use multiple variables in oracle's equation.**
- [x] Scale all ChainLink aggregator results to 1e18 to keep results uniform / promote ease of use.
- [ ] Fix bug with `DelphiFactoryV1#getOracles(bool _isEndorsed)`
- [x] Write more extensive tests **_(could still use a few more)_**
- [ ] Optimize size of `DelphiOracleV1` for cheaper creation
- [ ] Optimize gas consumed by `DelphiOracleV1#getLatestPrice()`. It will naturally be more expensive for more complex equations.
- [ ] *Maybe* Use ChainLink `AggregatorV2V3Interface` instead of `AggregatorV3Interface`

Front-end:
- [ ] Design Front-End for easy oracle creation. (See: [Shunting-yard Algorithm](https://en.wikipedia.org/wiki/Shunting-yard_algorithm) & [polish notation](https://en.wikipedia.org/wiki/Polish_notation))
- [ ] Make a subgraph, everybody likes subgraphs.