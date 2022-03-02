// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "@openzeppelin/access/Ownable.sol";
import "@chainlink/interfaces/AggregatorV3Interface.sol";
import "../lib/solmate/src/utils/CREATE3.sol";
import "./Oracle.sol";
import "../lib/openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

contract OracleFactoryV1 is Ownable {
    address[] public linkOracles;
    address[] public oracles;
    mapping(address => bool) public endorsed;

    bytes32 public SALT = 0xfff6c856a1f2b4269a1d1d9bacd121f1c9273b6650961875824ce18cfc2ed86e;

    constructor(address[] memory initialOracles) {
        // For ease of deployment, fill the link oracles with your deployment script
        for (int8 i = 0; i < initialOracles.length; i++) {
            linkOracles[i] = initialOracles[i];
        }
    }

    // -----------------------------
    // PUBLIC FUNCTIONS
    // -----------------------------

    function createOracle() external{
        address deployed = CREATE3.deploy(
            SALT,
            type(OracleV1).creationCode,
            0
        );

        // TODO: Initialize oracle
        // Initializable

        oracles.push(oracles);
    }

    // -----------------------------
    // ADMIN FUNCTIONS
    // -----------------------------

    function setEndorsed(address oracle) external onlyOwner {
        endorsed[oracle] = true;
    }
}
