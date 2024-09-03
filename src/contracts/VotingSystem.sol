// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingSystem {
    struct Proposal {
        uint id;
        string title;
        string description;
        uint votesFor;
        uint votesAgainst;
        bool active;
        address creator;
    }

    uint public proposalCount = 0;
    mapping(uint => Proposal) public proposals;
    mapping(address => mapping(uint => bool)) public votes; // tracks if a user has voted on a proposal

    event ProposalCreated(uint id, string title, string description, address creator);
    event Voted(uint proposalId, bool voteFor, address voter);
    event TallyResult(uint proposalId, bool accepted);

    // Create a new proposal
    function createProposal(string memory _title, string memory _description) public {
        proposalCount++;
        proposals[proposalCount] = Proposal(proposalCount, _title, _description, 0, 0, true, msg.sender);
        emit ProposalCreated(proposalCount, _title, _description, msg.sender);
    }

    // Vote on a proposal
    function vote(uint _proposalId, bool _voteFor) public {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.active, "Proposal is not active");
        require(!votes[msg.sender][_proposalId], "You have already voted on this proposal");

        votes[msg.sender][_proposalId] = true;

        if (_voteFor) {
            proposal.votesFor++;
        } else {
            proposal.votesAgainst++;
        }

        emit Voted(_proposalId, _voteFor, msg.sender);
    }

    // Mark the proposal as tallied (This function will be called by the Cartesi off-chain computation)
    function tallyVotes(uint _proposalId, bool _accepted) public {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.active, "Proposal is not active");

        proposal.active = false;
        emit TallyResult(_proposalId, _accepted);
    }
}
