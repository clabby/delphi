// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "ds-test/test.sol";
import "../DelphiFactoryV1.sol";

contract DelphiFactoryV1Test is DSTest {
    DelphiFactoryV1 factory;
    DelphiOracleV1 baseOracle;

    function setUp() public {
        address[] memory aggregators = _getLinkAggregators();

        // Create Factory
        factory = new DelphiFactoryV1(aggregators);
        emit log_named_address("Factory", address(factory));

        // Check that all aggregators passed to constructor are allowed
        for (uint8 i = 0; i < aggregators.length; i++) {
            assertTrue(factory.linkAggregators(aggregators[i]));
        }

        uint256[] memory expressions = new uint256[](5);
        // x*2
        expressions[0] = 6;
        expressions[1] = 1;
        expressions[2] = 0;
        expressions[3] = 0;
        expressions[4] = 2;

        // Deploy Oracle
        baseOracle = DelphiOracleV1(factory.createOracle("2xETH", aggregators, expressions));
        emit log_named_address("Base Oracle (2xETH)", address(baseOracle));
    }

    // -----------------------------
    // ORACLE CREATION
    // -----------------------------

    // Test is pinned to block #14305846
    function testOneVariableOracle() public {
        assertEq(baseOracle.getLatestValue(), 6000612530720000000000);
    }

    // Test is pinned to block #14305846
    function testTwoVariableOracle() public {
        uint256[] memory expressions = new uint256[](5);
        // x+y
        expressions[0] = 4;
        expressions[1] = 1;
        expressions[2] = 0;
        expressions[3] = 1;
        expressions[4] = 1;

        address[] memory aggregators = _getLinkAggregators();

        // Deploy Oracle
        DelphiOracleV1 oracle = DelphiOracleV1(factory.createOracle("ETH+BTC", aggregators, expressions));

        assertEq(oracle.getLatestValue(), 47266446265360000000000);
    }

    // Test is pinned to block #14305846
    function testThreeVariableOracle() public {
        uint256[] memory expressions = new uint256[](11);
        // ((x+y)*z) / 1e8
        expressions[0] = 7;
        expressions[1] = 6;
        expressions[2] = 4;
        expressions[3] = 1;
        expressions[4] = 0;
        expressions[5] = 1;
        expressions[6] = 1;
        expressions[7] = 1;
        expressions[8] = 2;
        expressions[9] = 0;
        expressions[10] = 1e18;

        address[] memory aggregators = _getLinkAggregators();

        // Deploy Oracle
        DelphiOracleV1 oracle = DelphiOracleV1(factory.createOracle("(ETH+BTC) / LINK", aggregators, expressions));

        assertEq(oracle.getLatestValue(), 737832013977270330932800);
    }

    // Try to deploy two oracles with the same aggregators/expressions. Should fail.
    function testFailTwoOfAKind() public {
        uint256[] memory expressions = new uint256[](5);
        // x*y
        expressions[0] = 6;
        expressions[1] = 1;
        expressions[2] = 0;
        expressions[3] = 1;
        expressions[4] = 1;

        address[] memory aggregators = _getLinkAggregators();

        // A second oracle that performs the same operation on the same set of aggregators as another cannot be deployed
        factory.createOracle("ETHxBTC", aggregators, expressions);
        factory.createOracle("ETHxBTC", aggregators, expressions);
    }

    // Try to create an oracle with an aggregator that isn't allowed. Should fail.
    function testFailCreateOracleWithDisallowedAggregator() public {
        address[] memory aggregators = new address[](1);
        aggregators[0] = 0x8994115d287207144236c13Be5E2bDbf6357D9Fd;

        uint256[] memory expressions = new uint256[](5);
        // x*2
        expressions[0] = 6;
        expressions[1] = 1;
        expressions[2] = 0;
        expressions[3] = 0;
        expressions[4] = 2;

        // Deploy Oracle, should fail because the AMZN/USD aggregator is not allowed
        factory.createOracle("2xAMZN", aggregators, expressions);
    }

    // Try to re-initialize an oracle. Should fail.
    function testFailDoubleInit() public {
        uint256[] memory expressions = new uint256[](1);

        baseOracle.init(
            "2xETH",
            address(this),
            _getLinkAggregators(),
            expressions
        );
    }

    // -----------------------------
    // ADMIN FUNCTIONS
    // -----------------------------

    function testEndorseOracle() public {
        address oracleAddress = address(baseOracle);

        factory.setEndorsed(oracleAddress, true);
        assertTrue(factory.endorsed(oracleAddress));

        factory.setEndorsed(oracleAddress, false);
        assertTrue(!factory.endorsed(oracleAddress));
    }

    function testAllowAggregator() public {
        address[] memory aggregators = _getLinkAggregators();

        factory.setAllowAggregator(aggregators[0], true);
        assertTrue(factory.linkAggregators(aggregators[0]));

        factory.setAllowAggregator(aggregators[0], false);
        assertTrue(!factory.linkAggregators(aggregators[0]));
    }

    // -----------------------------
    // HELPER FUNCTIONS
    // -----------------------------

    // Helper function to get link oracles in form of address[] memory
    function _getLinkAggregators() private pure returns (address[] memory linkAggregators) {
        linkAggregators = new address[](3);
        linkAggregators[0] = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419; // ETH/USD -> x
        linkAggregators[1] = 0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c; // BTC/USD -> y
        linkAggregators[2] = 0x2c1d072e956AFFC0D435Cb7AC38EF18d24d9127c; // LINK/USD -> z
    }
}
