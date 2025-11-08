// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ballot {
    struct Voter {
        uint256 weight;
        bool voted;
        uint256 vote;     // index of the proposal
        address delegate; // kept for parity with the original (unused)
    }

    struct Proposal {
        uint256 voteCount;
    }

    enum Stage { Init, Reg, Vote, Done }
    Stage public stage = Stage.Init;

    address public chairperson;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    event VotingCompleted();

    uint256 public startTime;

    // --- Modifiers ---
    modifier validStage(Stage reqStage) {
        require(stage == reqStage, "Invalid stage");
        _;
    }

    modifier onlyChair() {
        require(msg.sender == chairperson, "Not chairperson");
        _;
    }

    /// Create a new ballot with `_numProposals` proposals.
    constructor(uint256 _numProposals) {
        require(_numProposals > 0, "No proposals");
        chairperson = msg.sender;
        voters[chairperson].weight = 2; // weight is 2 for testing purposes

        // Initialize proposals (can't set .length directly in 0.8.x)
        for (uint256 i = 0; i < _numProposals; i++) {
            proposals.push(Proposal({voteCount: 0}));
        }

        stage = Stage.Reg;
        startTime = block.timestamp;
    }

    /// Give `toVoter` the right to vote.
    /// Only the chairperson can register voters during Reg stage.
    function register(address toVoter) external validStage(Stage.Reg) onlyChair {
        Voter storage v = voters[toVoter];
        require(!v.voted, "Already voted");
        require(v.weight == 0, "Already registered");

        v.weight = 1;
        // v.voted is false by default

        if (block.timestamp > startTime + 30 seconds) {
            stage = Stage.Vote;
        }
    }

    /// Cast a single vote to proposal `toProposal`.
    function vote(uint256 toProposal) external validStage(Stage.Vote) {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "Already voted");
        require(sender.weight > 0, "Not registered");
        require(toProposal < proposals.length, "Invalid proposal");

        sender.voted = true;
        sender.vote = toProposal;
        proposals[toProposal].voteCount += sender.weight;

        if (block.timestamp > startTime + 30 seconds) {
            stage = Stage.Done;
            emit VotingCompleted();
        }
    }

    /// Return index of the winning proposal (requires Done stage).
    function winningProposal() external view validStage(Stage.Done) returns (uint256 _winningProposal) {
        uint256 winningVoteCount = 0;
        for (uint256 p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                _winningProposal = p;
            }
        }
        require(winningVoteCount > 0, "No votes cast");
    }
}
