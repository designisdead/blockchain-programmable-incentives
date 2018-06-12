pragma solidity ^0.4.23;

library BountyInterface {

  event logCreateBounty(address indexed _issuer, address _group, string _title, uint _reward);
  event logActivateBounty(address indexed _issuer, address _group, string _title, uint _reward);

  enum statusOptions {DRAFT, ACTIVE, COMPLETED, ABANDONED}

  struct BountyObject {
      string title;
      string issueURL;
      string reference;
      uint timestamp;
      uint deadline;
      statusOptions status;
      address issuer;
      uint reward;
      uint proposalCount;
    }
  struct Proposal {
        string reference;
        address author;
        bool accepted;
        uint timestamp;
    }

  struct Bounty {
    mapping (bytes32 => BountyObject) bounties;
    mapping (bytes32 => mapping (uint => Proposal)) proposals;
    bytes32[] bounty_indices;
  }

  function createBounty(Bounty storage _bounty, string _title, string _issueURL, string _reference, uint _deadline, address _issuer, uint _reward) external returns (bytes32);
  function getBounties(Bounty storage _bounty) external view returns (bytes32[]);
  function getBounty1(Bounty storage _bounty, bytes32 _index) external view returns (string, string, string, uint, uint);
  function getBounty2(Bounty storage _bounty, bytes32 _index) external view returns (statusOptions, address, uint, uint);
  function createProposal(Bounty storage _bounty, bytes32 _index, string _reference, address _sender) external;
  function getProposal(Bounty storage _bounty, bytes32 _index, uint _proposalId) external view returns (string, address, bool, uint);
  function acceptProposal(Bounty storage _bounty, bytes32 _index, uint _proposalId, address _sender) external;
}
