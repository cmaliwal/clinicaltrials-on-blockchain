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
        require(now > startDate || now < endDate, "Trail id not open");
        _;
    }

    modifier dateBeforeStart {
        require(now < startDate, "date before start");
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
        createdDate = now;
    }

    function getSubjectsCount() public view returns(uint _counter) {
        _counter = subjects.length;
    }

    function getSubjectById(uint _id) public view returns (bytes32) {
        if ( _id >= subjects.length ) {
            _subject = "";
            return;
        }
        return subjects[_id];
    }

    function getDataCounterForSubject(uint _subjectId) public view returns (uint) {
        if (_subjectId >= subjects.length) {
            return 0;
        }
        bytes32 ident = getSubjectIdentById(_subjectId);
        return data[ident].length;
    }

    function getSubjectIdentById(uint _subjectId) public view returns (bytes32) {
        if ( _subjectId >= subjects.length ) {
            return "";
            
        }
        return keccak256(abi.encodePacked(subjects[_subjectId]));
    }

    function getDataPointForSubject(uint _subjectId, uint _dataPointId) public view returns (uint _timestamp, bytes32 _json) {
        if ( _subjectId >= subjects.length ) {
            _timestamp = 0;
            _json = "";
            return;
        }

        bytes32 ident = getSubjectIdentById(_subjectId);
        if (_dataPointId >= data[ident].length) {
            _timestamp = 0;
            _json = "";
            return;
        }

        _timestamp = data[ident][_dataPointId].timestamp;
        _json = data[ident][_dataPointId].json;
    }

    function addSubject(bytes32 _subject) public croOnly dateBeforeStart returns (bool _success) {
        subjects.push(_subject);
        emit AddSubject(msg.sender,_subject,block.timestamp);
        return true;
    }

    function addDataPoint(uint _subjectId, bytes32 _json) public croOnly trialIdOpen returns (bool _success) {
        if ( _subjectId >= subjects.length ) {
            revert("invalid Id");
        }

        bytes32 ident = getSubjectIdentById(_subjectId);
        DataPoint memory dp;
        dp.timestamp = uint32(now);
        dp.json = _json;

        data[ident].push(dp);
        return true;
    }  

}