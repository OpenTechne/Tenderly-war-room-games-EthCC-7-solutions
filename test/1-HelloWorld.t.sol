// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {Test, console} from "forge-std/Test.sol";
import {HelloWorld} from "challenges//1-HelloWorld.sol";

contract HelloWorldTest is Test {
    HelloWorld public helloWorld;

    function setUp() public {
        helloWorld = new HelloWorld();
    }

    function test_solve() public {
        helloWorld.answer("HelloWorld");
        assertTrue(helloWorld.isSolved());
    }
}
