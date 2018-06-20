pragma solidity ^0.4.23;

import '../interface/group-interface.sol';

library GroupLib {

  function getGroup(GroupInterface.Group storage _group) external view returns (bytes32, string, address, address[], address[]) {
      return (_group.name, _group.avatar, _group.owner, _group.members, _group.pendingMembers);
  }

  function groupMeta(GroupInterface.Group storage _group) external view returns (bytes32, string, address) {
    return (_group.name, _group.avatar, _group.owner);
  }

  function requestMembership(GroupInterface.Group storage _group, address _sender) external {
    _group.pendingMembers.push(_sender);
  }

  function acceptMembership(GroupInterface.Group storage _group, address _pending, address _sender) external {
    require(_sender == _group.owner);
    for (uint i=0; i < _group.pendingMembers.length; i++) {
      if (_pending == _group.pendingMembers[i]) {
        _group.pendingMembers = _deleteAddress(_group.pendingMembers, i);
        _group.members.push(_pending);
      }
    }
  }

  function declineMembership(GroupInterface.Group storage _group, address _pending, address _sender) external {
    require(_sender == _group.owner);
    for (uint i = 0; i < _group.pendingMembers.length; i++) {
      if (_pending == _group.pendingMembers[i]) {
        _group.pendingMembers = _deleteAddress(_group.pendingMembers, i);
      }
    }
  }

  function leaveGroup(GroupInterface.Group storage _group, address _sender) external {
    for (uint i = 0; i < _group.members.length; i++) {
      if (_sender == _group.members[i]) {
        _group.members = _deleteAddress(_group.members, i);
      }
    }
  }

  function _deleteAddress(address[] _array, uint _index) public pure returns (address[]) {
    address[] memory arrayNew = new address[](_array.length-1);
    assert(_index < _array.length);
    for (uint i = 0; i<_array.length-1; i++){
      if(i != _index && i<_index){
        arrayNew[i] = _array[i];
      } else {
        arrayNew[i] = _array[i+1];
      }
    }
    delete _array;
    return arrayNew;
  }

  function _isMember(GroupInterface.Group storage _group, address _sender) external view returns (bool) {
    for (uint i = 0; i < _group.members.length; i++) {
      if (_group.members[i] == _sender) return true;
    }
    return false;
  }

  function _isPending(GroupInterface.Group storage _group, address _sender) external view returns (bool) {
    for (uint i = 0; i < _group.pendingMembers.length; i++) {
      if (_group.pendingMembers[i] == _sender) return true;
    }
    return false;
  }

  function _isOwner(GroupInterface.Group storage _group, address _sender) external view returns (bool) {
    return _group.owner == _sender;
  }
}
