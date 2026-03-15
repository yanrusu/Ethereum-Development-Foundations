// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Reentryattack_bank {
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    mapping (address => uint) public deposits;

    function deposit() external payable {
        deposits[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "insufficient deposit");
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success,"Failed");
        unchecked {deposits[msg.sender] -= amount;}
        // deposits[msg.sender] -= amount;
        emit Withdraw(msg.sender, amount);
    }
    
    function withdrawall() external {
        // require(deposits[msg.sender] >= amount, "insufficient deposit");
        (bool success, ) = msg.sender.call{value: deposits[msg.sender]}("");
        require(success,"Failed");
        // unchecked {deposits[msg.sender] -= amount;}
        deposits[msg.sender] = 0;
        // emit Withdraw(msg.sender, amount);
    }    

}
