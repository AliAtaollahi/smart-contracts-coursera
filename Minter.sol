// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Coin {
    // Public state
    address public minter;
    mapping(address => uint256) public balances;

    // Events
    event Sent(address indexed from, address indexed to, uint256 amount);

    // Constructor
    constructor() {
        minter = msg.sender;
    }

    // Modifiers
    modifier onlyMinter() {
        require(msg.sender == minter, "Not minter");
        _;
    }

    // Mint new coins to `receiver`
    function mint(address receiver, uint256 amount) external onlyMinter {
        require(receiver != address(0), "Zero receiver");
        balances[receiver] += amount; // safe in 0.8.x (checked math)
    }

    // Send coins to `receiver`
    function send(address receiver, uint256 amount) external {
        require(receiver != address(0), "Zero receiver");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[receiver] += amount;

        emit Sent(msg.sender, receiver, amount);
    }
}
