// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MYERC20 is ERC20{
    constructor(string memory _name,string memory _symbol) ERC20(_name, _symbol){
        // 设置初始化金额
        _mint(msg.sender, 10000*10**18);
    }


     // 存入ERC20代币
    function depositToken(address tokenAddress, address user,  uint256 amount) public {
        require(amount > 0, "Deposit amount must be greater than 0");
        
        IERC20 token = IERC20(tokenAddress);
        require(token.transferFrom(user, address(this), amount), "Transfer failed");
        
    }
}