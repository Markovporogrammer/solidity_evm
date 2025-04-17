// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
// 可升级合约
// 简单的可升级合约，管理员可以通过升级函数更改逻辑合约地址，从而改变合约的逻辑。
contract UnGradeable{
    address public implementation;// 逻辑合约地址
    address public admin;// 管理员
    string public words;

    constructor(address implementation_){
        admin = msg.sender;
        implementation = implementation_;
    }

    fallback() external payable { 
        (bool succ, bytes memory data) = implementation.delegatecall(msg.data);
    }

    // 升级函数
    function upgrade(address newImplementation)external {
        require(msg.sender==admin,"only admin call");
        implementation = newImplementation;
    }

}