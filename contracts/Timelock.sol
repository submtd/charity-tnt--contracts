// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./BaseContract.sol";

/**
 * @title Timelock
 * @author Steve Harmeyer
 * @notice This is the timelock contract.
 */

/// @custom:security-contact security@tntswap.io
contract Timelock is BaseContract
{
    /**
     * Contract initializer.
     * @dev This performs the initial contract setup.
     */
    function initialize() initializer public
    {
        __BaseContract_init();
    }
}
