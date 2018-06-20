pragma solidity ^0.4.23;

import '../interface/bounty-interface.sol';

library BountyLib {

  function createBounty(
    BountyInterface.Bounty storage _bounty,
    string _title,
    string _reference,
    uint _deadline,
    address _issuer,
    uint _reward
  ) external returns (bytes32) {
      bytes32 _index = keccak256(abi.encodePacked(_reference));
      _bounty.bounties[_index].title = _title;
      _bounty.bounties[_index].reference = _reference;
      _bounty.bounties[_index].timestamp = block.timestamp;
      _bounty.bounties[_index].deadline = _deadline;
      _bounty.bounties[_index].status = BountyInterface.statusOptions.ACTIVE;
      _bounty.bounties[_index].issuer = _issuer;
      _bounty.bounties[_index].reward = _reward;
      _bounty.bounty_indices.push(_index);
      return _index;
  }

  function getBounties(BountyInterface.Bounty storage _bounty) external view returns (bytes32[]) {
    return _bounty.bounty_indices;
  }

  function getBounty1(BountyInterface.Bounty storage _bounty, bytes32 _index) external view returns (string, string, uint, uint) {
      return (_bounty.bounties[_index].title, _bounty.bounties[_index].reference, _bounty.bounties[_index].timestamp, _bounty.bounties[_index].deadline);
  }

  function getBounty2(BountyInterface.Bounty storage _bounty, bytes32 _index) external view returns (BountyInterface.statusOptions, address, uint, uint) {
      return (_bounty.bounties[_index].status, _bounty.bounties[_index].issuer, _bounty.bounties[_index].reward, _bounty.bounties[_index].proposalCount);
  }

  function cancelBounty(BountyInterface.Bounty storage _bounty, bytes32 _index, address _sender) external {
    require(_bounty.bounties[_index].reward == 0);
    require(_bounty.bounties[_index].status == BountyInterface.statusOptions.DRAFT);
    _bounty.bounties[_index].status == BountyInterface.statusOptions.ABANDONED;
  }

  function contribute(BountyInterface.Bounty storage _bounty, bytes32 _index, uint _amount, address _sender) external {
    require(_bounty.bounties[_index].status == BountyInterface.statusOptions.DRAFT);
    _bounty.bounties[_index].contributions[_sender] += _amount; //SAFEMATH THIS
    _bounty.bounties[_index].reward += _amount; //SAFEMATH THIS
    _bounty.bounties[_index].contributers.push(_sender);
  }

  function createProposal(BountyInterface.Bounty storage _bounty, bytes32 _index, string _reference, address _sender) external {
      require(_sender != _bounty.bounties[_index].issuer);
      _bounty.proposals[_index][_bounty.bounties[_index].proposalCount].reference = _reference;
      _bounty.proposals[_index][_bounty.bounties[_index].proposalCount].author = _sender;
      _bounty.proposals[_index][_bounty.bounties[_index].proposalCount].accepted = false;
      _bounty.proposals[_index][_bounty.bounties[_index].proposalCount].timestamp = block.timestamp;
      _bounty.bounties[_index].proposalCount++;
  }

  function getProposal(BountyInterface.Bounty storage _bounty, bytes32 _index, uint _proposalId) external view returns (string, address, bool, uint) {
      return (_bounty.proposals[_index][_proposalId].reference, _bounty.proposals[_index][_proposalId].author, _bounty.proposals[_index][_proposalId].accepted, _bounty.proposals[_index][_proposalId].timestamp);
  }

  function acceptProposal(BountyInterface.Bounty storage _bounty, bytes32 _index, uint _proposalId) external {
    _bounty.proposals[_index][_proposalId].accepted = true;
    _bounty.bounties[_index].status = BountyInterface.statusOptions.COMPLETED;
  }
}
