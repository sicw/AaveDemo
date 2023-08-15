pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";
import "../configuration/LendingPoolAddressesProvider.sol";
import "../tokenization/AToken.sol";
import "./LendingPoolCore.sol";

import "hardhat/console.sol";

contract LendingPool {

    LendingPoolCore public core;
    LendingPoolAddressesProvider public addressesProvider;

    function initialize(LendingPoolAddressesProvider _addressesProvider) public {
        addressesProvider = _addressesProvider;
        core = LendingPoolCore(addressesProvider.getLendingPoolCore());
    }

    function deposit(address _reserve, uint256 _amount, uint16 _referralCode)
    external
    payable
    {
        AToken aToken = AToken(core.getReserveATokenAddress(_reserve));

//        bool isFirstDeposit = aToken.balanceOf(msg.sender) == 0;
//        core.updateStateOnDeposit(_reserve, msg.sender, _amount, isFirstDeposit);

        //minting AToken to user 1:1 with the specific exchange rate
        aToken.mintOnDeposit(msg.sender, _amount);

        //transfer to the core contract
        core.transferToReserve.value(msg.value)(_reserve, msg.sender, _amount);
    }

    function redeemUnderlying(
        address _reserve,
        address payable _user,
        uint256 _amount,
        uint256 _aTokenBalanceAfterRedeem
    )
    external
    {
        uint256 currentAvailableLiquidity = core.getReserveAvailableLiquidity(_reserve);
        require(
            currentAvailableLiquidity >= _amount,
            "There is not enough liquidity available to redeem"
        );

        // core.updateStateOnRedeem(_reserve, _user, _amount, _aTokenBalanceAfterRedeem == 0);

        core.transferToUser(_reserve, _user, _amount);
    }

}
