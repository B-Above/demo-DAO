// SPDX-License-Identifier: GPL-3.0
import "./token.sol";
import "./proposal.sol";

pragma solidity >=0.7.0 <0.9.0;

contract DAO {
    struct Member {
        bool exists;
        uint tokens;
        //bool hasVoted;
    }

    struct Proposal {
        address creator;
        string description;
        uint256 index;
        //ProposalVote pv;
    }


    mapping(address => Member) public members;
    mapping(uint256 => ProposalVote) private pros;
    MyToken private MYTN;  // 创建MYTN的实例
    Proposal[] public proposals;
    uint private supplynumber;

    modifier onlyMember() {
        require(members[msg.sender].exists, "Only members can call this function");
        _;
    }

    constructor(uint256 initialSupply){
        createToken(initialSupply);
        supplynumber = initialSupply;
    }

    function createToken(uint256 _number) private {
        MYTN = new MyToken(_number);  // 创建DAO token的实例并保存在MYTN中
    }

    function joinDAO() external payable returns (string memory) {
        require(!members[msg.sender].exists, "You are already a member");
        // 获取接收到的以太币数量
        uint256 receivedEther = msg.value;
        // 计算应发送的代币数量
        uint256 tokenAmount = 10*receivedEther;
        uint256 token_num = CheckTokenOfDAO();
        if (token_num < tokenAmount){
            payable(msg.sender).transfer(receivedEther);
            members[msg.sender] = Member(true, 0);
            string  memory message = "You are already a member, but token not enough, ETH is back.";
            return message;
        } else {
            MYTN.transfer(msg.sender,tokenAmount);
            members[msg.sender] = Member(true, tokenAmount);
            string  memory message = "You are a member now.";
            return message;
        }
        
    }

    function buyToken() external payable returns (string memory) {
        require(members[msg.sender].exists, "You are no a member, please join DAO first");
        uint256 receivedEther = msg.value;
        // 计算应发送的代币数量
        uint256 tokenAmount = 10*receivedEther;
        uint256 token_num = CheckTokenOfDAO();
        if (token_num < tokenAmount){
            payable(msg.sender).transfer(receivedEther);
            return "Token not enough, ETH is back.";
        } else {
            MYTN.transfer(msg.sender,tokenAmount);
            members[msg.sender].tokens += tokenAmount;
            return "Buy token successfully.";
        }
    }

    function CheckTokenOfMe() public view onlyMember returns (uint256) {
        return MYTN.balanceOf(msg.sender);
    }

    function CheckTokenOfDAO() public view returns (uint256) {
        return MYTN.balanceOf(address(this));
    }

    function CheckTokens() public view returns (uint256) {
        return members[msg.sender].tokens;
    }

    function createProposal(string memory description) external onlyMember {
        uint256 id =  proposals.length;
        proposals.push(Proposal({
            creator: msg.sender,
            description: description,
            index: id
            //pv: new ProposalVote()
        }));
        pros[id] = new ProposalVote();
    }
    
    function vote(uint256 proposalIndex, bool support, uint256 vote_num) external onlyMember {
        require(proposalIndex < proposals.length, "Invalid proposal index");
        Proposal storage pro = proposals[proposalIndex];
        ProposalVote prov = pros[pro.index];
        prov.vote(vote_num,support,members[msg.sender].tokens,msg.sender);
    }

    function Proposalresult(uint proID) public view
            returns (uint support, uint againest, bool pass)
    {
        (support,againest,pass) = pros[proposals[proID].index].Proposalresult();
    }

    function CheckWeight(uint proIndex) public view
            returns (uint weight)
    {
        require(proIndex < proposals.length, "Invalid proposal index");
        Proposal storage proposal = proposals[proIndex];
        weight = pros[proposal.index].RestVoteWeight(msg.sender);
    }

    receive() external payable{
        // 获取接收到的以太币数量
        uint256 receivedEther = msg.value;
        payable(msg.sender).transfer(receivedEther);
    }

   
    fallback() external { x = 1; }
    uint x;
}