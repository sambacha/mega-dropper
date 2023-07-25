// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {console2 as console} from "forge-std/console2.sol";
import {WenTokens} from "src/other/WenTokens.sol";

/// @author philogy <https://github.com/philogy>
contract ETHAirdropperScript is Script {
    function run() public {
        bytes32[] memory packets = new bytes32[](50);
        address[] memory recipients = new address[](packets.length);
        uint256[] memory amounts = new uint[](packets.length);
        uint256 baseAmount = 1 ether;
        for (uint256 i = 0; i < packets.length; i++) {
            recipients[i] = vm.addr(i + 3);
            amounts[i] = baseAmount;
            packets[i] = bytes32(abi.encodePacked(uint96(baseAmount), vm.addr(i + 3)));
        }
        uint256 total = packets.length * baseAmount;

        vm.startBroadcast(vm.envUint("PRIV_KEY"));

        for (uint256 i = 0; i < packets.length; i++) {
            payable(vm.addr(i + 3)).transfer(1 wei);
        }

        string[] memory args = new string[](3);
        args[0] = "huffc";
        args[1] = "-b";
        args[2] = "src/ETHDropper.huff";
        bytes memory bytecode = vm.ffi(args);
        address airdropper;
        assembly {
            airdropper := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        console.log("size: %s", airdropper.code.length);

        WenTokens wenTokens = new WenTokens();

        bool success;

        assembly {
            success := call(gas(), airdropper, total, add(packets, 0x20), mul(mload(packets), 0x20), 0, 0)
        }
        require(success);

        wenTokens.airdropETH{value: total}(recipients, amounts);

        vm.stopBroadcast();
    }
}
