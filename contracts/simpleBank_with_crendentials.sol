// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom( address from, address to, uint256 value) external returns (bool);
    function transfer(address to, uint256 value ) external returns (bool);
}
interface Ib_token {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
}
contract SimpleBank1{
    
    address public _token;
    address public b_token;
    address public owner_;
    mapping (address => uint) public deposits;

    modifier only_owner() {
        require(owner_ == msg.sender,"not the owner");
        _;
    }
    constructor(address token_addr,address btoken_addr){
        _token = token_addr;
        b_token = btoken_addr;
    }

    function deposit(uint256 amount) external {
        IERC20(_token).transferFrom(msg.sender,address(this),amount);
        Ib_token(b_token).mint(msg.sender, amount);
        deposits[msg.sender] += amount;

    }

    function withdraw(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "insufficient deposit");
        deposits[msg.sender] -= amount;

        Ib_token(b_token).burn(msg.sender, amount);
        IERC20(_token).transfer(msg.sender, amount);
        //attack
        //IERC20(_token).transfer(msg.sender,amount);
        //deposits[msg.sender] -= amount;
    }
}