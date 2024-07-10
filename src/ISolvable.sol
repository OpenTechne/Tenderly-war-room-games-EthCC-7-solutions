// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/**
 * @dev Interface that every challenge extends
 */
interface Solvable {
    function isSolved() external view returns (bool);
}
