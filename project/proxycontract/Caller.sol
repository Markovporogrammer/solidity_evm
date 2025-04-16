// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract Caller{
    address public proxy;
    constructor(address _proxy) payable {
        proxy = _proxy;
    }

    function increment()external returns (uint256){
       (bool succ, bytes memory data) = proxy.call(abi.encodeWithSignature("increment()"));
       require(succ, "call Logic increment error");
       return abi.decode(data, (uint256));
    }
}