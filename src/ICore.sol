// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "./ISolvable.sol";

/**
 * @dev Interface for the Core contract
 */
interface ICore {
    function deployChallenge(uint256 index) external payable;
    function getScoreAll() external returns(uint256 totalScore);
    function getScore(uint256 index) external returns(uint256 score);
    function challenges(uint256 index) external returns(Solvable);
}