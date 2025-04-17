// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
contract Logic1{
    address public implementation;// 逻辑合约地址
    address public admin;// 管理员
    string public words;
// 改变proxy中状态变量，选择器：0xc2985578 bytes(keccak256("foo"))
    function foo() public  {
        words = "new_foo";
    }
}