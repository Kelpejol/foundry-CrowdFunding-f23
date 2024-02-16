// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {PriceConverter} from "./PriceConverter.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error CrowdFunding__notEnoughETH();
error CrowdFunding__deadlinePassed();

contract CrowdFunding is Ownable {
    using PriceConverter for uint256;

    uint256 public immutable i_fundingGoal;
    uint256 public immutable i_campaignDuration;
    uint256 public constant MINIMUM_USD = 5e8;
    address[] private s_funders;
    uint256 private s_totalAmountfunded;
    address private s_priceFeed;

    enum Statuses {
        unsuccessful,
        successful
    }
    Statuses private s_currentStatus;

    mapping(address funder => uint256 amountFunded)
        private s_funderToAmountFunded;

    constructor(
        uint256 _fundingGoal,
        uint256 _campaignDuration,
        address _priceFeed
    ) Ownable(msg.sender) {
        i_fundingGoal = _fundingGoal * 1e18;
        i_campaignDuration = _campaignDuration;
        s_currentStatus = Statuses.unsuccessful;
        s_priceFeed = (_priceFeed);
    }

    function fundMe() public payable {
        if (msg.value.getConversionRate(s_priceFeed) < MINIMUM_USD) {
            revert CrowdFunding__notEnoughETH();
        }
        if (block.timestamp > i_campaignDuration) {
            revert CrowdFunding__deadlinePassed();
        }

        s_funders.push(msg.sender);
        s_funderToAmountFunded[msg.sender] += msg.value;
        s_totalAmountfunded += msg.value;
    }

    function status() internal {
        if (s_totalAmountfunded >= i_fundingGoal) {
            s_currentStatus = Statuses.successful;
        } else {
            s_currentStatus = Statuses.unsuccessful;
        }
    }

    function withdraw() public onlyOwner {
        address owner = owner();
        (bool success, ) = payable(owner).call{value: address(this).balance}(
            ""
        );
        require(success, "withdraw Not Successful");
    }

    receive() external payable {
        fundMe();
    }

    fallback() external payable {
        fundMe();
    }

    function getFundersArray(uint256 _index) external view returns (address) {
        return s_funders[_index];
    }

    function getTotalAmountFunded() external view returns (uint256) {
        return s_totalAmountfunded;
    }

    function getFundersToAmountFunded(
        address _funder
    ) external view returns (uint256) {
        return s_funderToAmountFunded[_funder];
    }

    function getCampaignDuration() external view returns (uint256) {
        return i_campaignDuration;
    }
}
