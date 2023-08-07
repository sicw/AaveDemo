// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract UsdcTokenReserve {

    address usdc = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8;

    // 映射用户地址 <-> 货币存储量
    mapping(address => uint256) public userReserve;

    // 存钱
    function supply(uint amount) public payable returns (uint total) {
        IERC20(usdc).transferFrom(msg.sender, address(this), amount);
        userReserve[msg.sender] = userReserve[msg.sender] + msg.value;
    }

    // 取钱
    function withdraw(uint amount) public returns (uint total) {
        require(userReserve[msg.sender] >= amount, "no engouh");
        userReserve[msg.sender] = userReserve[msg.sender] - amount;
        // todo 计算利息
        // this.transfer(msg.sender, amount);
    }

    // 借钱
    function borrow(uint amount) public {
        // 判断是否有足够的存款
        require(amount <= userReserve[msg.sender], "engouh");
        IERC20(usdc).transferFrom(address(this), msg.sender, amount);
        userReserve[msg.sender] = userReserve[msg.sender] - amount;
    }

    // 还钱
    function giveBack(uint amount) public {
        userReserve[msg.sender] = userReserve[msg.sender] + amount;
        IERC20(usdc).transferFrom(msg.sender, address(this), amount);
    }
}
