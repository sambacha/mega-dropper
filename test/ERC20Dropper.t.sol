// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {MockERC20} from "./mock/MockERC20.sol";

/// @author philogy <https://github.com/philogy>
contract ERC20DropperTest is Test {
    address airdropper;

    MockERC20 token;

    function setUp() public {
        string[] memory args = new string[](3);
        args[0] = "huffc";
        args[1] = "-b";
        args[2] = "src/ERC20Dropper.huff";
        bytes memory bytecode = vm.ffi(args);
        address addr;
        assembly {
            addr := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        airdropper = addr;

        token = new MockERC20();
    }

    function testSingleERC20() public {
        address sender = makeAddr("sender");
        address to = makeAddr("recipient_1");

        token.mint(sender, 10e18);

        vm.startPrank(sender);

        token.approve(airdropper, type(uint256).max);

        (bool success,) = airdropper.call(abi.encodePacked(uint96(3e18), token, to, uint96(2.9e18)));

        assertTrue(success);

        assertEq(token.balanceOf(airdropper), 0.1e18);
        assertEq(token.balanceOf(to), 2.9e18);
        assertEq(token.balanceOf(sender), 7e18);
    }

    function test_fuzzingTransfers(uint256 totalRecipients, bytes32 seed) public {
        address sender = makeAddr("sender");

        totalRecipients = bound(totalRecipients, 1, 400);
        address[] memory recipients = new address[](totalRecipients);
        uint256[] memory amounts = new uint[](totalRecipients);
        bytes32[] memory params = new bytes32[](totalRecipients);

        uint256 total = 0;

        for (uint256 i = 0; i < totalRecipients; i++) {
            seed = keccak256(abi.encodePacked(seed));
            address to = vm.addr(1 + i);
            recipients[i] = to;
            uint256 amount = bound(uint256(seed), 0 wei, 1e18);
            amounts[i] = amount;

            total += amount;
            params[i] = bytes32(abi.encodePacked(to, uint96(amount)));
        }

        token.mint(sender, total);

        vm.startPrank(sender);

        token.approve(airdropper, type(uint256).max);

        (bool success,) = airdropper.call(abi.encodePacked(uint96(total), token, params));
        assertTrue(success);

        vm.stopPrank();

        for (uint256 i; i < totalRecipients; i++) {
            assertEq(token.balanceOf(recipients[i]), amounts[i]);
        }
    }
}
