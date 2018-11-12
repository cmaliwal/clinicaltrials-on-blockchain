pragma solidity ^0.4.23;

import "./ClinicalTrial.sol";


contract Regulator {
    address public owner;

    int8 constant STATUS_SUBMITTED = 0;
    int8 constant STATUS_ACCEPTED  = 1;
    int8 constant STATUS_REJECTED  = 2;

    event ProposalSubmitted(address indexed msgSender,bytes32 msg,uint timestamp);
    event ProposalAccepted (address indexed msgSender,bytes32 msg,uint timestamp);
    event ProposalRejected (address indexed msgSender,bytes32 msg,uint timestamp);

    event AddCRO (address indexed msgSender,bytes32 msg,uint timestamp);
    event UpdateCROStatus (address indexed msgSender,bytes32 msg,uint timestamp);
    event RegulatoryContractDeployed (address indexed msgSender,bytes32 msg,uint timestamp);
    event ClinicalTrialContractDeployed (address indexed msgSender,bytes32 msg,uint timestamp);
    event UploadTrialProtocol (address indexed msgSender,bytes msg,uint timestamp);


    struct CroIdentity {
        bytes32  name;
        bytes32  url;
        address addr;
        int8   status;  //values: SUBMITTED, ACCEPTED, REJECTED
    }

    struct TrialProposal {
        address croAddr;
        bytes32  drugName;
        uint32  startDate;
        uint32  endDate;
        bytes  ipfsHash;
        int8  status; // values: SUBMITTED, ACCEPTED, REJECTED
        address trial;  // clinical trial contract; 0x0 if none
    }

    CroIdentity[] cros;
    TrialProposal[] proposals;

    /**
   * @dev Throws if called by any account other than the owner.
   */
    modifier ownerOnly{
        require(msg.sender == owner, "Only owner access");
        _;
    }

    modifier crosOnly {
        bool found = false;
        for (uint32 i = 0; i<cros.length; i++) {
            if (cros[i].addr == msg.sender && cros[i].status == STATUS_ACCEPTED) {
                found = true;
                break;
            }
        }
        if (!found) {
            revert("cro not found");
        }
        _;
    }

    constructor() public{
        owner = msg.sender;
        emit RegulatoryContractDeployed(msg.sender,"Mined",block.timestamp);
    }

    function submitProposal(bytes32 _drugName, uint32 _startDate, uint32 _endDate) public {

        TrialProposal memory proposal;
        proposal.croAddr = msg.sender;
        proposal.drugName = _drugName;
        proposal.startDate = _startDate;
        proposal.endDate = _endDate;
        proposal.status = STATUS_SUBMITTED;

        proposals.push(proposal);

        emit ProposalSubmitted(msg.sender,proposal.drugName,block.timestamp);
    }

    function submitTrialProtocolDocument(uint32 _id, bytes _docHash) public returns (bytes _docIpfsHash) {
        require(_id <= proposals.length, "Invalid Id");
        TrialProposal memory tp = proposals[_id];
        tp.ipfsHash = _docHash;
        _docIpfsHash = tp.ipfsHash;
        emit UploadTrialProtocol(msg.sender,tp.ipfsHash,block.timestamp);
    }

    function getProposalsCount() public view returns (uint _counter) {
        _counter = proposals.length;
    }

    function getProposalById(uint32 _id) public view returns (address _croAddr, bytes32 _drugName, uint32 _startDate, 
        uint32 _endDate, bytes _ipfsHash, int _status, address _trial) 
    {
        require(_id <= proposals.length, "Invalid Id");
        TrialProposal memory tp = proposals[_id];
        _croAddr = tp.croAddr;
        _drugName = tp.drugName;
        _startDate = tp.startDate;
        _endDate = tp.endDate;
        _ipfsHash = tp.ipfsHash;
        _status = tp.status;
        _trial = tp.trial;
    }

    function acceptProposal(uint _id) public returns (address _clinicalTrial) {
        require(_id <= proposals.length, "Invalid Id");
        
        TrialProposal memory tp = proposals[_id];
        if (tp.status == STATUS_ACCEPTED) {
            revert("already accepted");
        }

        // deploy the actual clinical trial contract and return it
        ClinicalTrial trial = new ClinicalTrial(owner, tp.croAddr, _id, tp.startDate, tp.endDate, tp.drugName, tp.ipfsHash);

        proposals[_id].trial = trial;
        proposals[_id].status = STATUS_ACCEPTED;

        _clinicalTrial = proposals[_id].trial;

        emit ProposalAccepted (msg.sender,tp.drugName,block.timestamp);
        emit ClinicalTrialContractDeployed(msg.sender,"Mined",block.timestamp);
    }

    function rejectProposal(uint _id) public returns(bool) {
        require(_id <= proposals.length, "Invalid Id");
         
        proposals[_id].status = STATUS_REJECTED;

        TrialProposal memory tp = proposals[_id];
        emit ProposalRejected (tp.croAddr, tp.drugName, _id);

        return true;
    }

    function submitCro(bytes32 _name, bytes32 _url) public returns(bool) {
        CroIdentity memory cro;
        cro.name = _name;
        cro.url = _url;
        cro.addr = msg.sender;
        cro.status = STATUS_SUBMITTED;
        cros.push(cro);
        emit AddCRO(msg.sender,cro.name,block.timestamp);

        return true;
    }

    function changeCroStatus(address _addr, uint8 _status) public returns(bool) {
        for (uint32 i = 0; i<cros.length; i++) {
            if (cros[i].addr == _addr) {
                cros[i].status = int8(_status);
                if (cros[i].status == STATUS_ACCEPTED) {
                    emit UpdateCROStatus(msg.sender,"Approved",block.timestamp);
                    return true;
                } else {
                    emit UpdateCROStatus(msg.sender,"Rejected",block.timestamp);
                    return true;
                }
                break;
            } 
        }  
    }

    function getCrosCounter() public view returns(uint _counter) {
        _counter = cros.length;
    }

    function getCroById(uint _id) public view returns(bytes32 _name, bytes32 _url, address _addr, int8 _status) {
        require(_id <= cros.length, "Invalid Id");

        CroIdentity memory ci = cros[_id];
        _name = ci.name;
        _url = ci.url;
        _addr = ci.addr;
        _status = ci.status;
    }  
      
}