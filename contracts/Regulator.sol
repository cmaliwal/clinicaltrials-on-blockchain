pragma solidity ^0.4.23;

import "./ClinicalTrial.sol";


contract Regulator {
    address public owner;

    int8 constant STATUS_SUBMITTED = 0;
    int8 constant STATUS_ACCEPTED  = 1;
    int8 constant STATUS_REJECTED  = 2;

    event AddCRO (address indexed msgSender,bytes32 msg,uint timestamp);
    event UpdateCROStatus (address indexed msgSender,bytes32 msg,uint timestamp);
    event RegulatoryContractDeployed (address indexed msgSender,bytes32 msg,uint timestamp);

    struct CroIdentity {
        bytes32  name;
        bytes32  url;
        address addr;
        int8   status;  //values: SUBMITTED, ACCEPTED, REJECTED
    }

    CroIdentity[] cros;

    /**
   * @dev Throws if called by any account other than the owner.
   */
    modifier ownerOnly{
        require(msg.sender == owner, "Only owner access");
        _;
    }

    constructor() public{
        owner = msg.sender;
        emit RegulatoryContractDeployed(msg.sender,"Mined",block.timestamp);
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