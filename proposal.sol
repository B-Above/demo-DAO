// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract proposalVote{
    struct Voteprocess{
        bool finish;
        uint256 yesVotes;
        uint256 noVotes;
    }

    struct Voter {
        bool exists;
        uint voteweight;
    }

    mapping(address => Voter) public voters;
    Voteprocess private pro;
    uint256 public startTime;
    uint256 public endTime;

    modifier onlyDuringVotingPeriod() {
        require(block.timestamp >= startTime && block.timestamp <= endTime, "Voting is not currently allowed");
        _;
    }

    constructor(uint256 _startTime, uint256 _endTime){
        pro = Voteprocess(false,0,0);
        startTime = _startTime;
        endTime = _endTime;
    }

//投票操作
    function vote(uint256 vote_number, bool support, uint256 total_token, address sender) public onlyDuringVotingPeriod {
               if (!voters[sender].exists){
            voters[sender] = Voter(true, total_token);
        } 
        require(!pro.finish, "Voting has already ended");
        require(voters[sender].exists, "Only registered voters can vote");
        require(vote_number <= voters[sender].voteweight, "Your token balance is not enough");

        //Proposal storage proposal = proposals[proposalIndex];
        //require(!proposal.voters[members[msg.sender]].exists,"You have already voted for this proposal");
        //require(proposal.creator != msg.sender, "The proposal creator cannot vote");

        if (support) {
            pro.yesVotes += vote_number;
            voters[sender].voteweight -= vote_number;
        } else {
            pro.noVotes += vote_number;
            voters[sender].voteweight -= vote_number;
        }
        //proposal.voters.push(members[msg.sender]);
        //members[msg.sender].hasVoted = true;
    }

    function endVoting() public {
        require(!pro.finish, "Voting has already ended");
        require(block.timestamp > endTime, "Voting period has not yet ended");

        pro.finish = true;
    }


    function proposalResult() public view
            returns (uint support, uint againest, bool pass)
    {
        support = pro.yesVotes;
        againest = pro.noVotes;
        pass = true;
        if (support < againest){
            pass = false;
        }
    }

    function restVoteWeight(address sender) public view
            returns (uint weight)
    {
        weight = voters[sender].voteweight;
    }

}