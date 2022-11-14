// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./abstracts/BaseContract.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

/// @custom:security-contact security@tnt.io
contract TNT is BaseContract, ERC20Upgradeable {
    /**
     * Contract initializer.
     * @dev This intializes all the parent contracts.
     */
    function initialize() public initializer {
        __BaseContract_init();
        __ERC20_init("TNT Token", "TNT");
    }

    /**
     * Total max supply of TNT.
     * @dev Can not exceed 5b tokens.
     */
    uint256 constant MAX_SUPPLY = 5000000000e18;

    /**
     * External contracts.
     */
    address pair;

    /**
     * Addresses that can swap.
     */
    mapping(address => bool) private _canSwap;

    /**
     * Addresses that can mint.
     */
    mapping(address => bool) private _canMint;

    /**
     * _transfer override.
     * @param from_ From address.
     * @param to_ To address.
     * @param amount_ Transfer amount.
     * @dev This is overridden to prevent swaps through non-whitelisted contracts.
     */
    function _transfer(
        address from_,
        address to_,
        uint256 amount_
    ) internal override {
        if(from_ == pair) require(_canSwap[to_], "TNT: No swaps from external contracts");
        if(to_ == pair) require(_canSwap[from_], "TNT: No swaps from external contracts");
        return super._transfer(from_, to_, amount_);
    }

    /**
     * Mint.
     * @param to_ Token receiver address.
     * @param quantity_ Quantity to mint.
     * @dev Minting is limited to the pool contract which is used to create the
     * initial liquidity pool, and the timelock contract which is used to trikle
     * out tokens to team/early investors.
     */
    function mint(address to_, uint256 quantity_) external onlyOwner {
        super._mint(to_, quantity_);
    }

    /**
     * Setup.
     * @dev Updates stored addresses.
     */
    function setup() public {
        address _factory_ = addressBook.get("factory");
        pair = IUniswapV2Factory(_factory_).getPair(
            addressBook.get("payment"),
            address(this)
        );
        address _swap_ = addressBook.get("swap");
        address _pool_ = addressBook.get("pool");
        address _timelock_ = addressBook.get("timelock");
        if(_swap_ != address(0)) _canSwap[_swap_] = true;
        if(_pool_ != address(0)) _canMint[_pool_] = true;
        if(_timelock_ != address(0)) _canMint[_timelock_] = true;
    }

    /**
     * @dev Add whenNotPaused modifier to token transfer hooks.
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override whenNotPaused {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal override whenNotPaused {}
}
