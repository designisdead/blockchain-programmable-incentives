pragma solidity ^0.4.23;

import './registry/contract-registry.sol';
import './storage/people-storage.sol';
import './storage/timesheet-storage.sol';
import './storage/group-storage.sol';
import './token.sol';


contract Controller is Enabled {

  //CONTRIBUTE TO BOUNTIES - ADDED - ADD WITHDRAW FOR WHEN BOUNTY CANCELLED, ADD EVENT
  //CANCEL BOUNTY - ADDED - ADD WITHDRAW FOR CONTRIBUTERS IN ABANDONED STATE , ADD EVENT
  // IDEAAA ONLY CONTRIBUTE DURING ACTIVE, ONLY CANCEL DURING DRAFT --> NO WITHDRAWAL NEEDED ! ----> DONE !
  //UPDATE BOUNTY, ONLY IN DRAFT
  //ACTIVATE BOUNTY , Mint tokens on activation
  //STANDARDIZE BOUNTIES (remove issueURL, use reference instead)
  //PAYOUT MULTIPLE FULFILLERS
  //CHANGE FLOW TO PULL REQUEST/CODE REVIEW. --> // USE DRAFT OR ONLY ACTIVE -- DONE
  // WHO WILL MAKE BOUNTY, USER OR HTTP SERVER?
  event logRegistered(address indexed _wallet, string _name, string _email, string _company);
  event logUpdateProfile(address indexed _wallet, string _email, string _name, string _company, string _avatar);
  event logGroupCreated(address indexed _owner,  address indexed _address, bytes32 _name);
  event logMembershipRequested(address indexed _user, address indexed group);
  event logMembershipAccepted( address indexed _user, address indexed _group);
  event logCreateBounty(address indexed _issuer, address indexed _group, bytes32 _index);
  event logContributeToBounty(address indexed _from, address indexed _group, bytes32 _index);
  event logRequestPrChange(address indexed _group, bytes32 indexed _index, uint _id);
  event logApprovePR(address indexed _group, bytes32 indexed _index, address _approvedBy);


  function registerUser(string _name, string _email, string _company, string _avatar) external {
    require(!People(ContractProvider(CMC).contracts("people-storage"))._isRegistered(msg.sender));
    People(ContractProvider(CMC).contracts("people-storage")).registerUser(_name, _email, _company, _avatar, msg.sender);
    Token(ContractProvider(CMC).contracts("token")).mint(msg.sender, 500);
    emit logRegistered(msg.sender, _name, _email, _company);
  }

  function getUser(address _address) external view returns (string, string, string, string, address, address[]) {
    return People(ContractProvider(CMC).contracts("people-storage")).getUser(_address);
  }

  function updateUser(string _name, string _email, string _company, string _avatar) external {
    require(People(ContractProvider(CMC).contracts("people-storage"))._isRegistered(msg.sender));
    People(ContractProvider(CMC).contracts("people-storage")).updateUser(_name, _email, _company, _avatar, msg.sender);
    emit logUpdateProfile(msg.sender, _email, _name, _company, _avatar);

  }

  function createGroup(bytes32 _name, string _avatar) external {
    require(ContractProvider(CMC).groups(_name) == address(0));
    require(People(ContractProvider(CMC).contracts("people-storage"))._isRegistered(msg.sender));
    Group _group = new Group(_name, _avatar, msg.sender, CMC);
    ContractProvider(CMC).addGroup(_name, address(_group));
    People(ContractProvider(CMC).contracts("people-storage")).addGroup(address(_group), msg.sender);
    emit logGroupCreated(msg.sender, address(_group), _name);

  }

  function getGroup(address _group) external view  returns (bytes32 name, string avatar, address owner, address[] members, address[] pendingMembers, bytes32[] bounties) {
    (name, avatar, owner, members, pendingMembers) = Group(_group).getGroup();
    bounties = Group(_group).getPRs();
    return (name, avatar, owner, members, pendingMembers, bounties);
  }

  function groupMeta(address _group) external view returns (bytes32, string, address) {
    return Group(_group).groupMeta();
  }

  function requestMembership(address _group) external {
    require(People(ContractProvider(CMC).contracts("people-storage"))._isRegistered(msg.sender));
    require(!Group(_group)._isMember(msg.sender));
    require(!Group(_group)._isPending(msg.sender));
    Group(_group).requestMembership(msg.sender);
    emit logMembershipRequested(msg.sender, _group);
  }

  function acceptMembership(address _group, address _user) external {
    require(Group(_group)._isOwner(msg.sender));
    require(Group(_group)._isPending(_user));
    Group(_group).acceptMembership(_user, msg.sender);
    People(ContractProvider(CMC).contracts("people-storage")).addGroup(_group, _user);
    emit logMembershipAccepted(_user, _group);
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

  function createPR(address _group, string _title, string _reference, uint _deadline) external {
    //require(Group(_group)._isMember(msg.sender));
    bytes32 _index = Group(_group).createPR(_title, _reference, _deadline, msg.sender);
    People(ContractProvider(CMC).contracts("people-storage")).addBounty(_group, _index, msg.sender);
    emit logCreateBounty(msg.sender, _group, _index);
  }

  function getPRs(address _group) external view returns (bytes32[] PR_indices) {
    return Group(_group).getPRs();
  }

  function getPR(address _group, bytes32 _index) external view
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
        return Group(_group).getPR(_index);
      }

  function contributePR(address _group, bytes32 _index, uint _amount) external {
    require(Group(_group)._isMember(msg.sender));
    Group(_group).addContribution(_index, _amount, msg.sender);
    //token.approve() on client before calling controller.contribute()
    Token(ContractProvider(CMC).contracts("token")).transferFrom(msg.sender, _group, _amount);
    emit logContributeToBounty(msg.sender, _group, _index);
  }

  function getContribution(address _group, bytes32 _index, address _contributer) external view returns (uint) {
    return Group(_group).getContribution(_index, _contributer);
  }
  function requestPRChange(address _group, bytes32 _index, string _reference) external {
    require(Group(_group)._isMember(msg.sender));
    //require status in library for now
    uint _id = Group(_group).requestChange(_index, _reference, msg.sender);
    emit logRequestPrChange(_group, _index, _id);
  }

  function approvePR(address _group, bytes32 _index) external {
    require(Group(_group)._isMember(msg.sender));
    Group(_group).approvePR(_index, msg.sender);
    emit logApprovePR(_group, _index, msg.sender);
  }

  function getChangeRequest(address _group, bytes32 _index, uint _id) external view returns (string, address, uint) {
    return Group(_group).getChangeRequest(_index, _id);
  }

  function getReward(address _group) external view returns (uint) {
    return Group(_group).getReward();
  }

  function changeReward(address _group, uint _amount) external {
    require(Group(_group)._isOwner(msg.sender));
    return Group(_group).changeReward(_amount);
  }
}

/*function getBounty(address _group, bytes32 _index) external view returns (string title, string reference, uint timestamp, uint deadline, BountyInterface.statusOptions status, address issuer, uint reward, uint proposalCount) {
  //bytes32 _index = keccak256(abi.encodePacked(_issueURL)); //should do this in controller or bountyLib
  return Group(_group).getBounty(_index);
}*/


/*function acceptProposal(address _group, bytes32 _index, uint _id) external {
  (,,,,BountyInterface.statusOptions _status, address _issuer,,) = Group(_group).getBounty(_index);
  require(_status == BountyInterface.statusOptions.ACTIVE);
  require(msg.sender == _issuer);
  return Group(_group).acceptProposal(_index, _id);
}*/

/*function getProposal(address _group, bytes32 _index, uint _id) external view returns (string, address, bool, uint) {
  return Group(_group).getProposal(_index, _id);
}*/

  /*function createProposal(address _group, bytes32 _index, string _reference) external {
    require(Group(_group)._isMember(msg.sender));
    (,,,,BountyInterface.statusOptions _status,address _issuer,,) = Group(_group).getBounty(_index);
    require(_status == BountyInterface.statusOptions.ACTIVE);
    require(msg.sender != _issuer);
    return Group(_group).createProposal(_index, _reference, msg.sender);
  }*/

  /*function createBounty(address _group, string _title, string _reference, uint _deadline, uint _reward) external {
    require(Group(_group)._isMember(msg.sender));
    bytes32 _index = Group(_group).createBounty(_title, _reference, _deadline, msg.sender, _reward);
    People(ContractProvider(CMC).contracts("people-storage")).addBounty(_group, _index, msg.sender);
    Token(ContractProvider(CMC).contracts("token")).mint(, _reward);
    emit logCreateBounty(msg.sender, _group, _title, _reward);
  }*/

  /*function cancelBounty(address _group, bytes32 _index) external {
    Group(_group).cancelBounty(_index, msg.sender);
  }*/

  /*function getBounties(address _group) external view returns (bytes32[] bounty_indices) {
    return Group(_group).getBounties();
  }*/
