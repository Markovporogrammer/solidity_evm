// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
import "../erc20/IERC20.sol";
// 步骤是先部署一个ERC20代币，在部署这个代币锁，需要参数 ERC20代币地址，受益人，锁的时间，
// 拿到代币锁合约地址去ERC20代币transfer方法转账给这个代币锁多少钱,
// 然后可以调用release方法参数ERC20合约地址，和释放金额
contract LPLock{

    /*
    TokenLockStart：锁仓开始事件，在合约部署时释放，记录受益人地址，代币地址，锁仓起始时间，和结束时间。
    Release：代币释放事件，在受益人取出代币时释放，记录记录受益人地址，代币地址，释放代币时间，和代币数量
    */
    event TokenLockStart(address indexed beneficiary, address indexed token, uint256 lockStarttime, uint256 endTime);
    event Release(address indexed beneficiary, address indexed token, uint256 releasetime, uint256 amount);

    address public immutable beneficiary;// 受益人地址
    IERC20 public immutable token;// 锁仓ERC代币地址
    uint256 public immutable lockTime;// 锁多长时间
    uint256 public immutable startTime;// 开始锁仓时间

    constructor(IERC20  _token, address _beneficiary, uint256 _lockTime) {
        beneficiary = _beneficiary;
        token = _token;
        lockTime = _lockTime;
        startTime = block.timestamp;
        emit TokenLockStart(_beneficiary, address(_token), block.timestamp, _lockTime+block.timestamp);
    }

    // 释放 受益人代币 代币所在ERC20，和释放多少钱
    function release(IERC20 _token, uint256 _amount)public {
        require(block.timestamp>=startTime+lockTime,unicode"释放时间未到");

        uint256 amount = _token.balanceOf(address(this));
        require(amount>0, unicode"代币锁合约里已经没钱了");
        require(amount>=_amount, unicode"代币锁合约释放的钱不足");

        _token.transfer( beneficiary, _amount);

        emit Release(beneficiary, address(_token), block.timestamp, _amount);
    }




}