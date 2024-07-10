// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "./ISolvable.sol";

/**
 * @title Bank
 * @dev You can see how this challenge was deployed by looking at `Core.sol`.
 * Simple Bank application, users can deposit funds and withdraw it later.
 * Only externally owned accounts (EOA) are permitted to interact with the application.
 */
contract Bank is Solvable {
    event Registration(address wallet);
    event Deregistration(address wallet);

    mapping(address => uint) public balances;
    mapping(address => bool) public externalAccounts;

    error ContractAccount();
    error UnknownAccount();

    modifier onlyEOA(address addr) {
        if (isContract(addr)) revert ContractAccount();
        _;
    }

    modifier onlyRegWallets(address addr) {
        if (!externalAccounts[addr]) revert UnknownAccount();
        _;
    }

    constructor() payable {
        require(msg.value == 1 ether, "1 ether is required to deploy the bank!");
    }

    function registerWallet() external onlyEOA(msg.sender) {
        require(!externalAccounts[msg.sender], "Already registered");
        externalAccounts[msg.sender] = true;
        emit Registration(msg.sender);
    }

    function unregisterWallet() external onlyRegWallets(msg.sender) {
        externalAccounts[msg.sender] = false;
        emit Deregistration(msg.sender);
    }

    function deposit(uint amount) external payable onlyRegWallets(msg.sender) {
        require(msg.value == amount, "Insufficient funds");
        balances[msg.sender] += amount;
    }

    function depositFor(
        address wallet,
        uint amount
    ) external payable onlyRegWallets(wallet) {
        require(msg.value == amount, "Insufficient funds");
        balances[wallet] += amount;
    }

    function withdraw() external onlyRegWallets(msg.sender) {
        uint balance = balances[msg.sender];
        require(balance > 0, "Nothing to withdraw");
        (bool sent, ) = msg.sender.call{value: balance}("");
        require(sent, "Failed to send Ether");
        balances[msg.sender] = 0;
    }

    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function isSolved() external view returns(bool) {
        return address(this).balance == 0;
    }
}
