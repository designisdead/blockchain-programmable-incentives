pragma solidity ^0.4.23;

import './registry/enabled.sol';
import './storage/people-storage.sol';
import './storage/timesheet-storage.sol';
import './storage/group-storage.sol';


contract Controller is Enabled {

  function registerUser(string _name, string _email, string _company, string _avatar) external {
    require(!People(ContractProvider(CMC).contracts("people-storage"))._isRegistered(msg.sender));
    return People(ContractProvider(CMC).contracts("people-storage")).registerUser(_name, _email, _company, _avatar, msg.sender);
  }

  function getUser(address _address) external view returns (string, string, string, string, address, address[]) {
    return People(ContractProvider(CMC).contracts("people-storage")).getUser(_address);
  }

  function updateUser(string _name, string _email, string _company, string _avatar) external {
    require(People(ContractProvider(CMC).contracts("people-storage"))._isRegistered(msg.sender));
    return People(ContractProvider(CMC).contracts("people-storage")).updateUser(_name, _email, _company, _avatar, msg.sender);
  }

  function createGroup(string _name, string _avatar) external {
    require(People(ContractProvider(CMC).contracts("people-storage"))._isRegistered(msg.sender));
    Group _group = new Group(_name, _avatar, msg.sender, CMC);
    People(ContractProvider(CMC).contracts("people-storage")).addGroup(address(_group), msg.sender);
  }

  function getGroup(address _group) external view  returns (string name, string avatar, address owner, address[] members, address[] pendingMembers, bytes32[] bounties) {
    (name, avatar, owner, members, pendingMembers) = Group(_group).getGroup();
    bounties = Group(_group).getBounties();
    return (name, avatar, owner, members, pendingMembers, bounties);
  }

  function requestMembership(address _group) external {
    require(People(ContractProvider(CMC).contracts("people-storage"))._isRegistered(msg.sender));
    require(!Group(_group)._isMember(msg.sender));
    require(!Group(_group)._isPending(msg.sender));
    return Group(_group).requestMembership(msg.sender);
  }

  function acceptMembership(address _group, address _user) external {
    require(Group(_group)._isOwner(msg.sender));
    require(Group(_group)._isPending(_user));
    Group(_group).acceptMembership(_user, msg.sender);
    People(ContractProvider(CMC).contracts("people-storage")).addGroup(_group, _user);
  }

  function declineMembership(address _group, address _user) external {
    require(Group(_group)._isOwner(msg.sender));
    Group(_group).declineMembership(_user, msg.sender);
  }

  function leaveGroup(address _group) external {
    require(Group(_group)._isMember(msg.sender));
    Group(_group).leaveGroup(msg.sender);
    People(ContractProvider(CMC).contracts("people-storage")).leaveGroup(_group, msg.sender);
  }

  function createBounty(address _group, string _title, string _issueURL, string _reference, uint _deadline, uint _reward) external {
    require(Group(_group)._isMember(msg.sender));
    bytes32 _index = Group(_group).createBounty(_title, _issueURL, _reference, _deadline, msg.sender, _reward);
    People(ContractProvider(CMC).contracts("people-storage")).addBounty(_group, _index, msg.sender);
  }

  function getBounties(address _group) external view returns (bytes32[] bounty_indices) {
    return Group(_group).getBounties();
  }

  function getBounty(address _group, bytes32 _index) external view returns (string title, string issueURL, string reference, uint timestamp, uint deadline, BountyInterface.statusOptions status, address issuer, uint reward, uint proposalCount) {
    //bytes32 _index = keccak256(abi.encodePacked(_issueURL)); //should do this in controller or bountyLib
    return Group(_group).getBounty(_index);
  }

  function createProposal(address _group, bytes32 _index, string _reference) external {
    require(Group(_group)._isMember(msg.sender));
    return Group(_group).createProposal(_index, _reference, msg.sender);
  }

  function acceptProposal(address _group, bytes32 _index, uint _id) external {
    return Group(_group).acceptProposal(_index, _id);
  }

  function getProposal(address _group, bytes32 _index, uint _id) external view returns (string, address, bool, uint) {
    return Group(_group).getProposal(_index, _id);
  }
}
