// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./abstracts/BaseContract.sol";
// Interfaces.
import "./interfaces/ITNT.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

/// @custom:security-contact security@tntswap.io
contract Pool is BaseContract
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
     * External contracts.
     */
    address public safe;

    /**
     * Starting price.
     */
    uint256 private _startingPrice;

    /**
     * Setup.
     */
    function setup() external
    {
        _startingPrice = 500; // $0.05 * 100
        safe = addressBook.get("safe");
    }

    /**
     * Create liquidity.
     */
    function createLiquidity() external onlyOwner
    {
        IUniswapV2Router02 _router_ = IUniswapV2Router02(addressBook.get("router"));
        require(address(_router_) != address(0), "Pool: Router not set");
        IERC20 _usdc_ = IERC20(addressBook.get("usdc"));
        ITNT _tnt_ = ITNT(addressBook.get("tnt"));
        uint256 _usdcBalance_ = _usdc_.balanceOf(address(this));
        uint256 _tntBalance_ = _tnt_.balanceOf(address(this));
        require(_usdcBalance_ > 0 && _tntBalance_ > 0, "Pool: No balance");
        _usdc_.approve(address(_router_), _usdcBalance_);
        _tnt_.approve(address(_router_), _tntBalance_);
        _router_.addLiquidity(
            address(_usdc_),
            address(_tnt_),
            _usdcBalance_,
            _tntBalance_,
            0,
            0,
            safe,
            block.timestamp + 3600
        );
    }
}
