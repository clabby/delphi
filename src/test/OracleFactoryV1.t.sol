// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../OracleFactoryV1.sol";

contract OracleFactoryV1Test is DSTest {
    OracleFactoryV1 factory;
    SynthOracleV1 oracle;

    function setUp() public {
        address[] linkOracles;

        // Add a few oracles for testing
        // linkOracles.push(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419); // ETH/USD
        // linkOracles.push(0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c); // BTC/USD
        linkOracles.push(0x47E1e89570689c13E723819bf633548d611D630C); // BTC Marketcap USD
        linkOracles.push(0xAA2FE1324b84981832AafCf7Dc6E6Fe6cF124283); // ETH Marketcap USD

        // Create Factory
        factory = new OracleFactoryV1(linkOracles);

        // Deploy Oracle
        oracle = SynthOracleV1(factory.createOracle(factory.oracles()));
    }

    // TODO
}
