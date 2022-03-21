// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.10;

import "solmate/utils/CREATE3.sol";
import "./DelphiOracleV1.sol";

/*

          ______          \'/
      .-'` .    `'-.    -= * =-
    .'  '    .---.  '.    /.\
   /  '    .'     `'. \
  ;  '    /          \|
 :  '  _ ;            `
;  :  /(\ \
|  .       '.
|  ' /     --'
|  .   '.__\
;  :       /
 ;  .     |            ,
  ;  .    \           /|
   \  .    '.       .'/
    '.  '  . `'---'`.'
      `'-..._____.-`

    Delphi Oracle Factory

*/
contract DelphiFactoryV1 {

    address[] public oracles;
    address public owner;
    mapping(address => bool) public endorsed;
    mapping(address => bool) public linkAggregators;

    event OracleCreation(string _name, address _address);
    event AllowAggregator(address _aggregator, bool _isAllowed);
    event Endorsement(address _oracle, bool _isEndorsed);
    event OwnershipTransferred(address previousOwner, address newOwner);

    constructor(address[] memory _aggregators) {
        // For ease of deployment, instantiate the contract with allowed aggregators
        for (uint8 i; i < _aggregators.length;) {
            linkAggregators[_aggregators[i]] = true;
            emit AllowAggregator(_aggregators[i], true);
            unchecked { ++i; }
        }
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Error: CALLER_NOT_OWNER");
        _;
    }

    // -----------------------------
    // PUBLIC FUNCTIONS
    // -----------------------------

    /**
     * Create an oracle that performs an arbitrary mathematical operation
     * on one or more ChainLink aggregator feeds.
     *
     * @param _name Name of the Oracle contract (For front-ends)
     * @param _aggregators ChainLink aggregators used in oracle
     * @param _expressions Equation OPCODEs & values
     */
    function createOracle(
        string memory _name,
        address[] memory _aggregators,
        uint256[] calldata _expressions
    ) external returns (address deployed) {
        // Check that all oracles are whitelisted
        for (uint8 i; i < _aggregators.length;) {
            require(linkAggregators[_aggregators[i]], "Error: ORACLE_NOT_ALLOWED");
            unchecked { ++i; }
        }

        // Deploy new synth oracle
        deployed = CREATE3.deploy(
            keccak256(abi.encodePacked(_aggregators, _expressions)), // Use aggregators and expression as CREATE2 salt to prevent duplicate oracles that perform the same equation on the same oracles
            type(DelphiOracleV1).creationCode,
            0
        );

        // Initialize new oracle
        DelphiOracleV1(deployed).init(_name, msg.sender, _aggregators, _expressions);

        // Add oracle to factory's collection
        oracles.push(deployed);

        // Emit OracleCreation event
        emit OracleCreation(_name, deployed);
    }

    // -----------------------------
    // ADMIN FUNCTIONS
    // -----------------------------

    /**
     * Allow/disallow an aggregator for use in new oracles
     *
     * @param _aggregator ChainLink Aggregator to allow/disallow
     * @param _allow Allowed=true|Disallowed=false
     */
    function setAllowAggregator(address _aggregator, bool _allow) external onlyOwner {
        linkAggregators[_aggregator] = _allow;
        emit AllowAggregator(_aggregator, _allow);
    }

    /**
     * Endorse an oracle. This functionality exists so that protocols can
     * audit and endorse community made Delphi oracles, separating them from
     * other oracles made by the factory.
     *
     * @param _oracle ChainLink Aggregator to endorse
     * @param _endorsed Endorsed=true|Remove=false
     */
    function setEndorsed(address _oracle, bool _endorsed) external onlyOwner {
        endorsed[_oracle] = _endorsed;
        emit Endorsement(_oracle, _endorsed);
    }

    /**
     * Transfer contract ownership
     *
     * @param _newOwner New owner of the contract
     */
    function transferOwnership(address _newOwner) external onlyOwner {
        owner = _newOwner;
        emit OwnershipTransferred(msg.sender, _newOwner);
    }
}
