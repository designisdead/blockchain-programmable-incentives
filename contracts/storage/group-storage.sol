pragma solidity ^0.4.23;

import '../interface/group-interface.sol';
import '../interface/bounty-interface.sol';
import '../registry/enabled.sol';

contract Group is Enabled {

  using GroupInterface for GroupInterface.Group;
  using BountyInterface for BountyInterface.Bounty;
  GroupInterface.Group group;
  BountyInterface.Bounty bounties;

  event logGroupCreated(string _name, address _owner);
  event logMembershipRequested(address indexed group, address indexed user);
  event logCreateBounty(address indexed _issuer, address _group, string _title, uint _reward);
  event logActivateBounty(address indexed _issuer, address _group, string _title, uint _reward);

  constructor (string _name, string _avatar, address _owner, address _CMC) public {
    group.name = _name;
    group.avatar = _avatar;
    group.owner = _owner;
    group.members.push(_owner);
    CMC=_CMC;
  }

  function getGroup() external view  returns (string, string, address, address[], address[]) {
    return group.getGroup();
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

  function createBounty(string _title, string _issueURL, string _reference, uint _deadline, address _issuer, uint _reward) external  returns (bytes32) {
    return bounties.createBounty(_title, _issueURL, _reference, _deadline, _issuer, _reward);
  }

  function getBounties() external view returns (bytes32[]) {
    return bounties.getBounties();
  }

  function getBounty(bytes32 _index) external view  returns (string title, string issueURL, string reference, uint timestamp, uint deadline, BountyInterface.statusOptions status, address issuer, uint reward, uint proposalCount) {
    (title, issueURL, reference, timestamp, deadline) = bounties.getBounty1(_index);
    (status, issuer, reward, proposalCount) = bounties.getBounty2(_index);
    return (title, issueURL, reference, timestamp, deadline, status, issuer, reward, proposalCount);
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
