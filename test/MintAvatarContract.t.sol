// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/contract/MintAvatarContract.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract TestMintAvatarContractt is Test {

    address constant OWNER_ADDRESS = 0xC565FC29F6df239Fe3848dB82656F2502286E97d;

    address private proxy;
    MintAvatarContract private instance;

    function setUp() public {
        console.log("=======setUp============");
        proxy = Upgrades.deployUUPSProxy(
            "MintAvatarContract.sol",
            abi.encodeCall(MintAvatarContract.initialize, OWNER_ADDRESS)
        );
        console.log("uups proxy -> %s", proxy);

        instance = MintAvatarContract(proxy);
        assertEq(instance.owner(), OWNER_ADDRESS);

        address implAddressV1 = Upgrades.getImplementationAddress(proxy);
        console.log("impl proxy -> %s", implAddressV1);
    }

    function testMint() public {
        console.log("testMint");
        // vm.prank(OWNER_ADDRESS);

        vm.startPrank(OWNER_ADDRESS);
        string memory name = unicode"xxx";
        string memory contentId = "1";
        uint8 contentType = 1;
        uint256 tokenId = instance.mint(name, contentType, contentId);
        assertEq(tokenId, 1, string.concat("tokenId != 1, ", Strings.toString(tokenId)));
        vm.stopPrank();
    }
}
