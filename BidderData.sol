// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bidder {
    string public name;
    uint256 public bidAmount = 20000;
    bool public eligible;
    uint256 constant minBid = 1000;
}
