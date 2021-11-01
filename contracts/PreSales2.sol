// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import '@openzeppelin/contracts/utils/Context.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol';

contract PreSales2 is Context {
    using Address for address payable;

    address payable private immutable _wallet;
    ERC20 private immutable _token;
    AggregatorV3Interface private immutable _USDPriceFeed;
    uint256 private immutable _openingTime;
    uint256 private immutable _closingTime;
    uint256 private immutable _cap;
    //100 ether = 100EAR = 1USD
    uint256 private immutable _rate;

    uint256 private _weiRaised;
    uint256 private _soldTokens;

    /**
     * Event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    constructor(
        uint256 rate_,
        address payable wallet_,
        ERC20 token_,
        uint256 cap_,
        uint256 openingTime_,
        uint256 closingTime_,
        AggregatorV3Interface USDPriceFeed_
    ) {
        require(cap_ > 0, 'PreSales: cap is 0');
        require(openingTime_ >= block.timestamp, 'PreSales: opening time is before current time');
        require(closingTime_ > openingTime_, 'PreSales: opening time is not before closing time');
        require(rate_ > 0, 'Crowdsale: rate is 0');
        require(wallet_ != address(0), 'Crowdsale: wallet is the zero address');
        require(address(token_) != address(0), 'Crowdsale: token is the zero address');
        require(address(USDPriceFeed_) != address(0), 'Crowdsale: USDPriceFeed is the zero address');

        _cap = cap_;
        _token = token_;
        _openingTime = openingTime_;
        _closingTime = closingTime_;
        _rate = rate_;
        _wallet = wallet_;
        _USDPriceFeed = USDPriceFeed_;
    }

    /**
     * @param beneficiary Recipient of the token purchase
     */
    function buyTokens(address beneficiary) public payable {
        uint256 weiAmount = msg.value;
        require(beneficiary != address(0), 'PreSales: beneficiary is the zero address');
        require(weiAmount != 0, 'PreSales: weiAmount is 0');
        require(isOpen(), 'PreSales: not open');

        // calculate token amount to be created
        uint256 tokens = estimate(weiAmount);
        require((_soldTokens + tokens) <= _cap, 'PreSales: cap exceeded');

        // update state
        _soldTokens = _soldTokens + tokens;
        _weiRaised = _weiRaised + weiAmount;

        emit TokensPurchased(_msgSender(), beneficiary, weiAmount, tokens);

        _token.transfer(beneficiary, tokens);
    }

    /**
     * @param value Ether amount
     */
    function estimate(uint256 value) public view returns (uint256) {
        (, int256 price, , , ) = _USDPriceFeed.latestRoundData();
        uint256 priceWei = uint256(price) * (10**(18 - _USDPriceFeed.decimals()));
        return (((value * priceWei) / 1 ether) * _rate) / 1 ether;
    }

    /**
     * @dev Withdraw the amount of this contract balance.
     */
    function withdraw() public {
        require(address(this).balance > 0, 'PreSales: balance is 0');
        wallet().sendValue(address(this).balance);
    }

    /**
     * @return the crowdsale opening time.
     */
    function openingTime() public view returns (uint256) {
        return _openingTime;
    }

    /**
     * @return the crowdsale closing time.
     */
    function closingTime() public view returns (uint256) {
        return _closingTime;
    }

    /**
     * @return true if the crowdsale is open, false otherwise.
     */
    function isOpen() public view returns (bool) {
        return block.timestamp >= _openingTime && block.timestamp <= _closingTime;
    }

    /**
     * @dev Checks whether the period in which the crowdsale is open has already elapsed.
     * @return Whether crowdsale period has elapsed
     */
    function hasClosed() public view returns (bool) {
        return block.timestamp > _closingTime;
    }

    /**
     * @return the token being sold.
     */
    function token() public view returns (IERC20) {
        return _token;
    }

    /**
     * @return the address where funds are collected.
     */
    function wallet() public view returns (address payable) {
        return _wallet;
    }

    /**
     * @return the number of token units a buyer gets per wei.
     */
    function rate() public view returns (uint256) {
        return _rate;
    }

    /**
     * @return the amount of wei raised.
     */
    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }

    /**
     * @return the amount of sold token.
     */
    function soldTokens() public view returns (uint256) {
        return _soldTokens;
    }

    /**
     * @return the cap of the crowdsale.
     */
    function cap() public view returns (uint256) {
        return _cap;
    }

    /**
     * @dev Checks whether the cap has been reached.
     * @return Whether the cap was reached
     */
    function capReached() public view returns (bool) {
        return soldTokens() >= _cap;
    }

    /**
     * @return chainlink AggregatorV3Interface(ETH / USD)
     */
    function USDPriceFeed() public view returns (AggregatorV3Interface) {
        return _USDPriceFeed;
    }
}
