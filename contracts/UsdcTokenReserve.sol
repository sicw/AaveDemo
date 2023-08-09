// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./UsdcToken.sol";

contract UsdcTokenReserve {

    address public usdc;

    // 映射用户地址 <-> 货币存储量
    mapping(address => uint256) public userReserve;

    function setUsdcAddress(address addr) public {
        usdc = addr;
    }

    // 存钱
    function supply(uint amount) public {
        console.log('supply msg.sender', msg.sender, 'amount', amount);

        console.log('before supply balance', UsdcToken(usdc).balanceOf(address(this)));
        UsdcToken(usdc).transferFrom(msg.sender, address(this), amount);
        userReserve[msg.sender] = userReserve[msg.sender] + amount;
        console.log('after supply balance', UsdcToken(usdc).balanceOf(address(this)));
    }

    // 取钱
    function withdraw(uint amount) public returns (bool ret) {
        console.log('before withdraw balance', UsdcToken(usdc).balanceOf(address(this)));
        require(userReserve[msg.sender] >= amount, "no engouh");
        userReserve[msg.sender] = userReserve[msg.sender] - amount;
        ret = UsdcToken(usdc).transfer(msg.sender, amount);
        console.log('after withdraw balance', UsdcToken(usdc).balanceOf(address(this)));
        // todo 计算利息
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
