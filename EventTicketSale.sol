// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract EventTicketSale {
    using PriceConverter for uint256;

    address public immutable i_organizer;
    uint256 public constant TICKET_PRICE_USD = 10 * 1e18; // $10 per ticket

    mapping(address => uint256) public addressToTicketsBought;
    address[] public buyers;
    AggregatorV3Interface public s_priceFeed;

    modifier onlyOrganizer() {
        require(msg.sender == i_organizer, "Not the organizer");
        _;
    }

    constructor(address priceFeedAddress) {
        i_organizer = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function buyTickets(uint256 numberOfTickets) public payable {
        uint256 totalCostUSD = numberOfTickets * TICKET_PRICE_USD;
        require(msg.value.getConversionRate(s_priceFeed) >= totalCostUSD, "Insufficient ETH for tickets");

        if (addressToTicketsBought[msg.sender] == 0) {
            buyers.push(msg.sender);
        }
        addressToTicketsBought[msg.sender] += numberOfTickets;
    }

    function withdraw() public onlyOrganizer {
        payable(i_organizer).transfer(address(this).balance);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getBuyersCount() public view returns (uint256) {
        return buyers.length;
    }

    function getPriceFeed() public view returns (address) {
        return address(s_priceFeed);
    }
}