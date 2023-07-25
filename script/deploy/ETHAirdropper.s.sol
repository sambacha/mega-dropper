// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {HuffDeployer} from "smol-huff-deployer/HuffDeployer.sol";
import {console2 as console} from "forge-std/console2.sol";

/// @author philogy <https://github.com/philogy>
contract ETHAirdropperScript is Script, HuffDeployer {
    function run() public {
        bytes32[] memory packets = new bytes32[](1500);
        uint256 baseAmount = 1 ether;
        for (uint256 i = 0; i < packets.length; i++) {
            packets[i] = bytes32(abi.encodePacked(uint96(baseAmount), vm.addr(i + 3)));
        }
        uint256 total = packets.length * baseAmount;

        vm.startBroadcast(vm.envUint("PRIV_KEY"));

        for (uint256 i = 0; i < packets.length; i++) {
            payable(vm.addr(i + 3)).transfer(1 wei);
        }

        address airdropper = deploy("src/ETHAirdropper.huff");
        console.log("size: %s", airdropper.code.length);

        bool success;

        assembly {
            success := call(gas(), airdropper, total, add(packets, 0x20), mul(mload(packets), 0x20), 0, 0)
        }
        require(success);

        vm.stopBroadcast();
    }
}
