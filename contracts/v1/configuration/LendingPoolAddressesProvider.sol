pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "./AddressStorage.sol";

/**
* @title LendingPoolAddressesProvider contract
* @notice Is the main registry of the protocol. All the different components of the protocol are accessible
* through the addresses provider.
* @author Aave
**/

contract LendingPoolAddressesProvider is Ownable {

    address payable private lendingPoolCoreAddress;

    /**
    * @dev returns the address of the LendingPoolCore proxy
    * @return the lending pool core proxy address
     */
    function getLendingPoolCore() public view returns (address payable) {
        return lendingPoolCoreAddress;
    }

    /**
    * @dev updates the implementation of the lending pool core
    * @param _lendingPoolCore the new lending pool core implementation
    **/
    function setLendingPoolCoreImpl(address payable _lendingPoolCore) public onlyOwner {
        lendingPoolCoreAddress = _lendingPoolCore;
    }
}
