// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract Logic{
    address public implementation;
    uint public x = 99;
    event CallSuccess();

    function increment() external returns (uint256){
        emit CallSuccess();
        return x+1;
    }
}