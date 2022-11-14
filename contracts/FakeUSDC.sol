// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./abstracts/BaseContract.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

/// @custom:security-contact security@tntswap.io
contract FakeUSDC is BaseContract, ERC20Upgradeable {

    /**
     * Contract initializer.
     */
    function initialize() initializer public {
        __BaseContract_init();
        __ERC20_init("Fake USDC", "FUSDC");
    }

    /**
     * Faucet.
     */
    uint256 public dripAmount;
    uint256 public dripCooldown;
    mapping(address => uint256) private _lastDrip;

    /**
     * Setup.
     */
    function setup() external
    {
        dripCooldown = 1 days;
        dripAmount = 1000e18;
    }

    /**
     * Drip.
     */
    function drip() external
    {
        require(_lastDrip[msg.sender] + dripCooldown <= block.timestamp, "FUSDC: Drip too soon");
        _lastDrip[msg.sender] = block.timestamp;
        _mint(msg.sender, dripAmount);
    }

    /**
     * Mint.
     * @param to_ Token receiver address.
     * @param quantity_ Quantity to mint.
     */
    function mint(address to_, uint256 quantity_) external {
        super._mint(to_, quantity_);
    }
}
