// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "ds-test/test.sol";
import "../OracleFactoryV1.sol";

contract OracleFactoryV1Test is DSTest {
    OracleFactoryV1 factory;

    function setUp() public {
        address[] memory linkOracles = _getLinkOracles();

        // Create Factory
        factory = new OracleFactoryV1(linkOracles);
        emit log_named_address("Factory", address(factory));
    }

    // Test is pinned to block #14305846
    function testCreateOracle() public {
        uint256[] memory expressions = new uint256[](4);
        // x*2
        expressions[0] = 8;
        expressions[1] = 1;
        expressions[2] = 0;
        expressions[3] = 2;

        address[] memory linkOracles = _getLinkOracles();

        // Deploy Oracle
        SynthOracleV1 oracle = SynthOracleV1(factory.createOracle(linkOracles, expressions));

        assertEq(oracle.getLatestValue(), 600061253072);
    }

    function _getLinkOracles() private view returns (address[] memory linkOracles) {
        linkOracles = new address[](2);
        linkOracles[0] = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419; // ETH/USD
        linkOracles[1] = 0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c; // BTC/USD
        // linkOracles[0] = 0x47E1e89570689c13E723819bf633548d611D630C; // BTC Marketcap USD
        // linkOracles[1] = 0xAA2FE1324b84981832AafCf7Dc6E6Fe6cF124283; // ETH Marketcap USD
    }
}
