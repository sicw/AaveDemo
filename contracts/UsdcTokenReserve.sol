// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";

contract UsdcTokenReserve {

    // 映射用户地址 <-> 货币存储量
    mapping(address => uint256) public userReserve;

    // 存钱
    function supply() public payable returns (uint total) {
        userReserve[msg.sender] = userReserve[msg.sender] + msg.value;
        total = this.balance;
    }

    // 取钱
    function withdraw(uint amount) returns (uint total){
        userReserve[msg.sender] = userReserve[msg.sender] - amount;
        // todo 计算利息
        this.transfer(msg.sender, amount);
    }
}
