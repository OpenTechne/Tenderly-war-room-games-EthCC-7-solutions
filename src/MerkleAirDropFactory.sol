// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "./4-MerkleAirDrop.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";

/**
 * @dev Library used by the Core contract to deploy the challenge `MerkleAirDrop.sol`
 */
library MerkleAirDropFactory {

    bytes32 private constant EIP712DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 public constant DROP_TYPEHASH = keccak256("Drop(address user,uint256 amount,bool premium)");

    address public constant VICTIM_ADDRESS = 0x0000000000000000000000000000bEEFBeeFBeEF;

    function deploy(address advAddress) external returns(ShinyToken) {
        ShinyToken token;
        bytes32[2] memory leafHash;
        bytes32 rootHash;

        address adversary = address(advAddress); // gift one AirDrop to the adversary
        token = new ShinyToken();

        leafHash[0] = _hashDrop(adversary, 100, false, token);
        leafHash[1] = _hashDrop(VICTIM_ADDRESS, 300, true, token);
        rootHash = _hashPair(leafHash[0], leafHash[1]);
        token.setTree(rootHash, 2);

        return token;
    }
    
    /**
     * @dev Sorts the pair (a, b) and hashes the result.
     */
    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    /**
     * @dev Implementation of keccak256(abi.encode(a, b)) that doesn't allocate or expand memory.
     */
    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }

    function _hashDrop(address user, uint amount, bool premium, ShinyToken token) private view returns(bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(
            DROP_TYPEHASH,
            user,
            amount,
            premium
        )), token);
    }

    function _hashTypedDataV4(bytes32 structHash, ShinyToken token) internal view returns (bytes32) {
        return MessageHashUtils.toTypedDataHash(_buildDomainSeparator(token), structHash);
    }

    function _buildDomainSeparator(ShinyToken token) private view returns (bytes32) {
        return keccak256(abi.encode(
            EIP712DOMAIN_TYPEHASH, 
            keccak256("MerkleAirDrop"), 
            keccak256("1"), 
            block.chainid, 
            address(token)
        ));
    }
}
