// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/console.sol";
import "forge-std/Script.sol";
import "../src/contract/RSMemberNFT.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract RSMemberNFTScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address owner = vm.envAddress("OWNER");

        address uupsProxy =
            Upgrades.deployUUPSProxy("RSMemberNFT.sol", abi.encodeCall(RSMemberNFT.initialize, (owner)));

        console.log("uupsProxy deploy at %s", uupsProxy);

        // contract upgrade
        // Upgrades.upgradeProxy(
            // 0xc580E034288517CdC99B807E5dcdf6cC1b27181d,//代理地址
            // "RSMemberNFT.sol",
            // ""
        // );

        vm.stopBroadcast();
    }
}
