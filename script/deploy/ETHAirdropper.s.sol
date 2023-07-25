// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {HuffDeployer} from "smol-huff-deployer/HuffDeployer.sol";
import {console2 as console} from "forge-std/console2.sol";

/// @author philogy <https://github.com/philogy>
contract ETHAirdropperScript is Script, HuffDeployer {
    function run() public {
        bytes32[] memory packets = new bytes32[](800);
        for (uint256 i = 0; i < packets.length; i++) {
            packets[i] = bytes32(abi.encodePacked(uint96(1 ether), vm.addr(i + 3)));
        }

        vm.startBroadcast(vm.envUint("PRIV_KEY"));

        address airdropper = deploy("src/ETHAirdropper.huff");
        console.log("size: %s", airdropper.code.length);

        bool success;

        assembly {
            success :=
                call(gas(), airdropper, 800000000000000000000, add(packets, 0x20), mul(mload(packets), 0x20), 0, 0)
        }
        require(success);

        vm.stopBroadcast();
    }
}
