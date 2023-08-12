pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";
import "../configuration/LendingPoolAddressesProvider.sol";
import "../tokenization/AToken.sol";
import "./LendingPoolCore.sol";

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

        //minting AToken to user 1:1 with the specific exchange rate
        aToken.mintOnDeposit(msg.sender, _amount);

        //transfer to the core contract
        core.transferToReserve.value(msg.value)(_reserve, msg.sender, _amount);
    }
}
