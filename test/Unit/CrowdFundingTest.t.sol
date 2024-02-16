// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Test, console} from "forge-std/Test.sol";
import {CrowdFunding} from "../../src/CrowdFunding.sol";
import {DeployCrowdFunding} from "../../script/DeployCrowdFunding.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract CrowdFundingTest is Test {
    CrowdFunding crowdFunding;
    HelperConfig helperConfig;

    address USER = makeAddr("USER");
    uint256 constant STARTING_BALANCE = 0.1 ether;

    function setUp() external {
        // crowdFunding = new CrowdFunding(100e18, 1708094597, 0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployCrowdFunding deployCrowdFunding = new DeployCrowdFunding();
       (crowdFunding, helperConfig) = deployCrowdFunding.run();
    }

    function testMinimumUsdIsFive() public {
        assertEq(crowdFunding.MINIMUM_USD(), 5e8);
    }

    function testOwnerIsMsgSender() public {
        assertEq(crowdFunding.owner(), msg.sender);
    }

    function testCampaignDurationNotPassed() public view {
        assert(crowdFunding.i_campaignDuration() > block.timestamp);
    }

    function testMinimumUsdIsLessThanMsgvalue() public {
        vm.expectRevert();
        crowdFunding.fundMe();
    }

    modifier timeNotPassed() {
        assert(crowdFunding.i_campaignDuration() > block.timestamp);
        _;
    }

    function testFunded() public timeNotPassed {
        uint256 startingAddressBalance = address(crowdFunding).balance;
        hoax(USER, STARTING_BALANCE);
        crowdFunding.fundMe{value: 6e8}();
        uint256 endingAddressBalance = address(crowdFunding).balance;
        assertEq(
            startingAddressBalance + 6e8,
            endingAddressBalance + startingAddressBalance
        );
    }

    modifier funded() {
        uint256 startingAddressBalance = address(crowdFunding).balance;
        hoax(USER, STARTING_BALANCE);
        crowdFunding.fundMe{value: 6e8}();
        uint256 endingAddressBalance = address(crowdFunding).balance;
        assertEq(
            startingAddressBalance + 6e8,
            endingAddressBalance + startingAddressBalance
        );
        _;
    }

    function testFunderIsInFundersArray() public funded {
        address funder = crowdFunding.getFundersArray(0);
        assertEq(funder, USER);
    }

    function testFunderIsInDataStructure() public funded {
        uint256 funderToAmtFunded = crowdFunding.getFundersToAmountFunded(USER);
        assertEq(funderToAmtFunded, 6e8);
    }

    function testTotalAmtFunded() public funded {
        uint256 totalAmtFunded = crowdFunding.getTotalAmountFunded();
        assertEq(totalAmtFunded, 6e8);
    }

    function testWithdraw() public funded {
        address owner = crowdFunding.owner();
        uint256 startingOwnerBalance = address(owner).balance;
        uint256 startingContractBalance = address(crowdFunding).balance;

        vm.prank(owner);
        crowdFunding.withdraw();
         uint256 endingOwnerBalance = address(owner).balance;
        uint256 endingContractBalance = address(crowdFunding).balance;
        assertEq(endingContractBalance, 0);
        assertEq(startingOwnerBalance + startingContractBalance, endingOwnerBalance);
    }
}

// 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
