// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script, console} from "forge-std/Script.sol";
import {CrowdFunding} from "../src/CrowdFunding.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployCrowdFunding is Script {

    uint256 constant FUNDING_GOAL = 100e18;
    uint256 constant CAMPAIGN_DURATION = 1708094597;


    function run() external returns(CrowdFunding, HelperConfig){
        HelperConfig helperConfig = new HelperConfig();
        address priceFeed = helperConfig.activeNetworkConfig();
        vm.startBroadcast();
        CrowdFunding crowdFunding = new CrowdFunding(FUNDING_GOAL, CAMPAIGN_DURATION, priceFeed);
        vm.stopBroadcast();
        return (crowdFunding, helperConfig);
    }
}

// 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
