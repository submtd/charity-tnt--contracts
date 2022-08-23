// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./abstracts/BaseContract.sol";
import "./interfaces/ITNT.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

/// @custom:security-contact security@tntswap.io
contract Presale is BaseContract
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
     * Addresses.
     */
    address public usdcAddress;
    address public routerAddress;
    address public safeAddress;
    address public tntAddress;

    /**
     * Presale parameters.
     */
    uint256 private _presaleIdTracker;
    mapping(uint256 => uint256) public startTime;
    mapping(uint256 => uint256) public price;
    mapping(uint256 => uint256) public sold;
    mapping(uint256 => uint256) public max;

    event Bought(address indexed buyer, uint256 amount);

    /**
     * Update addresses.
     */
    function updateAddresses() public
    {
        if(usdcAddress == address(0)) usdcAddress = addressBook.get("USDC");
        if(routerAddress == address(0)) routerAddress = addressBook.get("Router");
        if(safeAddress == address(0)) safeAddress = addressBook.get("Safe");
        if(tntAddress == address(0)) tntAddress = addressBook.get("TNT");
    }

    /**
     * Get presale id.
     * @return uint256 Presale id.
     */
    function getPresaleId() public view returns (uint256)
    {
        for(uint256 i = _presaleIdTracker; i > 0; i--) {
            if(startTime[i] <= block.timestamp) return i;
        }
        return 0;
    }

    /**
     * Buy.
     * @param amount_ Amount of TNT to buy.
     */
    function buy(uint amount_) public whenNotPaused
    {
        updateAddresses();
        require(usdcAddress != address(0), "Payment address not set");
        require(tntAddress != address(0), "TNT address not set");
        uint256 _presaleId_ = getPresaleId();
        require(_presaleId_ > 0, "No presales are currently active");
        require(sold[_presaleId_] + amount_ <= max[_presaleId_], "No more presales are available");
        sold[_presaleId_] += amount_;
        IERC20 _usdc_ = IERC20(usdcAddress);
        ITNT _tnt_ = ITNT(tntAddress);
        require(_usdc_.transferFrom(msg.sender, address(this), amount_ * price[_presaleId_]), "Token transfer failed");
        require(_tnt_.mint(msg.sender, amount_), "TNT mint failed");
        emit Bought(msg.sender, amount_);
    }

    /**
     * -------------------------------------------------------------------------
     * ADMIN FUNCTIONS.
     * -------------------------------------------------------------------------
     */

    /**
     * Create presale.
     * @param startTime_ Start time.
     * @param price_ Price.
     * @param max_ Max amount of TNT available.
     */
    function createPresale(uint startTime_, uint price_, uint max_) external onlyOwner
    {
        require(startTime_ > startTime[_presaleIdTracker], "Start time must be greater than previous start time.");
        _presaleIdTracker++;
        startTime[_presaleIdTracker] = startTime_;
        price[_presaleIdTracker] = price_;
        max[_presaleIdTracker] = max_;
    }

    /**
     * Withdraw.
     * @param amount_ Amount to withdraw.
     */
    function withdrawUSDC(uint256 amount_) external onlyOwner
    {
        updateAddresses();
        require(usdcAddress != address(0), "Payment address not set");
        IERC20 _usdc_ = IERC20(usdcAddress);
        _usdc_.transfer(msg.sender, amount_);
    }

    /**
     * Create liquidity pool.
     * @param launchPrice_ Launch price.
     */
    function createLiquidityPool(uint launchPrice_) external onlyOwner
    {
        updateAddresses();
        require(usdcAddress != address(0), "Payment address not set");
        require(routerAddress != address(0), "Router address not set");
        require(safeAddress != address(0), "Safe address not set");
        require(tntAddress != address(0), "Token address not set");
        IUniswapV2Router02 _router_ = IUniswapV2Router02(routerAddress);
        IERC20 _usdc_ = IERC20(usdcAddress);
        ITNT _tnt_ = ITNT(tntAddress);
        uint256 _usdcBalance_ = _usdc_.balanceOf(address(this));
        uint256 _amountToMint_ = _usdcBalance_ / launchPrice_;
        require(_amountToMint_ > 0, "Invalid amount");
        _tnt_.mint(address(this), _amountToMint_);
        _tnt_.approve(routerAddress, _amountToMint_);
        _usdc_.approve(routerAddress, _usdcBalance_);
        _router_.addLiquidity(
            usdcAddress,
            tntAddress,
            _usdcBalance_,
            _amountToMint_,
            0,
            0,
            safeAddress,
            block.timestamp + 3600
        );
    }
}
