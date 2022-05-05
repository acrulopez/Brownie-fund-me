// SPDX-License-Identifier: MIT

pragma solidity >=0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public owner;
    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) public {
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function fund() public payable {
        uint256 minimumUsd = 50 * 10**8;
        require(
            getConvertionRate(msg.value) >= minimumUsd,
            "You need to spend more ETH!"
        );
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function describe() external view returns (string memory) {
        return priceFeed.description();
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer);
    }

    function getConvertionRate(uint256 weiAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethInUsd = (ethPrice * weiAmount) / 10**18; // Divide to transform wei to ether
        return ethInUsd;
    }

    function getEntranceFeeInWei() public view returns (uint256) {
        //minimum USD
        uint256 minimumUSD = 50;
        uint256 price = getPrice(); //price has 8 decimals
        uint256 precision = 1.01 * 10**26; // 8 to remove price decimals + 18 to convert to wei. 1.01 to increase 1% the fee to avoid errors
        return (minimumUSD * precision) / price;
    }

    function getFunds() public view returns (uint256) {
        return address(this).balance;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function withDraw() public payable onlyOwner {
        msg.sender.transfer(address(this).balance);
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        delete funders;
    }
}
