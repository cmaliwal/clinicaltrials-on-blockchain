pragma solidity ^0.4.23;

import "./Regulator.sol";


contract ClinicalTrial {

    address cro;
    address regulator;

    uint public proposalId;

    uint public startDate;
    uint public endDate;
    uint public createdDate;

    bytes32 public drugName;
    bytes public ipfsHash;

    constructor(address _regulator, address _cro, uint _proposalId, uint _startDate, 
	    uint _endDate, bytes32 _drugName, bytes _ipfsHash) public {
        cro = _cro;
        regulator = _regulator;
        proposalId = _proposalId;
        startDate = _startDate;
        endDate = _endDate;
        drugName = _drugName;
        ipfsHash = _ipfsHash;
        createdDate = now;
    }

}