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

    constructor(){
        pro = Voteprocess(false,0,0);
    }

    function vote(uint256 voteNumber, bool support, uint256 totalToken, address sender) public{
        if (!voters[sender].exists){
            voters[sender] = Voter(true, totalToken);
        } 
        require(voteNumber <= voters[sender].voteweight, "Your token is not enough");
        //Proposal storage proposal = proposals[proposalIndex];
        //require(!proposal.voters[members[msg.sender]].exists,"You have already voted for this proposal");
        //require(proposal.creator != msg.sender, "The proposal creator cannot vote");

        if (support) {
            pro.yesVotes += voteNumber;
            voters[sender].voteweight -= voteNumber;
        } else {
            pro.noVotes += voteNumber;
            voters[sender].voteweight -= voteNumber;
        }
        //proposal.voters.push(members[msg.sender]);
        //members[msg.sender].hasVoted = true;
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