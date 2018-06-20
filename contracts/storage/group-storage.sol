pragma solidity ^0.4.23;

import '../interface/group-interface.sol';
import '../interface/pr-interface.sol';
//import '../interface/bounty-interface.sol';
import '../registry/enabled.sol';

contract Group is Enabled {

  using GroupInterface for GroupInterface.Group;
  using PRInterface for PRInterface.PR;
  //using BountyInterface for BountyInterface.Bounty;
  GroupInterface.Group group;
  PRInterface.PR pullrequests;
  //BountyInterface.Bounty bounties;

  constructor (bytes32 _name, string _avatar, address _owner, address _CMC) public {
    group.name = _name;
    group.avatar = _avatar;
    group.owner = _owner;
    group.members.push(_owner);
    CMC=_CMC;
  }

  function getGroup() external view  returns (bytes32, string, address, address[], address[]) {
    return group.getGroup();
  }

  function groupMeta() external view returns (bytes32, string, address) {
    return group.groupMeta();
  }
  function requestMembership(address _sender) external  {
    return group.requestMembership(_sender);
  }

  function acceptMembership(address _user, address _sender) external  {
    return group.acceptMembership(_user, _sender);
  }

  function declineMembership(address _user, address _sender) external  {
    return group.declineMembership(_user, _sender);
  }

  function leaveGroup(address _sender) external  {
    return group.leaveGroup(_sender);
  }

  function changeReward(uint _newReward) external {
    return pullrequests.changeReward(_newReward);
  }

  function getReward() external view returns (uint) {
    return pullrequests.getReward();
  }

  function createPR(string _title, string _reference, uint _deadline, address _issuer) external returns (bytes32) {
    bytes32 index = pullrequests.createPullRequest(_title, _reference, _deadline, _issuer);
    return index;
  }

  function getPRs() external view returns (bytes32[]) {
    return pullrequests.getPRs();
  }

  function getPR(bytes32 _index) external view
  returns (
    string title,
    string reference,
    uint timestamp,
    uint deadline,
    PRInterface.statusOptions status,
    address issuer,
    uint reward,
    uint changeRequestCount,
    address[] contributers) {
    (title, reference, timestamp, deadline, status) = pullrequests.getPR1(_index);
    (issuer, reward, changeRequestCount, contributers) = pullrequests.getPR2(_index);
    return (title, reference, timestamp, deadline, status, issuer, reward, changeRequestCount, contributers);
  }

  function addContribution(bytes32 _index, uint _amount, address _sender) {
    return pullrequests.addContribution(_index, _amount, _sender);
  }

  function getContribution(bytes32 _index, address _contributer) external view returns (uint) {
    return pullrequests.getContribution(_index, _contributer);
  }

  function approvePR(bytes32 _index, address _sender) external {
    return pullrequests.approvePR(_index, _sender);
  }

  function requestChange(bytes32 _index, string _reference, address _sender) external returns (uint) {
    return pullrequests.requestChange(_index, _reference, _sender);
  }

  function getChangeRequest(bytes32 _index, uint _id) returns (string, address, uint) {
    return pullrequests.getChangeRequest(_index, _id);
  }

  function _isMember(address _sender) external view returns (bool) {
    return group._isMember(_sender);
  }
  function _isPending(address _sender) external view returns (bool) {
    return group._isPending(_sender);
  }
  function _isOwner(address _sender) external view returns (bool) {
    return group._isOwner(_sender);
  }
}
