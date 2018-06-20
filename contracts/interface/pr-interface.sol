pragma solidity ^0.4.23;

library PRInterface {
  enum statusOptions {ACTIVE, COMPLETED}

  struct PRObject {
      string title;
      string reference;
      uint timestamp;
      uint deadline;
      statusOptions status;
      address issuer;
      uint reward;
      uint changeRequestCount;
      mapping (address => uint) contributions; //Contributed to PR prize
      address[] contributers;
    }
  struct ChangeRequest {
        string reference;
        address author;
        uint timestamp;
    }

  struct PR {
    mapping (bytes32 => PRObject) pullrequests;
    mapping (bytes32 => mapping (uint => ChangeRequest)) changeRequests;
    bytes32[] PR_indices;
    uint reward;
  }

  function createPullRequest(PR storage _pullrequests, string _title, string _reference, uint deadline, address _issuer) external returns (bytes32);
  function changeReward(PR storage _pullrequests, uint _newReward) external;
  function getReward(PR storage _pullrequests) external view returns (uint);
  function getPRs(PR storage _pullrequests) external view returns (bytes32[]);
  function getPR1(PR storage _pullrequests, bytes32 _index) external view returns (string, string, uint, uint, statusOptions);
  function getPR2(PR storage _pullrequests, bytes32 _index) external view returns (address, uint, uint, address[]);
  function addContribution(PR storage _pullrequests, bytes32 _index, uint _amount, address _sender) external;
  function getContribution(PR storage _pullrequests, bytes32 _index, address _contributer) external view returns (uint);
  function approvePR(PR storage _pullrequests, bytes32 _index, address _sender) external;
  function requestChange(PR storage _pullrequests, bytes32 _index, string _reference, address _sender) external returns (uint);
  function getChangeRequest(PR storage _pullrequests, bytes32 _index, uint _id) external view returns (string, address, uint);
}
