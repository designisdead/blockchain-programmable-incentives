pragma solidity ^0.4.23;

library PeopleInterface {
    struct Person {
      string name;
      string email;
      string company;
      string avatar;
      address wallet;
      address[] groups;
      mapping (address => bytes32[]) personBounties; //groupaddress -> bounty id's use controller.getBounty(_groupAddress, bountyId)
    }

    struct People {
      mapping (address => Person) people;
    }

    function registerUser(People storage _people, string _name, string _email, string _company, string _avatar, address _sender) external;
    function updateUser(People storage _people, string _name, string _email, string _company, string _avatar, address _sender) external;
    function getUser(People storage _people, address _address) external view returns (string, string, string, string, address, address[]);
    function addGroup(People storage _people, address _group, address _user, address _sender) external;
    function leaveGroup(People storage _people, address _group, address _sender) external;
    function addBounty(People storage _people, address _group, bytes32 _index, address _sender) external;
    function getUserBountiesByGroup(People storage _people, address _group, address _sender) external view returns (bytes32 []);
    function _isRegistered (PeopleInterface.People storage _people, address _sender) external returns (bool);
}
