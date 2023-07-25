// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {HuffDeployer} from "smol-huff-deployer/HuffDeployer.sol";

/// @author philogy <https://github.com/philogy>
contract LeBrokenTest is Test, HuffDeployer {
    address airdropper;

    function setUp() public {
        airdropper = deploy("src/ETHAirdropper.huff");
    }

    function testSingle() public {
        address to1 = makeAddr("recipient_1");
        address sender = makeAddr("sender");

        hoax(sender, 1.2 ether);

        (bool success,) = airdropper.call{value: 1.2 ether}(abi.encodePacked(uint96(1 ether), to1));
        assertTrue(success);

        assertEq(sender.balance, 0.2 ether);
        assertEq(to1.balance, 1 ether);
    }

    function testMany(uint256 total, bytes32 seed) public {
        total = bound(total, 1, 400);

        address[] memory recipients = new address[](total);
        uint256[] memory amounts = new uint[](total);
        bytes32[] memory params = new bytes32[](total);

        uint256 total = 0;

        for (uint256 i = 0; i < total; i++) {
            seed = keccak256(abi.encodePacked(seed));
            address to = vm.addr(1 + i);
            recipients[i] = to;
            uint256 amount = bound(uint256(seed), 0 wei, 1 ether);
            amounts[i] = amount;

            total += amount;
            params[i] = bytes32(abi.encodePacked(uint96(amount), to));
        }

        hoax(makeAddr("sender"), total);

        (bool success,) = airdropper.call{value: total}(abi.encodePacked(params));
        assertTrue(success);

        for (uint256 i; i < total; i++) {
            assertEq(recipients[i].balance, amounts[i]);
        }
    }
}
