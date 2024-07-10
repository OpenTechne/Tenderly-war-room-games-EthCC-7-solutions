// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "./ISolvable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

/**
 * @title Vault
 * @dev You can see how this challenge was deployed by looking at `Core.sol`.
 *
 * Description:
 * Simple vault application, users can deposit specific tokens and withdraw it later.
 * This challenge uses the fact that Tenderly virtual testnets fork mainnet.
 * Hence, here you interact with real mainnet contracts.
 * Your account should have a starting balance of some of these tokens.
 * Check your token balances using: forge script script/TokenStatus.s.sol --rpc-url $RPC_URL
 */
contract Vault is Solvable {
    // Predefined list of ERC20 tokens
    IERC20[] public allowedTokens;
    mapping(address => mapping(IERC20 => uint256)) public balances;
    mapping(IERC20 => uint256) public totalBalances;

    constructor() {
        allowedTokens = [
            IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F),
            IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48),
            IERC20(0xD37EE7e4f452C6638c96536e68090De8cBcdb583),
            IERC20(0xA17581A9E3356d9A858b789D68B4d866e593aE94),
            IERC20(0xbe0Ed4138121EcFC5c0E56B40517da27E6c5226B)
        ];
    }

    // Modifier to check if the token is allowed
    modifier onlyAllowedToken(IERC20 token) {
        require(isTokenAllowed(token), "Token is not allowed");
        _;
    }

    function allAllowedTokens() external view returns (IERC20[] memory) {
        return allowedTokens;
    }

    // Function to check if a token is allowed
    function isTokenAllowed(IERC20 token) public view returns (bool) {
        for (uint256 i = 0; i < allowedTokens.length; i++) {
            if (allowedTokens[i] == token) {
                return true;
            }
        }
        return false;
    }

    // Deposit function
    function deposit(IERC20 token, uint256 amount) external onlyAllowedToken(token) {
        require(amount > 0, "Amount must be greater than 0");
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        balances[msg.sender][token] += amount;
        totalBalances[token] += amount;
    }

    // Withdraw function
    function withdraw(IERC20 token, uint256 amount) external onlyAllowedToken(token) {
        require(amount > 0, "Amount must be greater than 0");
        require(balances[msg.sender][token] >= amount, "Insufficient balance");

        balances[msg.sender][token] -= amount;
        totalBalances[token] -= amount;
        require(token.transfer(msg.sender, amount), "Transfer failed");
    }

    function isSolved() external view returns (bool) {
        for (uint256 i = 0; i < allowedTokens.length; i++) {
            if (totalBalances[allowedTokens[i]] >= 2 ** 128) {
                return true;
            }
        }
        return false;
    }
}
