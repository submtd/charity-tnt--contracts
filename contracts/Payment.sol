// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @custom:security-contact security@tntswap.io
contract Payment is ERC20 {
    constructor() ERC20("USD Coin", "USDC") {}

    function mint(uint256 amount) public {
        _mint(msg.sender, amount * (10 ** decimals()));
    }
}
