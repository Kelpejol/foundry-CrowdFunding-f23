// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/Mock/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;
    uint8 constant DECIMALS = 8;
    int256 constant ETH_TO_USD = 2000e8;

    constructor() {
        if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthToUsdPriceFeed();
        } else if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthToUsdPriceFeed();
        }
        else{
            activeNetworkConfig = getOrSetAnvilEthToUsdPriceFeed();
        }
    }

    struct NetworkConfig {
        address priceFeed;
    }

    function getSepoliaEthToUsdPriceFeed()
        public
        pure
        returns (NetworkConfig memory)
    {
        NetworkConfig memory sepoliaEthToUsdPriceFeed = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaEthToUsdPriceFeed;
    }

    function getMainnetEthToUsdPriceFeed()
        public
        pure
        returns (NetworkConfig memory)
    {
        NetworkConfig memory mainnetEthToUsdPriceFeed = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return mainnetEthToUsdPriceFeed;
    }

    function getOrSetAnvilEthToUsdPriceFeed() public returns (NetworkConfig memory) {
 
       if (activeNetworkConfig.priceFeed != address(0)) {
       return activeNetworkConfig;
      }

        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(DECIMALS, ETH_TO_USD);
        vm.stopBroadcast();

        NetworkConfig memory anvilEthToUsdPriceFeed = NetworkConfig({
            priceFeed: address(mockV3Aggregator)
        });
        return anvilEthToUsdPriceFeed;

    }
}
