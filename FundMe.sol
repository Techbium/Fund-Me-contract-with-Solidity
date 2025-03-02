//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

//import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

contract FundMe {
    using PriceConverter for uint256;

    uint256 public minimumUsd = 5e18;

    address[] funders;
    mapping(address funder => uint amountFunded) public addressToAmountFunded;

    address public owner;
    constructor() {
        owner = msg.sender;
    }

    function Fund() public payable {
        require(msg.value.getConversionRate() >= minimumUsd, "Not enough ETH");

        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = addressToAmountFunded[msg.sender] + msg.value;
    }

     function withdraw () public  { 
        require(msg.sender == owner, "Must be the owner");

        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        funders = new address[](0);

        //payable(msg.sender).transfer(address(this).balance);
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Sender is not owner");
        _;
    } 

    receive() external payable {
        Fund();
    }
    fallback() external payable {
        Fund();
    }
}