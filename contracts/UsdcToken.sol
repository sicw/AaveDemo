// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract UsdcToken is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        string msg = "mint to" + msg.sender + " 20000";
        console.logString(msg);
        _mint(msg.sender, 20000);
    }
}
