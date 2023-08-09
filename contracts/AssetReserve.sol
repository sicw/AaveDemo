// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./UsdcToken.sol";

contract AssetReserve {

    struct AssetData {
        uint assetReserve;  // 资产纬度数据
    }

    struct UserData {
        uint assetReserve;      // 资产数量
        uint mortgageReserve;   // 抵押资产
    }

    // 资产地址 => 资产数据
    mapping(address => AssetData) public assetReserve;

    // 资产地址 => 用户地址 => 用户数据
    mapping(address => mapping(address => UserData)) public userAsset;

    // 存钱
    function supply(address asset, uint amount) public {
        console.log('supply msg.sender', msg.sender, 'amount', amount);

        console.log('before supply balance', IERC20(asset).balanceOf(address(this)));
        IERC20(asset).transferFrom(msg.sender, address(this), amount);
        assetReserve[asset].assetReserve = assetReserve[asset].assetReserve + amount;
        userAsset[asset][msg.sender].assetReserve = userAsset[asset][msg.sender].assetReserve + amount;
        console.log('after supply balance', IERC20(asset).balanceOf(address(this)));
    }

    //    // 取钱
    //    function withdraw(uint amount) public returns (bool ret) {
    //        console.log('before withdraw balance', usdctoken(usdc).balanceof(address(this)));
    //        require(assetreserve[msg.sender] >= amount, "no engouh");
    //        assetreserve[msg.sender] = assetreserve[msg.sender] - amount;
    //        ret = ierc20(usdc).transfer(msg.sender, amount);
    //        console.log('after withdraw balance', usdctoken(usdc).balanceof(address(this)));
    //        // todo 计算利息
    //    }
    //
    //    // 借钱
    //    function borrow(uint amount) public {
    //        // 判断是否有足够的存款
    //        require(amount <= assetreserve[msg.sender], "engouh");
    //        ierc20(usdc).transferfrom(address(this), msg.sender, amount);
    //        assetreserve[msg.sender] = assetreserve[msg.sender] - amount;
    //    }
    //
    //    // 还钱
    //    function giveback(uint amount) public {
    //        assetreserve[msg.sender] = assetreserve[msg.sender] + amount;
    //        ierc20(usdc).transferfrom(msg.sender, address(this), amount);
    //    }
}
