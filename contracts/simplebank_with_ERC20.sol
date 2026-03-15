
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom( address from, address to, uint256 value) external returns (bool);
    function transfer(address to, uint256 value ) external returns (bool);
}

contract SimpleBank_with_ERC20{
    address public token_;
    address public owner_;

    constructor(address token_addr) {
        token_ = token_addr;
        owner_ = msg.sender;
    }

    string public name = "B_test Token";
    string public symbol = "BTOK";
    
    uint256 public totalSupply_;

    mapping(address => uint256) public _balanceOf;
    mapping(address => mapping(address => uint256)) public _allowance;

    mapping (address => uint) public deposits;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed from, address indexed to, uint256 indexed);
    event Burn(address indexed from, address indexed to, uint256 indexed);

    function totalSupply() external view returns (uint256){
        return totalSupply_;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowance[owner][spender];
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balanceOf[account];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(to != address(0), "Invalid address");
        require(_balanceOf[msg.sender] >= value, "Insufficient balance");

        _balanceOf[msg.sender] -= value;
        _balanceOf[to] += value;

        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(to != address(0), "Invalid address");
        require(_balanceOf[from] >= value, "Insufficient balance");
        require(_allowance[from][msg.sender] >= value, "Allowance exceeded");

        _balanceOf[from] -= value;
        _balanceOf[to] += value;
        _allowance[from][msg.sender] -= value;

        emit Transfer(from, to, value);
        return true;
    }

    function _mint(address to, uint256 amount) internal { 
        totalSupply_ += amount;
        _balanceOf[to] += amount;
        emit Mint(address(this), to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        require(_balanceOf[from]>=amount,"insufficient bToken");
        totalSupply_ -= amount;
        _balanceOf[from] -= amount;
        emit Burn(from, address(0),amount);
    }

    function deposit(uint256 amount) external {
        IERC20(token_).transferFrom(msg.sender,address(this),amount);
        _mint(msg.sender, amount);
        deposits[msg.sender] += amount;
    }

    function withdraw(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "insufficient deposit");
        deposits[msg.sender] -= amount;
        _burn(msg.sender, amount);
        IERC20(token_).transfer(msg.sender, amount);
    }
}