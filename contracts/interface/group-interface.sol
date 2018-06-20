pragma solidity ^0.4.23;

library GroupInterface {
  struct Group {
    bytes32 name;
    string avatar;
    address owner;
    address[] members;
    address[] pendingMembers;
  }

  function getGroup(Group storage _group) external view returns (bytes32, string, address, address[], address[]);
  function groupMeta(Group storage _group) external view returns (bytes32, string, address);
  function requestMembership(Group storage _group, address _sender) external;
  function acceptMembership(Group storage _group, address _pending, address _sender) external;
  function declineMembership(Group storage _group, address _pending, address _sender) external;
  function leaveGroup(Group storage _group, address _sender) external;
  function _isMember(Group storage _group, address _sender) external view returns (bool);
  function _isPending(Group storage _group, address _sender) external view returns (bool);
  function _isOwner(Group storage _group, address _sender) external view returns (bool);
}
