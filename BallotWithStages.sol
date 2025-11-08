// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ballot {
    struct Voter {
        uint256 weight;
        bool voted;
        uint256 vote; // index of the proposal
    }

    struct Proposal {
        uint256 voteCount;
    }

    enum Stage { Init, Reg, Vote, Done }
    Stage public stage = Stage.Init;

    address public chairperson;
    mapping(address => Voter) public voters;
    Proposal[] public proposals;

    uint256 public startTime; // marks start of current stage window

    /// Create a new ballot with `_numProposals` different proposals.
    constructor(uint256 _numProposals) {
        require(_numProposals > 0, "No proposals");
        chairperson = msg.sender;
        voters[chairperson].weight = 2; // weight is 2 for testing

        // Initialize proposals (cannot set .length directly in 0.8.x)
        for (uint256 i = 0; i < _numProposals; i++) {
            proposals.push(Proposal({voteCount: 0}));
        }

        stage = Stage.Reg;
        startTime = block.timestamp;
    }

    modifier onlyChair() {
        require(msg.sender == chairperson, "Not chairperson");
        _;
    }

    modifier atStage(Stage s) {
        require(stage == s, "Invalid stage");
        _;
    }

    /// Give `toVoter` the right to vote on this ballot.
    /// May only be called by `chairperson` during Reg stage.
    function register(address toVoter) external onlyChair atStage(Stage.Reg) {
        Voter storage v = voters[toVoter];
        require(!v.voted, "Already voted");
        require(v.weight == 0, "Already registered");

        v.weight = 1;
        // v.voted is false by default

        // After 10s from Reg start, move to Vote and reset window
        if (block.timestamp > startTime + 10 seconds) {
            stage = Stage.Vote;
            startTime = block.timestamp;
        }
    }

    /// Cast a single vote to proposal `toProposal`.
    function vote(uint256 toProposal) external atStage(Stage.Vote) {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "Already voted");
        require(sender.weight > 0, "Not registered");
        require(toProposal < proposals.length, "Invalid proposal");

        sender.voted = true;
        sender.vote = toProposal;
        proposals[toProposal].voteCount += sender.weight;

        // After 10s from Vote start, move to Done
        if (block.timestamp > startTime + 10 seconds) {
            stage = Stage.Done;
        }
    }

    function winningProposal() external view atStage(Stage.Done) returns (uint256 _winningProposal) {
        uint256 winningVoteCount = 0;
        for (uint256 p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                _winningProposal = p;
            }
        }
    }
}
