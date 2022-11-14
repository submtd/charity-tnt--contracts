// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./abstracts/BaseContract.sol";
// INTERFACES
import "./interfaces/ITaxHandler.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

/// @custom:security-contact security@tntswap.io
contract TNTSwap is BaseContract
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
     * Contracts.
     */
    IUniswapV2Factory public factory;
    IUniswapV2Pair public pair;
    IUniswapV2Router02 public router;
    IERC20 public tnt;
    ITaxHandler public taxHandler;
    IERC20 public usdc;

    /**
     * Taxes.
     */
    uint256 public tax;

    /**
     * Contract setup.
     */
    function setup() external
    {
        factory = IUniswapV2Factory(addressBook.get("factory"));
        router = IUniswapV2Router02(addressBook.get("router"));
        taxHandler = ITaxHandler(addressBook.get("taxHandler"));
        tnt = IERC20(addressBook.get("tnt"));
        usdc = IERC20(addressBook.get("usdc"));
        pair = IUniswapV2Pair(factory.getPair(address(tnt), address(usdc)));
        tax = 1000; // 10%
    }

    /**
     * Buy TNT.
     * @param payment_ Address of payment token.
     * @param amount_ Amount of tokens to spend.
     */
    function buy(address payment_, uint256 amount_) external whenNotPaused
    {
        // Buy TNT.
        uint256 _received_ = _buy(msg.sender, payment_, amount_);
        // Transfer received TNT to sender.
        require(tnt.transfer(msg.sender, _received_), "TNTSwap: transfer failed");
    }

    /**
     * Buy TNT.
     * @param buyer_ Address of buyer.
     * @param payment_ Address of payment token.
     * @param amount_ Amount of tokens to spend.
     * @return uint256 Amount of FUR received.
     */
    function _buy(address buyer_, address payment_, uint256 amount_) internal returns (uint256)
    {
        // Convert payment to USDC.
        uint256 _usdcAmount_ = _buyUsdc(payment_, amount_, buyer_);
        // Calculate USDC taxes.
        uint256 _tax_ = 0;
        if(!taxHandler.isExempt(buyer_)) _tax_ = _usdcAmount_ * tax / 10000;
        // Get TNT balance.
        uint256 _startingTntBalance_ = tnt.balanceOf(address(this));
        // Swap USDC for TNT.
        _swap(address(usdc), address(tnt), _usdcAmount_ - _tax_);
        uint256 _tntSwapped_ = tnt.balanceOf(address(this)) - _startingTntBalance_;
        // Transfer taxes to tax handler.
        if(_tax_ > 0) usdc.transfer(address(taxHandler), _tax_);
        // Return amount.
        return _tntSwapped_;
    }

    /**
     * Internal buy USDC.
     * @param payment_ Address of payment token.
     * @param amount_ Amount of tokens to spend.
     * @param buyer_ Address of buyer.
     * @return uint256 Amount of USDC purchased.
     */
    function _buyUsdc(address payment_, uint256 amount_, address buyer_) internal returns (uint256)
    {
        // Instanciate payment token.
        IERC20 _payment_ = IERC20(payment_);
        // Get payment balance.
        uint256 _startingPaymentBalance_ = _payment_.balanceOf(address(this));
        // Transfer payment tokens to this address.
        require(_payment_.transferFrom(buyer_, address(this), amount_), "TNTSwap: transfer failed");
        uint256 _balance_ = _payment_.balanceOf(address(this)) - _startingPaymentBalance_;
        // If payment is already USDC, return.
        if(payment_ == address(usdc)) {
            return _balance_;
        }
        // Swap payment for USDC.
        uint256 _startingUsdcBalance_ = usdc.balanceOf(address(this));
        _swap(address(_payment_), address(usdc), _balance_);
        uint256 _usdcSwapped_ = usdc.balanceOf(address(this)) - _startingUsdcBalance_;
        // Return tokens received.
        return _usdcSwapped_;
    }

    /**
     * Swap.
     * @param in_ Address of input token.
     * @param out_ Address of output token.
     * @param amount_ Amount of input tokens to swap.
     */
    function _swap(address in_, address out_, uint256 amount_) internal
    {
        address[] memory _path_ = new address[](2);
        _path_[0] = in_;
        _path_[1] = out_;
        IERC20(in_).approve(address(router), amount_);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount_,
            0,
            _path_,
            address(this),
            block.timestamp + 3600
        );
    }

    /**
     * Sell FUR.
     * @param amount_ Amount of FUR to sell.
     */
    function sell(uint256 amount_) external whenNotPaused
    {
        // Get starting TNT balance.
        uint256 _startingTntBalance_ = tnt.balanceOf(address(this));
        // Transfer TNT to this contract.
        require(tnt.transferFrom(msg.sender, address(this), amount_), "TNTSwap: transfer failed");
        // Get TNT received.
        uint256 _tntReceived_ = tnt.balanceOf(address(this)) - _startingTntBalance_;
        // Get starting USDC balance.
        uint256 _startingUsdcBalance_ = usdc.balanceOf(address(this));
        // Swap FUR for USDC.
        _swap(address(tnt), address(usdc), _tntReceived_);
        uint256 _usdcSwapped_ = usdc.balanceOf(address(this)) - _startingUsdcBalance_;
        // Handle taxes.
        uint256 _tax_ = 0;
        if(!taxHandler.isExempt(msg.sender)) _tax_ = _usdcSwapped_ * tax / 10000;
        // Transfer taxes to tax handler.
        if(_tax_ > 0) usdc.transfer(address(taxHandler), _tax_);
        // Transfer received USDC to sender.
        require(usdc.transfer(msg.sender, _usdcSwapped_ - _tax_), "TNTSwap: transfer failed");
    }

    /**
     * Get token buy output.
     * @param payment_ Address of payment token.
     * @param amount_ Amount spent.
     * @return uint Amount of tokens received.
     */
    function buyOutput(address payment_, uint256 amount_) public view returns (uint256) {
        return
            _getOutput(
                payment_,
                address(tnt),
                amount_
            );
    }

    /**
     * Get token sell output.
     * @param amount_ Amount sold.
     * @return uint Amount of tokens received.
     */
    function sellOutput(uint256 amount_) public view returns (uint256) {
        return
            _getOutput(
                address(tnt),
                address(usdc),
                amount_
            );
    }

    /**
     * Get output.
     * @param in_ In token.
     * @param out_ Out token.
     * @param amount_ Amount in.
     * @return uint Estimated tokens received.
     */
    function _getOutput(
        address in_,
        address out_,
        uint256 amount_
    ) internal view returns (uint256) {
        address[] memory _path_ = new address[](2);
        _path_[0] = in_;
        _path_[1] = out_;
        uint256[] memory _outputs_ = router.getAmountsOut(amount_, _path_);
        uint256 _output_ = _outputs_[1];
        uint256 _tax_ = 0;
        if(!taxHandler.isExempt(msg.sender)) _tax_ = _output_ * tax / 10000;
        return _output_ - _tax_;
    }
}
