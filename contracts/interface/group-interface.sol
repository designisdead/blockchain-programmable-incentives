pragma solidity ^0.4.23;

library GroupInterface {
  struct Group {
    string name;
    string avatar;
    address owner;
    address[] members;
    address[] pendingMembers;
  }
  event logGroupCreated(string _name, address _owner);
  event logMembershipRequested(address indexed group, address indexed user);

  function getGroup(Group storage _group) external view returns (string, string, address, address[], address[]);
  function requestMembership(Group storage _group, address _sender) external;
  function acceptMembership(Group storage _group, address _pending, address _sender) external;
  function declineMembership(Group storage _group, address _pending, address _sender) external;
  function leaveGroup(Group storage _group, address _sender) external;
  function _isMember(Group storage _group, address _sender) external view returns (bool);
  function _isPending(Group storage _group, address _sender) external view returns (bool);
  function _isOwner(Group storage _group, address _sender) external view returns (bool);
}
