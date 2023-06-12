// SPDX-License-Identifier: GPL-3.0
import "./token.sol";
import "./proposal.sol";

pragma solidity >=0.8.0 <0.9.0;

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
    uint256 startTime;  // 添加startTime字段
    uint256 endTime;  // 添加endTime字段
    //ProposalVote pv;
}
//存储成员信息的映射
    string public name;
    mapping(address => Member) public members;
    // 存储提案投票合约的映射
    mapping(uint256 => proposalVote) private pros;
    MyToken private mytn;  // 创建mytn的实例
    // 提案列表
    Proposal[] public proposals;
    // 供应量
    uint private supplynumber;

 // 限制只有成员可以调用的修饰符
    modifier onlyMember() {
        require(members[msg.sender].exists, "Only members can call this function");
        _;
    }

    //初始化合约的初始状态

    constructor(uint256 initialSupply,string memory _name){
        createToken(initialSupply);
        supplynumber = initialSupply;
        name = _name;
    }

// 创建代币实例
    function createToken(uint256 _number) private {
        mytn = new MyToken(_number);  // 创建DAO token的实例并保存在mytn中
    }

    function joinDAO() external payable returns (string memory) {
        require(!members[msg.sender].exists, "You are already a member");
        // 获取接收到的以太币数量
        uint256 receivedEther = msg.value;
        // 计算应发送的代币数量
        uint256 tokenAmount = 10*receivedEther;
        uint256 tokenNum = checkTokenOfDAO();
        if (tokenNum < tokenAmount){
            // 代币不足，将以太币退回
            payable(msg.sender).transfer(receivedEther);
            members[msg.sender] = Member(true, 0);
            string  memory message = "You are already a member, but token not enough, ETH is back.";
            return message;
        } else {
            // 发送代币给成员
            mytn.transfer(msg.sender,tokenAmount);
            members[msg.sender] = Member(true, tokenAmount);
            string  memory message = "You are a member now.";
            return message;
        }
        
    }

// 购买代币
    function buyToken() external payable returns (string memory) {
        require(members[msg.sender].exists, "You are no a member, please join DAO first");
        uint256 receivedEther = msg.value;
        // 计算应发送的代币数量
        uint256 tokenAmount = 10*receivedEther;
        uint256 tokenNum = checkTokenOfDAO();
        if (tokenNum < tokenAmount){
            // 代币不足，将以太币退回
            payable(msg.sender).transfer(receivedEther);
            return "Token not enough, ETH is back.";
        } else {
            // 发送代币给成员
            mytn.transfer(msg.sender,tokenAmount);
            members[msg.sender].tokens += tokenAmount;
            return "Buy token successfully.";
        }
    }
// 查询成员自身持有的代币数量
    function checkTokenOfMe() public view onlyMember returns (uint256) {
        return mytn.balanceOf(msg.sender);
    }
//查询调用者（成员）在DAO合约中拥有的代币数量
    function checkTokenOfDAO() public view returns (uint256) {
        return mytn.balanceOf(address(this));
    }
//查询DAO合约本身拥有的代币数量
    function checkTokens() public view returns (uint256) {
        return members[msg.sender].tokens;
    }
//创建提案

function createProposal(string memory description, uint256 duration) external onlyMember {
    // require(startTime < endTime, "Invalid time range");

    uint256 startTime = block.timestamp; // 当前时间作为开始时间
    uint256 endTime = startTime + duration; // 开始时间加持续时间（单位秒）

    uint256 id = proposals.length;
    proposals.push(
        Proposal({
            creator: msg.sender,
            description: description,
            index: id,
            startTime: startTime,
            endTime: endTime
        })
    );
    pros[id] = new proposalVote();
}

    
    function vote(uint256 proposalIndex, bool support, uint256 voteNum) external onlyMember {
        require(proposalIndex < proposals.length, "Invalid proposal index");
        Proposal storage pro = proposals[proposalIndex];
        proposalVote prov = pros[pro.index];
        prov.vote(voteNum,support,members[msg.sender].tokens,msg.sender);
    }


//查询提案的投票结果
    function proposalResult(uint proID) public view
            returns (uint support, uint againest, bool pass)
    {
        (support,againest,pass) = pros[proposals[proID].index].proposalResult();
    }




//调用者（成员）在指定提案中剩余的投票权重
    function checkWeight(uint proIndex) public view
            returns (uint weight)
    {
        require(proIndex < proposals.length, "Invalid proposal index");
        Proposal storage proposal = proposals[proIndex];
        weight = pros[proposal.index].restVoteWeight(msg.sender);
    }

    
//这是一个receive函数，用于接收以太币支付
    receive() external payable{
        // 获取接收到的以太币数量
        uint256 receivedEther = msg.value;
        payable(msg.sender).transfer(receivedEther);
    }

    function callJoinFunction(uint256 param,address to) external {
        // 向在to地址的智能合约发送交易来调用 join 函数
        (bool success, ) = to.call{value: param}(abi.encodeWithSignature("joinDAO()"));
        require(success, "Join function call failed");
    }

    function callVoteFunction(uint256 proposalIndex, bool support, uint256 voteNum,address to) external {
        // 向在to地址的智能合约发送交易来调用 vote 函数
        (bool success, ) = to.call(abi.encodeWithSignature("vote(uint256,bool,uint256)", proposalIndex,support,voteNum));
        require(success, "Vote function call failed");
    }

}