// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract Proxy{
    address public implementation;// 逻辑合约地址，implementation合约的同一个位置的状态变量类型必须和Proxy位置一致
    constructor(address _implementation){
        implementation=_implementation;
    }

    /**
* @dev 回调函数，将本合约的调用委托给 `implementation` 合约
* 通过assembly，让回调函数也能有返回值
*/
fallback() external payable {
    address _implementation = implementation;
    assembly {
        // 将msg.data拷贝到内存里
        // calldatacopy操作码的参数: 内存起始位置，calldata起始位置，calldata长度
        calldatacopy(0, 0, calldatasize())

        // 利用delegatecall调用implementation合约
        // delegatecall操作码的参数：gas, 目标合约地址，input mem起始位置，input mem长度，output area mem起始位置，output area mem长度
        // output area起始位置和长度位置，所以设为0
        // delegatecall成功返回1，失败返回0
        let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)

        // 将return data拷贝到内存
        // returndata操作码的参数：内存起始位置，returndata起始位置，returndata长度
        returndatacopy(0, 0, returndatasize())

        switch result
        // 如果delegate call失败，revert
        case 0 {
            revert(0, returndatasize())
        }
        // 如果delegate call成功，返回mem起始位置为0，长度为returndatasize()的数据（格式为bytes）
        default {
            return(0, returndatasize())
        }
    }
}

    function abiEncodeSignSelector()external pure returns(bytes4  res ){
        res =bytes4(keccak256("increment()"));
    }

}