// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./BaseContract.sol";
// Interfaces.
import "@openzeppelin/contracts/interfaces/IERC20.sol";

/**
 * @title Pool
 * @author Steve Harmeyer
 * @notice This is the pool/automated market maker contract.
 */

/// @custom:security-contact security@tntswap.io
contract Pool is BaseContract
{
    /**
     * Contract initializer.
     * @dev This performs the initial contract setup.
     */
    function initialize() initializer public
    {
        __BaseContract_init();
    }

    /**
     * TNT Token.
     * @dev TNT token.
     */
    IERC20 private _token;

    /**
     * Payment Token.
     * @dev Payment token (USDC).
     */
    IERC20 private _payment;
}
