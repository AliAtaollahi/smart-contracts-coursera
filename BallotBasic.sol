// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ballot {
    struct Voter {
        uint256 weight;
        bool voted;
        uint256 vote; // index of the voted proposal
        // address delegate; // left out since it was commented in the original
    }

    struct Proposal {
        uint256 voteCount; // you could add more fields later
    }

    address public chairperson;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    modifier onlyChair() {
        require(msg.sender == chairperson, "Not chairperson");
        _;
    }

    /// Create a new ballot with `_numProposals` different proposals.
    constructor(uint256 _numProposals) {
        chairperson = msg.sender;
        voters[chairperson].weight = 2;

        // Initialize proposals array (length assignment is not allowed in 0.8.x)
        for (uint256 i = 0; i < _numProposals; i++) {
            proposals.push(Proposal({voteCount: 0}));
        }
    }

    /// Give `toVoter` the right to vote on this ballot.
    /// May only be called by `chairperson`.
    function register(address toVoter) external onlyChair {
        Voter storage v = voters[toVoter];
        require(!v.voted, "Already voted");
        require(v.weight == 0, "Already registered");
        v.weight = 1;
        // v.voted is false by default
    }

    /// Give a single vote to proposal `toProposal`.
    function vote(uint256 toProposal) external {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "Already voted");
        require(toProposal < proposals.length, "Invalid proposal");

        sender.voted = true;
        sender.vote = toProposal;
        proposals[toProposal].voteCount += sender.weight;
    }

    function winningProposal() external view returns (uint256 _winningProposal) {
        uint256 winningVoteCount = 0;
        for (uint256 p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                _winningProposal = p;
            }
        }
    }
}
