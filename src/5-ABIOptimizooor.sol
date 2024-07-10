// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "./ISolvable.sol";

/**
 * @title ABIOptimizooor
 * @dev You can see how this challenge was deployed by looking at `Core.sol`.
 */
contract ABIOptimizooor is Solvable {

    bool solved;

    function foo(uint[] calldata x, uint[] calldata y, uint[] calldata z) external {
        assert(msg.data.length <= 196);
        assert (x.length == 0);
        assert (y.length == 2);
        assert (z.length == 2);
        solved = true;
    }

    function isSolved() external view returns(bool) {
        return solved;
    }
}