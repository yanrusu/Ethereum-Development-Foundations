// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Hash {
    function hashexample(address addr) internal pure returns (bytes32) {
        return keccak256(abi.encode(addr));
    }
}
