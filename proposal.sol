// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract ProposalVote{
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

    constructor(){
        pro = Voteprocess(false,0,0);
    }

    function vote(uint256 vote_number, bool support, uint256 total_token, address sender) public{
        if (!voters[sender].exists){
            voters[sender] = Voter(true, total_token);
        } 
        require(vote_number <= voters[sender].voteweight, "Your token is not enough");
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

    function Proposalresult() public view
            returns (uint support, uint againest, bool pass)
    {
        support = pro.yesVotes;
        againest = pro.noVotes;
        pass = true;
        if (support < againest){
            pass = false;
        }
    }

    function RestVoteWeight(address sender) public view
            returns (uint weight)
    {
        weight = voters[sender].voteweight;
    }

}