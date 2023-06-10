// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from './PriceConverter.sol';

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18; //5$ * 18 decimals
    // 329 cost - constant
    // 2429 cost without constant keyword
    uint256 public minWeiAmount = MINIMUM_USD.getMinWeiAmount(); //I created another function to help me know what is the min amount of Wei I need to send


    //	894724 gas first transaction cost - before using constant and immutable
	//  874997 gas transaction cost - after adding constant 
    //  851423 gas transaction cost - after adding constant + immutable
    //  826312 gas transaction cost - after adding constant + immutable + custom error NotOwner()

    address public immutable i_owner;
    // 422 cost - immutable
    // 2558 cost - without immutable keyword
    address[] public funders;
    mapping (address funder => uint256 amountFunded) public addressToAmountFunded;

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Didn't send enough ETH");
        funders.push(msg.sender);
        // addressToAmountFunded[msg.sender] = addressToAmountFunded[msg.sender] + msg.value;
         addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for(uint256 fundersIndex = 0; fundersIndex < funders.length; fundersIndex++ ) {
            address funder = funders[fundersIndex];
            addressToAmountFunded[funder] = 0;

            funders = new address[](0);
        //transfer
        // payable(msg.sender).transfer(address(this).balance);
        // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        //call;
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "call failed");
    }
    }


    modifier onlyOwner() {
                if(msg.sender != i_owner){revert NotOwner();} //more gas efficient than using require
            //    require(msg.sender == i_owner, "You are not the owner");
               _;
    }

    //What happens if someone sends this contract ETH without calling the fund function?
    receive() external payable {
        fund();
    }
    fallback() external payable {
        fund();
    }
}
