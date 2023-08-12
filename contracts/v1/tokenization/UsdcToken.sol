// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract UsdcToken is ERC20 {
    constructor() public ERC20() {
        _mint(msg.sender, 20000);
    }
}
