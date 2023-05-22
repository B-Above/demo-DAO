// SPDX-License-Identifier: GPL-3.0
import "./token.sol";

pragma solidity >=0.7.0 <0.9.0;

contract DAO {
    struct Member {
        bool exists;
        bool hasVoted;
    }

    struct Proposal {
        address creator;
        string description;
        uint256 yesVotes;
        uint256 noVotes;
        Member[] voters;
    }


    mapping(address => Member) public members;
    MyToken private MYTN;  // 创建MYTN的实例
    Proposal[] public proposals;

    modifier onlyMember() {
        require(members[msg.sender].exists, "Only members can call this function");
        _;
    }

    constructor(uint256 initialSupply){
        createToken(initialSupply);
    }

    function createToken(uint256 _number) private {
        MYTN = new MyToken(_number);  // 创建DAO token的实例并保存在MYTN中
    }

    function joinDAO() external payable {
        require(!members[msg.sender].exists, "You are already a member");

        members[msg.sender] = Member(true, false);
    }

    function createProposal(string memory description) external onlyMember {
        proposals.push(Proposal({
            creator: msg.sender,
            description: description,
            yesVotes: 0,
            noVotes: 0
        }));
    }
    
    function vote(uint256 proposalIndex, bool support) external onlyMember {
        require(proposalIndex < proposals.length, "Invalid proposal index");
        //require(!members[msg.sender].hasVoted, "You have already voted for this proposal");
        
        Proposal storage proposal = proposals[proposalIndex];
        require(!proposal.voters[members[msg.sender]].exists,"You have already voted for this proposal");
        //require(proposal.creator != msg.sender, "The proposal creator cannot vote");

        if (support) {
            proposal.yesVotes++;
        } else {
            proposal.noVotes++;
        }
        proposal.voters.push(members[msg.sender]);
        //members[msg.sender].hasVoted = true;
    }

    function Proposalresult(uint proID) public view
            returns (uint support, uint againest, bool pass)
    {
        support = proposals[proID].yesVotes;
        againest = proposals[proID].noVotes;
        pass = true;
        if (support < againest){
            pass = false;
        }
    }

    receive() external payable {
        // 获取接收到的以太币数量
        uint256 receivedEther = msg.value;

        // 计算应发送的代币数量
        uint256 tokenAmount = receivedEther / 0.1;

        // 向发送方发送代币
        _mint(msg.sender, tokenAmount);
    }

   

    fallback() external { x = 1; }
    uint x;
}