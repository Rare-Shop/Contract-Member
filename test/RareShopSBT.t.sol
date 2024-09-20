// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/contract/RareShopSBT.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract TestRareShopSBT is Test {

    address constant OWNER_ADDRESS = 0xC565FC29F6df239Fe3848dB82656F2502286E97d;

    address private proxy;
    RareShopSBT private instance;

    function setUp() public {
        console.log("=======setUp============");
        proxy = Upgrades.deployUUPSProxy(
            "RareShopSBT.sol",
            abi.encodeCall(RareShopSBT.initialize, OWNER_ADDRESS)
        );
        console.log("uups proxy -> %s", proxy);

        instance = RareShopSBT(proxy);
        assertEq(instance.owner(), OWNER_ADDRESS);

        address implAddressV1 = Upgrades.getImplementationAddress(proxy);
        console.log("impl proxy -> %s", implAddressV1);
    }

    // function testMint() public {
        // console.log("testMint");
        // vm.startPrank(OWNER_ADDRESS);
        // address mintUser = 0xC565FC29F6df239Fe3848dB82656F2502286E97d;
        // instance.setSigner(OWNER_ADDRESS);
        // uint256 ret = instance.mint(mintUser, 1);
        // assertEq(ret, 1, string.concat("tokenId != 1, ", Strings.toString(ret)));
        // vm.stopPrank();
    // }
}
