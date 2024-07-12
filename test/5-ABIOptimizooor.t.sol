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
        // Uncompressed data
        //bytes memory _calldata =abi.encodePacked(ABIOptimizooor.foo.selector,
        //    bytes32(0x0000000000000000000000000000000000000000000000000000000000000060),    // Pointer to x
        //    bytes32(0x0000000000000000000000000000000000000000000000000000000000000080),    // Pointer to y
        //    bytes32(0x00000000000000000000000000000000000000000000000000000000000000e0),    // Pointer to z
        //    bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),    // x.length = 0
        //    bytes32(0x0000000000000000000000000000000000000000000000000000000000000002),    // y.length = 2
        //    bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),    // y[0] = 1
        //    bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),    // y[1] = 1
        //    bytes32(0x0000000000000000000000000000000000000000000000000000000000000002),    // z.length = 2
        //    bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),    // z[0] = 1
        //    bytes32(0x0000000000000000000000000000000000000000000000000000000000000000)     // z[1] = 1
        //    );  

        // Compressed data
        bytes memory _calldata =abi.encodePacked(ABIOptimizooor.foo.selector,
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000080),// Pointer to x
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000060),// Pointer to y
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000060),// Pointer to z
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000002),// y.length = 2 & z.length = 2
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000),// y[0] = 0 & z[0] = 0 & x.length = 0
            bytes32(0x0000000000000000000000000000000000000000000000000000000000000000) // y[1] = 0 & z[1] = 0
            );  

        address(abiOptimizooor).call(_calldata);
        assertTrue(abiOptimizooor.isSolved());
    }
}
