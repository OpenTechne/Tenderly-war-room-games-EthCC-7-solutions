// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";
import "./ISolvable.sol";

/**
 * @title MerkleAirDrop
 * @dev You can see how this challenge was deployed by looking at `Core.sol`.
 * @dev This challenge was deployed using `MerkleAirDropFactory.sol`.
 *
 * "Ehm, thanks I guess..."
 *
 * Merkle air-drops are a sensible alternative to spending tons of gas to mint 
 * tokens on-chain to unsuspecting innocent users who might not even want them.
 * A Merkle tree, containing all the individual drops, is generated off-chain:
 * OpenZeppelin and the like provide a backend library to generate proofs which
 * will then be recognised by their on-chain counterpart. All the admin needs to
 * do is push the root hash on chain, and distribute the proofs off-chain.
 * 
 * In this challenge, we want to give away our ERC20 tokens using this scheme,
 * but we further want to integrate it with our custom air-drop features. 
 * 1. The first 1000 users to actually redeem their gift receive twice as many
 *    tokens as they were allocated.
 * 2. Some "premium" drops entitle the user to participate in a raffle that will
 *    award 200 tokens to the winner (the raffle itself is not implemented).
 */
contract ShinyToken is Ownable, EIP712, ERC20, Solvable {
    mapping(uint => uint) private redeemed; // Bitmap
    bytes32 private rootHash;
    uint private totLeaves;
    uint public numRedemptions;
    // Raffle data structures (not implemented)

    bytes32 public constant DROP_TYPEHASH = keccak256("Drop(address user,uint256 amount,bool premium)");


    constructor()
        Ownable(msg.sender)
        EIP712("MerkleAirDrop", "1")
        ERC20("ShinyToken", "SHNY")
        {}
    
    function setTree(bytes32 _rootHash, uint _totLeaves) external onlyOwner {
        rootHash = _rootHash;
        totLeaves = _totLeaves;
    }

    function isRedeemed(uint256 index) public view returns (bool) {
        uint256 wordIndex = index / 256;
        uint256 bitIndex = index % 256;
        uint256 word = redeemed[wordIndex];
        uint256 mask = (1 << bitIndex);
        return word & mask == mask;
    }

    function _setRedeemed(uint256 index) private {
        uint256 wordIndex = index / 256;
        uint256 bitIndex = index % 256;
        uint256 mask = (1 << bitIndex);
        redeemed[wordIndex] |= mask;
    }

    // Use an explicit credit account, instead of msg.sender, so that someone
    // else might call this function to pay the user's gas fees.
    function redeem(address user, uint amount, bool premium, 
                    uint leafIndex, bytes32[] calldata proof) 
                    external {
        require(leafIndex < totLeaves, "Leaf index out of bounds");
        require(!isRedeemed(leafIndex), "Replay protection");
        _setRedeemed(leafIndex);

        // Reconstruct the hash of the leaf, including special features
        bytes32 leafHash = _hashDrop(user, amount, premium);
        require(MerkleProof.verifyCalldata(proof, rootHash, leafHash), "Verification failed");

        // Redeem
        if (numRedemptions++ < 1000) {
            amount *= 2;
        }
        _mint(user, amount);

        if (premium) {
            // Raffle logic
        }

        return;
    }

    function _hashDrop(address user, uint amount, bool premium) private view returns(bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(
            DROP_TYPEHASH,
            user,
            amount,
            premium
        )));
    }

    // The challenge is solved when all the airdrops have been redeemed.
    function isSolved() external view returns(bool) {
        return numRedemptions == totLeaves;
    }
}