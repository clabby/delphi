// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.10;

import "@openzeppelin/access/Ownable.sol";
import "@chainlink/interfaces/AggregatorV3Interface.sol";
import "solmate/utils/CREATE3.sol";
import "./SynthOracleV1.sol";

contract OracleFactoryV1 is Ownable {
    address[] public linkOracles;
    address[] public oracles;
    mapping(address => bool) public endorsed;

    // heh heh
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

    function createOracle(
        address[] memory _oracles,
        uint256[] calldata _expressions
    ) external returns (address deployed) {
        // Deploy new synth oracle
        deployed = CREATE3.deploy(
            SALT,
            type(SynthOracleV1).creationCode,
            0
        );

        // Initialize new oracle
        SynthOracleV1(deployed).init(address(this), _oracles, _expressions);

        // Add oracle to factory's collection
        oracles.push(oracles);
    }

    // -----------------------------
    // ADMIN FUNCTIONS
    // -----------------------------

    function setEndorsed(address oracle) external onlyOwner {
        endorsed[oracle] = true;
    }
}
