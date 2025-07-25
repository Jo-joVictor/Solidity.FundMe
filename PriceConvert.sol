// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    //  Get ETH price in USD
    function getEthPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        (, int256 price,,,) = priceFeed.latestRoundData();
        // Chainlink returns 8 decimals, convert to 18
        return uint256(price * 1e10); // e.g., $2,000.00000000 → $2,000 * 1e18
    }

    //  Convert ETH to USD
    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        uint256 ethPrice = getEthPrice(priceFeed);
        return (ethPrice * ethAmount) / 1e18;
    }
}
