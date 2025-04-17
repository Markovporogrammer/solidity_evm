// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract UUPSProxy{
    address public implementation;// 逻辑合约地址
    address public admin;
    string public words;

    constructor(address implementation_){
        implementation = implementation_;
        admin = msg.sender;
    }

    fallback() external payable { 
        (bool succ, bytes memory data) = implementation.delegatecall(msg.data);
    }

    // 获取选择器 参数1对于代理的方法名 foo()
    function getAbiBytes(string memory fun) public pure returns (bytes4 res){
        res = bytes4(keccak256(bytes(fun)));
    }

    // abi的hasx调用新函数的bytes
    // 参数1 upgrade(address)， 参数2 0x6b8588E0BaAa2a027F0c7A5bA201D009bC76E459
    function getAbiHash(string memory funname, address addr) public pure returns (bytes memory res){
        res= abi.encodeWithSelector(getAbiBytes(funname), addr);
    }

}