pragma solidity ^0.4.23;

import '../interface/people-interface.sol';
import '../registry/enabled.sol';

contract People is Enabled {
  using PeopleInterface for PeopleInterface.People;
  PeopleInterface.People people;

  event logRegistered(address indexed _wallet, string _name, string _email, string _company);
  event logUpdateProfile(address indexed _wallet, string _email, string _name, string _company, string _avatar);

  function registerUser(string _name, string _email, string _company, string _avatar, address _sender) external isEnabled("controller") {
    return people.registerUser(_name, _email, _company, _avatar, _sender);
  }

  function updateUser(string _name, string _email, string _company, string _avatar, address _sender) external isEnabled("controller") {
    return people.updateUser(_name, _email, _company, _avatar, _sender);
  }

  function getUser(address _wallet) external view isEnabled("controller") returns (string, string, string, string, address, address[]) {
    return people.getUser(_wallet);
  }

  function addGroup(address _group, address _user) external isEnabled("controller") {
    return people.addGroup(_group, _user);
  }

  function leaveGroup(address _group, address _sender) external isEnabled("controller") {
    return people.leaveGroup(_group, _sender);
  }

  function addBounty(address _group, bytes32 _index, address _sender) external isEnabled("controller") {
    return people.addBounty(_group, _index, _sender);
  }

  function _isRegistered(address _user) external returns (bool) {
    return people._isRegistered(_user);
  }
}
