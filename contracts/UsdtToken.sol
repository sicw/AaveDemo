// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract UsdtToken is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        console.log('mint ', 20000, ' to ', msg.sender);
        _mint(msg.sender, 20000);
    }
}
