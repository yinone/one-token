// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {OneToken} from "../src/OneToken.sol";

contract DeployOneToken is Script {
    function run() external returns (OneToken token) {
        vm.startBroadcast();
        // 广播账户即 owner，并持有初始供应；脚本里的 msg.sender 不是广播账户，要从 readCallers 取
        (, address deployer,) = vm.readCallers();
        token = new OneToken(deployer, 1_000_000 ether, 10_000_000 ether);
        vm.stopBroadcast();

        console.log("OneToken deployed at", address(token));
    }
}
