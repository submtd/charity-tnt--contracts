// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IResolver {
    function checker() external view returns (bool canExec, bytes memory execPayload);
}

import "./abstracts/BaseContract.sol";
import "./interfaces/ITNTSwap.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

/// @custom:security-contact security@tntswap.io
contract TaxHandler is BaseContract, IResolver
{
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() initializer public
    {
        __BaseContract_init();
    }

    /**
     * Taxes.
     */
    mapping (address => bool) private _isExempt;

    /**
     * Last distribution.
     */
    uint256 public distributionInterval;
    uint256 public lastDistribution;

    /**
     * Setup.
     */
    function setup() external
    {
        _isExempt[addressBook.get("swap")] = true;
        _isExempt[addressBook.get("pool")] = true;
        _isExempt[addressBook.get("router")] = true;
        distributionInterval = 2 hours;
    }

    /**
     * Checker.
     */
    function checker() external view override returns (bool canExec, bytes memory execPayload)
    {
        if(lastDistribution + distributionInterval >= block.timestamp) return (false, bytes("Distribution is not due"));
        return(true, abi.encodeWithSelector(this.distribute.selector));
    }

    /**
     * Check if address is exempt.
     * @param address_ Address to check.
     * @return bool True if address is exempt.
     */
    function isExempt(address address_) external view returns (bool)
    {
        return _isExempt[address_];
    }

    /**
     * Add tax exemption.
     * @param address_ Address to be exempt.
     */
    function addTaxExemption(address address_) external onlyOwner
    {
        _isExempt[address_] = true;
    }

    /**
     * Distribute taxes.
     */
    function distribute() external
    {
        lastDistribution = block.timestamp;
    }
}
