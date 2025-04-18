// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MCERC20 is ERC20{
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_){
        _mint(msg.sender, 100 ether);
    }

      function abc(uint t1, uint t2, uint t3)public pure returns (uint res){
        res = t1*t3 / (t1+t2);
    }

}