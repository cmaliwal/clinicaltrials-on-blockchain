pragma solidity ^0.4.23;

import "./Regulator.sol";


contract ClinicalTrial {

    address cro;
    address regulator;

    uint32 public proposalId;

    uint32 public startDate;
    uint32 public endDate;
    uint32 public createdDate;

    bytes32 public drugName;
    bytes public ipfsHash;

    event AddSubject(address indexed msgSender,bytes32 msg,uint timestamp);
    event AddDataPoint(address indexed msgSender,bytes32 msg,uint timestamp);

    struct DataPoint {
        uint32 timestamp;
        bytes32 json;
    }

    bytes32[] subjects;
    mapping(bytes32 => DataPoint[]) data;

    /**
   * @dev Throws if called by any account other than the cro.
   */
    modifier croOnly{
        require(msg.sender == cro, "Only cro access");
        _;
    }

    modifier trialIdOpen {
        if ( now < startDate || now > endDate ) {
            revert("Something went wrong");
        }
        _;
    }

    modifier dateBeforeStart {
        if ( now > startDate ) {
            revert("date passed");
        }
        _;
    }

    constructor(address _regulator, address _cro, uint32 _proposalId, uint32 _startDate, 
	    uint32 _endDate, bytes32 _drugName, bytes _ipfsHash) public {
        cro = _cro;
        regulator = _regulator;
        proposalId = _proposalId;
        startDate = _startDate;
        endDate = _endDate;
        drugName = _drugName;
        ipfsHash = _ipfsHash;
        createdDate = uint32(now);
    }

    function getSubjectsCount() public view returns(uint _counter) {
        _counter = subjects.length;
    }

    function getSubjectById(uint _id) public view returns (bytes32 _subject) {
        if ( _id >= subjects.length ) {
            _subject = "";
            return;
        }
        _subject = subjects[_id];
    }

    function getDataCounterForSubject(uint _subjectId) public view returns (uint _counter) {
        if ( _subjectId >= subjects.length ) {
            _counter = 0;
            return;
        }
        bytes32 ident = getSubjectIdentById(_subjectId);
        _counter = data[ident].length;
    }

    function getSubjectIdentById(uint _subjectId) public view returns (bytes32 _ident) {
        if ( _subjectId >= subjects.length ) {
            _ident = "";
            return;
        }
        _ident = keccak256(abi.encodePacked(subjects[_subjectId]));
    }



}