// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Imagine a big integer that the whole world could share
contract SimpleStorage {
    uint256 private storedData;

    function set(uint256 x) external {
        storedData = x;
    }

    function get() external view returns (uint256) {
        return storedData;
    }

    function increment(uint256 n) external {
        storedData = storedData + n; // overflow/underflow checked in 0.8.x
    }

    function decrement(uint256 n) external {
        storedData = storedData - n; // reverts on underflow in 0.8.x
    }
}
