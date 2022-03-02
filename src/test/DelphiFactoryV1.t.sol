// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "ds-test/test.sol";
import "../DelphiFactoryV1.sol";

contract DelphiFactoryV1Test is DSTest {
    DelphiFactoryV1 factory;

    function setUp() public {
        address[] memory linkOracles = _getLinkOracles();

        // Create Factory
        factory = new DelphiFactoryV1(linkOracles);
        emit log_named_address("Factory", address(factory));
    }

    // Test is pinned to block #14305846
    function testCreateOracle() public {
        uint256[] memory expressions = new uint256[](5);
        // x+y
        expressions[0] = 4;
        expressions[1] = 1;
        expressions[2] = 0;
        expressions[3] = 1;
        expressions[4] = 1;

        address[] memory linkOracles = _getLinkOracles();

        // Deploy Oracle
        DelphiOracleV1 oracle = DelphiOracleV1(factory.createOracle(linkOracles, expressions));

        assertEq(oracle.getLatestValue(), 4726644626536);
    }

    // Helper function to get link oracles in form of address[] memory
    function _getLinkOracles() private view returns (address[] memory linkOracles) {
        linkOracles = new address[](2);
        linkOracles[0] = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419; // ETH/USD
        linkOracles[1] = 0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c; // BTC/USD
        // linkOracles[0] = 0x47E1e89570689c13E723819bf633548d611D630C; // BTC Marketcap USD
        // linkOracles[1] = 0xAA2FE1324b84981832AafCf7Dc6E6Fe6cF124283; // ETH Marketcap USD
    }
}
