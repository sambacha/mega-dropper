// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {console2 as console} from "forge-std/console2.sol";
import {WenTokens} from "src/other/WenTokens.sol";
import {MockERC20} from "test/mock/MockERC20.sol";

/// @author philogy <https://github.com/philogy>
contract ERC20AirdropperScript is Script {
    function run() public {
        bytes32[] memory packets = new bytes32[](100);
        address[] memory recipients = new address[](packets.length);
        uint256[] memory amounts = new uint[](packets.length);
        uint256 baseAmount = 1.2e18;
        for (uint256 i = 0; i < packets.length; i++) {
            recipients[i] = vm.addr(i + 3);
            amounts[i] = baseAmount;
            packets[i] = bytes32(abi.encodePacked(recipients[i], uint96(baseAmount)));
        }
        uint256 total = packets.length * baseAmount;

        uint256 pk = vm.envUint("PRIV_KEY");
        address sender = vm.addr(pk);
        vm.startBroadcast(pk);

        MockERC20 token = new MockERC20();
        /* for (uint256 i; i < recipients.length; i++) {
            token.mint(recipients[i], 1);
        } */

        string[] memory args = new string[](3);
        args[0] = "huffc";
        args[1] = "-b";
        args[2] = "src/ERC20Dropper.huff";
        bytes memory bytecode = vm.ffi(args);
        address airdropper;
        assembly {
            airdropper := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        console.log("size: %s", airdropper.code.length);

        WenTokens wenTokens = new WenTokens();

        token.mint(sender, total * 2);

        /* token.approve(airdropper, type(uint256).max);
        (bool success,) = airdropper.call(abi.encodePacked(uint96(total), token, packets));
        require(success); */

        token.approve(address(wenTokens), type(uint256).max);
        wenTokens.airdropERC20(address(token), recipients, amounts, total);

        vm.stopBroadcast();
    }
}
