// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
contract UUPS1 {
    address public implementation;// 逻辑合约地址
    address public admin;
    string public words;

    function foo() public {
        words = "new";
    }
    // 升级函数，改变逻辑合约地址，只能由admin调用。选择器：0x0900f010
    // UUPS中，逻辑合约中必须包含升级函数，不然就不能再升级了。
    function upgrade(address newimplementation)external {
        require(msg.sender == admin);
        implementation = newimplementation;
    }
}