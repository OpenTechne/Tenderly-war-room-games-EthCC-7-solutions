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
        assertTrue(MultiCallProxy(payable(address(multiCall))).isSolved());
    }
}
