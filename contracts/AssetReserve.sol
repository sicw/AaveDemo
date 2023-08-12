// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./UsdcToken.sol";

contract AssetReserve {

    uint interestRate = 10;

    struct AssetData {
        uint assetReserve;      // 资产维度数量
        uint interestReserve;   // (借贷or闪电贷)利息收益
    }

    struct UserData {
        uint assetReserve;      // 用户资产数量
        uint mortgageReserve;   // 用户抵押资产数量

        uint borrowReserve;     // 借了多少资产
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
        assetReserve[asset].assetReserve += amount;
        userAsset[asset][msg.sender].assetReserve += amount;
        console.log('after supply balance', IERC20(asset).balanceOf(address(this)));
    }

    // 取钱
    function withdraw(address asset, uint amount) public returns (bool ret) {
        console.log('before withdraw balance', IERC20(asset).balanceOf(address(this)));
        require(userAsset[asset][msg.sender].assetReserve >= amount, "no engouh");
        userAsset[asset][msg.sender].assetReserve -= amount;
        assetReserve[asset].assetReserve -= amount;
        ret = IERC20(asset).transfer(msg.sender, amount);
        // todo 计算利息
        console.log('after withdraw balance', IERC20(asset).balanceOf(address(this)));
    }

    /*
       借款
       借USDT 抵押USDC
       总USDT -
       个人USDT存款 +
       个人USDC存款 -
       个人USDC抵押 +
    */
    function borrow(address borrowAsset, address mortgageAsset, uint amount) public {
        // todo 判断是否有足够的同等价值的资产
        //require(amount <= assetreserve[msg.sender], "engouh");】

        // 扣除超额抵押资产到另外地址(用户)
        userAsset[mortgageAsset][msg.sender].assetReserve -= amount;
        userAsset[mortgageAsset][msg.sender].mortgageReserve += amount;

        userAsset[borrowAsset][msg.sender].borrowReserve += amount;

        // 减少总资产中借出去的部分(总资产)
        assetReserve[borrowAsset].assetReserve -= amount;

        // 转移资产给msg.sender
        IERC20(borrowAsset).transfer(msg.sender, amount);

        console.log('borrowAsset balance', IERC20(borrowAsset).balanceOf(address(this)));
        console.log('borrowAsset reserve', assetReserve[borrowAsset].assetReserve);
        console.log('msg.sender mortgageAsset reserve', userAsset[mortgageAsset][msg.sender].mortgageReserve);
        console.log('msg.sender oriAsset reserve', userAsset[mortgageAsset][msg.sender].assetReserve);
        console.log('msg.sender borrow balance', IERC20(borrowAsset).balanceOf(msg.sender));
    }

    /*
        还款
        还USDT 抵押UDSC
        总USDT +
        个人USDT存款 -
        个人USDC存款 +
        个人USDC抵押 -
    */
    function repay(address borrowAsset, address mortgageAsset, uint amount) public {
        // 需要归还利息
        require(amount >= interestRate + userAsset[borrowAsset][msg.sender].borrowReserve, 'repay not enough interest');

        // 归还资产
        IERC20(borrowAsset).transferFrom(msg.sender, address(this), amount);

        // 增加总资产(当时借出的)
        assetReserve[borrowAsset].assetReserve += userAsset[borrowAsset][msg.sender].borrowReserve;
        // 收益增加
        assetReserve[borrowAsset].interestReserve += amount - userAsset[borrowAsset][msg.sender].borrowReserve;

        // 每次归还都必须还完
        userAsset[borrowAsset][msg.sender].borrowReserve = 0;

        // 修改用户抵押数量
        userAsset[mortgageAsset][msg.sender].assetReserve += userAsset[borrowAsset][msg.sender].borrowReserve;
        userAsset[mortgageAsset][msg.sender].mortgageReserve -= userAsset[borrowAsset][msg.sender].borrowReserve;
    }

    /*
        可以多次借出
        等额抵押
        归还 + 10

        收益和存储量分开存 画个图
    */
}
