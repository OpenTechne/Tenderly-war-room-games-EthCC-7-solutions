// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "./ISolvable.sol";

/**
 * @title HelloWorld
 * @dev You can see how this challenge was deployed by looking at `Core.sol`.
 */
contract HelloWorld is Solvable {
    bytes32 private immutable _answer;

    bool public success;

    constructor() {
        _answer = keccak256(abi.encodePacked("HelloWorld"));
    }

    function answer(string calldata data) external {
        bytes32 hash = keccak256(abi.encodePacked(data)); 
        if (hash == _answer) {
            success = true;
        }
    }
    
    function isSolved() external view returns(bool) {
        return success;
    }
}