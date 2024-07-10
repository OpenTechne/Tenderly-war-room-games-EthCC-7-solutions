// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {Test, console} from "forge-std/Test.sol";
import {ABIOptimizooor} from "challenges/5-ABIOptimizooor.sol";

contract ABIOptimizooorTest is Test {
    ABIOptimizooor public abiOptimizooor;

    function setUp() public {
        abiOptimizooor = new ABIOptimizooor();
    }

    function test_solve() public {
        assertTrue(abiOptimizooor.isSolved());
    }
}
