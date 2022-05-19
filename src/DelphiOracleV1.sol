// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.14;

import "@chainlink/interfaces/AggregatorV2V3Interface.sol";
import "./math/Equation.sol";

contract DelphiOracleV1 {

    string public name;
    address public creator; // Gotta give oracle creators creds <3
    address public factory;
    AggregatorV2V3Interface[] public aggregators;
    Equation.Node[] public nodes;
    bool private initialized = false;

    // -----------------------------
    // PUBLIC FUNCTIONS
    // -----------------------------

    /**
     * Initialize the Oracle
     *
     * @param _name Name of the Oracle contract (For front-ends)
     * @param _creator Creator of the contract, passed by the factory
     * @param _aggregators ChainLink aggregators to use in performOperation()
     * @param _expressions Equation OPCODEs & values
     */
    function init(
        string memory _name,
        address _creator,
        address[] memory _aggregators,
        uint256[] calldata _expressions
    ) external {
        require(!initialized, "Error: ALREADY_INITIALIZED");

        // Set creator, factory & ChainLink aggregators
        creator = _creator;
        name = _name;
        factory = msg.sender;

        for (uint8 i; i < _aggregators.length;) {
            aggregators.push(AggregatorV2V3Interface(_aggregators[i]));
            unchecked { ++i; }
        }

        // Set up equation for performOperation
        Equation.init(nodes, _expressions);

        initialized = true;
    }

    /**
     * Performs a special operation with data from available oracles
     */
    function getLatestValue() public view returns (int256) {
        uint256[] memory variables = new uint256[](aggregators.length);
        for (uint8 i; i < aggregators.length;) {
            variables[i] = uint256(aggregators[i].latestAnswer()) * (10 ** (18 - aggregators[i].decimals())); // Scale all values to 1e18
            unchecked { ++i; }
        }
        return int256(Equation.calculate(nodes, variables));
    }

    /**
     * Get the latest value of the oracle (performOperation remap to work with AggregatorV2V3Interface)
     */
    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        // TODO: Need to figure out what to set these to
        roundId = 0;
        startedAt = 0;
        updatedAt = 0;
        answeredInRound = 0;

        // Set oracle price to oracle operation
        answer = getLatestValue();
    }

    /**
     * Get the latest value of the oracle (performOperation remap to work with AggregatorV2V3Interface)
     */
    function latestAnswer() external view returns (int256) {
        return getLatestValue();
    }

    /**
     * Get the array of LINK aggregators the oracle utilizes
     */
    function getAggregators() external view returns (AggregatorV2V3Interface[] memory) {
        return aggregators;
    }

    /**
     * Get the oracle's equation nodes
     */
    function getNodes() external view returns (Equation.Node[] memory) {
        return nodes;
    }
}
