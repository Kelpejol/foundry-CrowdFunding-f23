// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {CrowdFunding} from "../src/CrowdFunding.sol";
import {console}  from "forge-std/console.sol";

contract FundMeCrowdFunding is Script {
    uint256 constant SEND_VALUE = 0.1 ether;


     function run() external {
        address latestDeployedCrowdFunding = DevOpsTools
            .get_most_recent_deployment("CrowdFunding", block.chainid);
        fundFundMeCrowdFunding(latestDeployedCrowdFunding, SEND_VALUE);
    }

    function fundFundMeCrowdFunding(
        address _latestDeployedCrowdFunding, uint256 _amount
    ) public {
        vm.startBroadcast();
        // CrowdFunding(payable(_latestDeployedCrowdFunding)).getCampaignDuration();
        CrowdFunding(payable(_latestDeployedCrowdFunding)).fundMe{value: _amount}();
        vm.stopBroadcast();
    }

   
}

contract WithdrawCrowdFunding is Script {

     function withdrawFundMeCrowdFunding(address latestDeployedCrowdFunding) public {
        vm.startBroadcast();
        CrowdFunding(payable(latestDeployedCrowdFunding)).withdraw();
        vm.stopBroadcast();
       
    }

    function run() external {
        address latestDeployedCrowdFunding = DevOpsTools.get_most_recent_deployment("CrowdFunding", block.chainid);
        withdrawFundMeCrowdFunding(latestDeployedCrowdFunding);
    }
}
