// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CollateralToken is ERC20 {

    address public creater;

    constructor(uint256 initialSupply) ERC20("CollateralToken", "CTK") {
        _mint(msg.sender, initialSupply);
        creater = msg.sender;
    }

    function buyCTK(uint256 receivedEther) public returns (string memory){
        // 计算应发送的代币数量
        uint256 tokenAmount = 100*receivedEther;
        uint256 tokenNum = balanceOf(creater);
        if (tokenNum < tokenAmount){
            // 代币不足
            return "Token not enough, ETH is back.";
        } else {
            // 发送代币给成员
            transferFrom(creater,msg.sender,tokenAmount);
            return "Buy token successfully.";
        }
    }
}