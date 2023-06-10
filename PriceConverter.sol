// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {


    function getPrice() internal view  returns (uint256) {
        //Address 0x694AA1769357215DE4FAC081bf1f309aDC325306
        //ABI - we get it from importing the AggregatorV3Interface
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        //return (uint80 roundID,int answer,uint startedAt,uint timeStamp,uint80 answeredInRound ) = priceFeed.latestRoundData();
        (, int256 price, , , ) = priceFeed.latestRoundData(); // - we just delete the variables we don't need
        return uint256(price * 1e10); //Interface has 8 decimals, and ETH price in WEI has 18 decimals so we need 10 more decimals in our price variable and we 
        //need it to be a uint256 since our msg.value is also uint256
    }

    function getConversionRate(uint256 ethAmount) internal view returns(uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = ethPrice * ethAmount / 1e18;
        return ethAmountInUsd;
    }

    function getversion() internal view returns (uint256) {
        return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
    }
    
    //I created another function to help me know what is the min amount of Wei I need to send
    function getMinWeiAmount(uint256 minUsdAmount) internal view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 minWeiAmount = minUsdAmount * 1e18 / ethPrice;
        return minWeiAmount;
    }
}
