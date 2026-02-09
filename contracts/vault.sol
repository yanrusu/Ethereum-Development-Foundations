// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(address from, address to, uint256 value) external returns (bool); }

contract Vault {
    address public owner;
     constructor() {
        owner = msg.sender;
    }
    function pullToken(address token, address from, uint256 amount) external {
        require(msg.sender == owner);
        IERC20(token).transferFrom(from, address(this), amount);
    }
}
