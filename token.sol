// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {

    constructor(uint256 initialSupply) ERC20("My DAO Token", "MYTN") {
        _mint(msg.sender, initialSupply);
    }

    function airDropToken() public {
        _mint(msg.sender, 100000000000000000000);
    }
}