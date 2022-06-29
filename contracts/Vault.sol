// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./BaseContract.sol";

/**
 * @title Vault
 * @author Steve Harmeyer
 * @notice This is the vault rewards contract.
 */

/// @custom:security-contact security@tntswap.io
contract Vault is BaseContract
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
