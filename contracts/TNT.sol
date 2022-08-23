// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./abstracts/BaseContract.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

/// @custom:security-contact security@tntswap.io
contract TNT is BaseContract, ERC20Upgradeable {
    /**
     * Contract initializer.
     */
    function initialize() initializer public
    {
        __BaseContract_init();
        __ERC20_init("TNT Token", "TNT");
        canAddNewMinters = true;
        mintingEnabled = true;
    }

    /**
     * Minting properties.
     */
    mapping(address => uint256) public minters;
    bool public canAddNewMinters;
    bool public mintingEnabled;

    /**
     * Minting events.
     */
    event Mint(address indexed to, uint256 amount);
    event MinterAdded(address indexed minter, uint256 remaining);
    event MinterAddingDisabled();
    event MintingDisabled();

    /**
     * -------------------------------------------------------------------------
     * Minting.
     * -------------------------------------------------------------------------
     */

    /**
     * Mint.
     * @param to_ Address to mint to.
     * @param amount_ Amount to mint.
     */
    function mint(address to_, uint256 amount_) external returns (bool)
    {
        require(mintingEnabled, "Minting is disabled.");
        require(minters[msg.sender] >= amount_, "You are not allowed to mint tokens.");
        minters[msg.sender] -= amount_;
        _mint(to_, amount_);
        emit Mint(to_, amount_);
        return true;
    }

    /**
     * Add minter.
     * @param minter_ Address to add as minter.
     * @param max_ Max tokens minter can mint.
     */
    function addMinter(address minter_, uint256 max_) external onlyOwner
    {
        require(canAddNewMinters, "Adding new minters is disabled.");
        minters[minter_] += max_;
        emit MinterAdded(minter_, minters[minter_]);
    }

    /**
     * Disable adding new minters.
     */
    function disableAddingNewMinters() external onlyOwner
    {
        canAddNewMinters = false;
        emit MinterAddingDisabled();
    }

    /**
     * Disable minting.
     */
    function disableMinting() external onlyOwner
    {
        canAddNewMinters = false;
        mintingEnabled = false;
        emit MintingDisabled();
    }
}
