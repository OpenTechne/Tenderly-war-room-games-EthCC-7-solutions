// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "./ISolvable.sol";

/**
/**
 * @title MultiCall
 * @dev You can see how this challenge was deployed by looking at `Core.sol`.
 *
 * This contract allows to batch operations into one transaction and safe up on fees.
 * Operations include depositing money in the contract and executing payments in favor of a chosen recipient.
 *
 * The contract uses a proxy pattern.
 * The MulticallProxy contract is the proxy.
 * The MultiCall contract is the initial implementation.
 * 
 * The proxy has an admin that is allowed to change the implementation.
 * Anyone can propose a new admin, but only the admin can approve the proposal.
 *
 */
contract MultiCallProxy is ERC1967Proxy, Solvable {
    address proposedAdmin;
    address admin;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not the admin");
        _;
    }

    constructor(address initialImpl) ERC1967Proxy(initialImpl, "") {
        admin = msg.sender;
    }

    /**
     * @notice Propose a new admin for the proxy contract.
     * @param newProposedAdmin the new admin to propose.
     */
    function proposeAdmin(address newProposedAdmin) public payable {
        require(msg.value == 1 ether, "1 ether is required to propose an admin");
        proposedAdmin = newProposedAdmin;
    }

    /**
     * @notice approve the proposed admin (only admin).
     * @param approvedAdmin the admin to approve (must be the same as the proposed admin).
     */
    function approveAdmin(address approvedAdmin) public onlyAdmin {
        require(proposedAdmin == approvedAdmin, "Invalid admin to approve");
        admin = proposedAdmin;
    }

    function isSolved() external view returns(bool) {
        return address(this).balance == 0;
    }
}

/**
 * @dev MultiCall implementation
 */
contract MultiCall {
    bool depositLocked;
    address admin;
    mapping(address => uint256) public balances;

    modifier onlyDepositUnlocked() {
        require(!depositLocked, "Deposit is locked");
        _;
    }

    /**
     * @notice Deposit funds in the contract.
     */
    function deposit() external payable onlyDepositUnlocked {
        balances[msg.sender] += msg.value;
    }

    /**
     * @notice Execute a transfer.
     * @param to the recipient's address.
     * @param value the amount to transfer.
     */
    function execute(address to, uint256 value) external {
        require(balances[msg.sender] >= value, "Insufficient balance");
        balances[msg.sender] -= value;

        payable(to).transfer(value);
    }

    /**
     * @notice Execute multiple function calls within the contract.
     * @param dataArray a list of function calls encoded as bytes.
     * @dev for security reasons, multicall cannot call itself. Also, at most one
     * call to the deposit function is allowed.
     */
    function multicall(bytes[] calldata dataArray) external payable {
        depositLocked = false;
        for (uint256 i = 0; i < dataArray.length; i++) {
            bytes memory data = dataArray[i];
            bytes4 selector = getSelector(data);

            require(selector != MultiCall.multicall.selector, "Multicall cannot call multicall");

            (bool success, ) = address(this).delegatecall(data);
            require(success, "Error while delegating call");

            if (selector == MultiCall.deposit.selector) {
                depositLocked = true;
            }
        }
        depositLocked = false;
    }

    /**
     * @notice Return the function selector.
     * @param data bytes representing a function call.
     * @return four bytes representing the function selector.
     */
    function getSelector(bytes memory data) private pure returns (bytes4) {
        bytes4 selector;
        assembly {
            selector := mload(add(data, 32))
        }
        return selector;
    }
}
