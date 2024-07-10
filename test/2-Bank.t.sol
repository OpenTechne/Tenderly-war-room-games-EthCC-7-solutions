// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {Test, console} from "forge-std/Test.sol";
import {Bank} from "challenges/2-Bank.sol";

contract BankTest is Test {
    Bank public bank;

    function setUp() public {
        bank = new Bank{value: 1 ether}();
    }

    function test_solve() public {
        assertTrue(bank.isSolved());
    }
}
