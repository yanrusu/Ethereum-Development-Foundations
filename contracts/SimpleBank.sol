// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom( address from, address to, uint256 value) external returns (bool);
    function transfer(address to, uint256 value ) external returns (bool);
}
contract SimpleBank{
    
    address public _token;
    mapping (address => uint) public deposits;

    constructor(address addr){
        _token = addr;
    }

    function deposit(uint256 amount) external {
        IERC20(_token).transferFrom(msg.sender,address(this),amount);
        deposits[msg.sender] += amount;
    }

    function withdraw(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "insufficient deposit");
        deposits[msg.sender] -= amount;
        IERC20(_token).transfer(msg.sender,amount);
        //attack
        //IERC20(_token).transfer(msg.sender,amount);
        //deposits[msg.sender] -= amount;
    }

}