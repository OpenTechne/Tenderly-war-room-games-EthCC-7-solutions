// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {Test, console} from "forge-std/Test.sol";
import {ShinyToken} from "challenges/4-MerkleAirDrop.sol";
import {MerkleAirDropFactory} from "challenges/MerkleAirDropFactory.sol";

contract MerkleAirDropTest is Test {
    address public immutable advAddress = makeAddr("advAddress");
    ShinyToken public shinyToken;

    function setUp() public {
        shinyToken = ShinyToken(MerkleAirDropFactory.deploy(advAddress));
    }

    function test_solve() public {
        assertTrue(shinyToken.isSolved());
    }
}
