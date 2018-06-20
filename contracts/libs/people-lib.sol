pragma solidity ^0.4.23;

import '../interface/people-interface.sol';

library PeopleLib {

  function registerUser(PeopleInterface.People storage _people, string _name, string _email, string _company, string _avatar, address _sender) external {
      require(_people.people[_sender].wallet == address(0));
      _people.people[_sender].name = _name;
      _people.people[_sender].email = _email;
      _people.people[_sender].company = _company;
      _people.people[_sender].avatar = _avatar;
      _people.people[_sender].wallet = _sender;
  }

  function updateUser(PeopleInterface.People storage _people, string _name, string _email, string _company, string _avatar, address _sender) external {
    require(_people.people[_sender].wallet == _sender);
    _updateName(_people, _name, _sender);
    _updateEmail(_people, _email, _sender);
    _updateCompany(_people, _company, _sender);
    _updateAvatar(_people, _avatar, _sender);
  }

  function _updateName(PeopleInterface.People storage _people, string _name, address _sender) public {
    bytes memory name = bytes(_name);
    if (name.length > 0) _people.people[_sender].name = _name;
  }

  function _updateEmail (PeopleInterface.People storage _people, string _email, address _sender) public {
    bytes memory email = bytes(_email);
    if (email.length > 0) _people.people[_sender].email = _email;
  }

  function _updateCompany (PeopleInterface.People storage _people, string _company, address _sender) public {
      bytes memory company = bytes(_company);
      if (company.length > 0) _people.people[_sender].company = _company;
  }

  function _updateAvatar (PeopleInterface.People storage _people, string _avatar, address _sender) public {
      bytes memory avatar = bytes(_avatar);
      if (avatar.length > 0) _people.people[_sender].avatar = _avatar;
  }

  function getUser (PeopleInterface.People storage _people, address _address) external view returns (string, string, string, string, address, address[]) {
      address[] memory _groups = _getGroups(_people, _address);
      return (_people.people[_address].name, _people.people[_address].email, _people.people[_address].company, _people.people[_address].avatar, _address, _groups);
  }

  function _getGroups(PeopleInterface.People storage _people, address _address) public view returns (address[]) {
    return _people.people[_address].groups;
  }

  function addGroup (PeopleInterface.People storage _people, address _group, address _user) external {
      _people.people[_user].groups.push(_group);
  }

  function leaveGroup (PeopleInterface.People storage _people, address _group, address _sender) external {
    require(_people.people[_sender].wallet == _sender);
    for (uint i = 0; i < _people.people[_sender].groups.length; i ++) {
      if ( _group == _people.people[_sender].groups[i] ) {
        _people.people[_sender].groups = _deleteAddress(_people.people[_sender].groups, i);
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

  function addBounty (PeopleInterface.People storage _people, address _group, bytes32 _index, address _sender) external {
     require(_people.people[_sender].wallet == _sender);
    _people.people[_sender].personBounties[_group].push(_index);
  }

  function getUserBountiesByGroup (PeopleInterface.People storage _people, address _group, address _sender) external view returns (bytes32 []) {
    return _people.people[_sender].personBounties[_group];
  }

  function _isRegistered (PeopleInterface.People storage _people, address _sender) external view returns (bool) {
    bytes memory email = bytes(_people.people[_sender].email);
    if (email.length > 0) {
      return true;
    } else {
      return false;
    }
  }
}
