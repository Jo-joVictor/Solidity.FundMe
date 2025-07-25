// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConvert.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract CharityFundMe {
    using PriceConverter for uint256;

    address public immutable i_owner;
    uint256 public constant MINIMUM_USD = 5 * 1e18; // $5.00

    mapping(address => uint256) public addressToAmountFunded;
    address[] public donors;

    AggregatorV3Interface public s_priceFeed;

    modifier onlyOwner() {
        require(msg.sender == i_owner, "Not the owner");
        _;
    }

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function fund() public payable {
        // Convert msg.value to USD
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "Minimum is $5");

        if (addressToAmountFunded[msg.sender] == 0) {
            donors.push(msg.sender);
        }

        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        payable(i_owner).transfer(address(this).balance);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getDonorCount() public view returns (uint256) {
        return donors.length;
    }

    function getPriceFeed() public view returns (address) {
        return address(s_priceFeed);
    }
}
