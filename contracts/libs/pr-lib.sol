pragma solidity ^0.4.23;

import '../interface/pr-interface.sol';
import '../util/SafeMath.sol';

library PRLib {
  using SafeMath for uint;

  function changeReward(PRInterface.PR storage _pullrequests, uint _newReward) {
    _pullrequests.reward = _newReward;
  }

  function getReward(PRInterface.PR storage _pullrequests) external view returns (uint) {
    return _pullrequests.reward;
  }

  function createPullRequest(PRInterface.PR storage _pullrequests, string _title, string _reference, uint _deadline, address _issuer) external returns (bytes32) {
    bytes32 _index = keccak256(_reference);
    _pullrequests.PR_indices.push(_index);
    _pullrequests.pullrequests[_index].title = _title;
    _pullrequests.pullrequests[_index].reference = _reference;
    _pullrequests.pullrequests[_index].timestamp = block.timestamp;
    _pullrequests.pullrequests[_index].deadline = _deadline;
    _pullrequests.pullrequests[_index].status = PRInterface.statusOptions.ACTIVE;
    _pullrequests.pullrequests[_index].issuer = _issuer;
    _pullrequests.pullrequests[_index].reward = _pullrequests.reward;
    return _index;
  }

  function getPRs(PRInterface.PR storage _pullrequests) external view returns (bytes32[]) {
    return _pullrequests.PR_indices;
  }

  function getPR1(PRInterface.PR storage _pullrequests, bytes32 _index) external view returns (string, string, uint, uint, PRInterface.statusOptions) {
      return (_pullrequests.pullrequests[_index].title, _pullrequests.pullrequests[_index].reference, _pullrequests.pullrequests[_index].timestamp, _pullrequests.pullrequests[_index].deadline, _pullrequests.pullrequests[_index].status);
  }

  function getPR2(PRInterface.PR storage _pullrequests, bytes32 _index) external view returns (address, uint, uint, address[]) {
      return (_pullrequests.pullrequests[_index].issuer, _pullrequests.pullrequests[_index].reward, _pullrequests.pullrequests[_index].changeRequestCount, _pullrequests.pullrequests[_index].contributers);
  }

  function addContribution(PRInterface.PR storage _pullrequests, bytes32 _index, uint _amount, address _sender) external {
    require(_pullrequests.pullrequests[_index].status == PRInterface.statusOptions.ACTIVE);
    _pullrequests.pullrequests[_index].contributions[_sender] = _pullrequests.pullrequests[_index].contributions[_sender].add(_amount);
    _pullrequests.pullrequests[_index].reward = _pullrequests.pullrequests[_index].reward.add(_amount);
    _pullrequests.pullrequests[_index].contributers.push(_sender);
  }

  function getContribution(PRInterface.PR storage _pullrequests, bytes32 _index, address _contributer) returns (uint) {
    return _pullrequests.pullrequests[_index].contributions[_contributer];
  }

  function requestChange(PRInterface.PR storage _pullrequests, bytes32 _index, string _reference, address _sender) external returns (uint){
    require(_pullrequests.pullrequests[_index].status == PRInterface.statusOptions.ACTIVE);
    uint count = _pullrequests.pullrequests[_index].changeRequestCount;
    _pullrequests.changeRequests[_index][_pullrequests.pullrequests[_index].changeRequestCount].reference = _reference;
    _pullrequests.changeRequests[_index][_pullrequests.pullrequests[_index].changeRequestCount].author = _sender;
    _pullrequests.changeRequests[_index][_pullrequests.pullrequests[_index].changeRequestCount].timestamp = block.timestamp;
    _pullrequests.pullrequests[_index].changeRequestCount++;
    return count;
  }

  function approvePR(PRInterface.PR storage _pullrequests, bytes32 _index, address _sender) external {
    require(_pullrequests.pullrequests[_index].issuer != _sender);
    require(_pullrequests.pullrequests[_index].status == PRInterface.statusOptions.ACTIVE);
    _pullrequests.pullrequests[_index].status = PRInterface.statusOptions.COMPLETED;
  }

  function getChangeRequest(PRInterface.PR storage _pullrequests, bytes32 _index, uint _id) external view returns (string, address, uint) {
    return (_pullrequests.changeRequests[_index][_id].reference, _pullrequests.changeRequests[_index][_id].author, _pullrequests.changeRequests[_index][_id].timestamp);
  }
}
