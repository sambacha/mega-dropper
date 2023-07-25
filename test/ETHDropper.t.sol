// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";

/// @author philogy <https://github.com/philogy>
contract ETHDropper is Test {
    address airdropper;

    function setUp() public {
        string[] memory args = new string[](3);
        args[0] = "huffc";
        args[1] = "-b";
        args[2] = "src/ETHAirdropper.huff";
        bytes memory bytecode = vm.ffi(args);
        address addr;
        assembly {
            addr := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        airdropper = addr;
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

    function test_fuzzingTransfers(uint256 totalRecipients, bytes32 seed) public {
        totalRecipients = bound(totalRecipients, 1, 400);

        address[] memory recipients = new address[](totalRecipients);
        uint256[] memory amounts = new uint[](totalRecipients);
        bytes32[] memory params = new bytes32[](totalRecipients);

        uint256 total = 0;

        for (uint256 i = 0; i < totalRecipients; i++) {
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

        for (uint256 i; i < totalRecipients; i++) {
            assertEq(recipients[i].balance, amounts[i]);
        }
    }
}
