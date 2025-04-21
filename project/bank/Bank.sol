// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenBank {
    // 存储每个地址的代币余额
    mapping(address => mapping(address => uint256)) private tokenBalances;
    
    // 存款事件
    event Deposit(address indexed account, address indexed token, uint256 amount);
    
    // 取款事件
    event Withdrawal(address indexed account, address indexed token, uint256 amount);
    
    // 存入ERC20代币
    function depositToken(address tokenAddress, address user,  uint256 amount) public {
        require(amount > 0, "Deposit amount must be greater than 0");
        
        IERC20 token = IERC20(tokenAddress);
        require(token.transferFrom(user, address(this), amount), "Transfer failed");
        
        tokenBalances[user][tokenAddress] += amount;
        emit Deposit(user, tokenAddress, amount);
    }
    
    // 取出ERC20代币
    function withdrawToken(address tokenAddress, address user, uint256 amount) public {
        require(amount > 0, "Withdrawal amount must be greater than 0");
        require(tokenBalances[user][tokenAddress] >= amount, "Insufficient balance");
        
        tokenBalances[user][tokenAddress] -= amount;
        IERC20(tokenAddress).transfer(user, amount);
        emit Withdrawal(user, tokenAddress, amount);
    }
    
    // 查询特定代币余额
    function getTokenBalance(address tokenAddress) public view returns (uint256) {
        return tokenBalances[msg.sender][tokenAddress];
    }
    
    // 保留原生代币(ETH)存款功能
    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        tokenBalances[msg.sender][address(0)] += msg.value;
        emit Deposit(msg.sender, address(0), msg.value);
    }
    
    // 保留原生代币(ETH)取款功能
    function withdraw(uint256 amount) public {
        require(amount > 0, "Withdrawal amount must be greater than 0");
        require(tokenBalances[msg.sender][address(0)] >= amount, "Insufficient balance");
        
        tokenBalances[msg.sender][address(0)] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, address(0), amount);
    }
    
    // 查询原生代币(ETH)余额
    function getBalance() public view returns (uint256) {
        return tokenBalances[msg.sender][address(0)];
    }
}