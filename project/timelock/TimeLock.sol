// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
import "hardhat/console.sol";

contract TimeLock {

        // 事件
    // 交易取消事件
    event CancelTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature,  bytes data, uint executeTime);
    // 交易执行事件
    event ExecuteTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature,  bytes data, uint executeTime);
    // 交易创建并进入队列 事件
    event QueueTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data, uint executeTime);
    // 修改管理员地址的事件
    event NewAdmin(address indexed newAdmin);

    
    address public admin;// 管理员地址
    uint256 public constant GRACE_PERIOD = 7 days ;// 交易有效期
    uint256 public delay;// 交易锁定时间
    mapping (bytes32 => bool) public queuedTransactions; // txHash到bool，记录所有在时间锁队列中的交易

    constructor(uint256 delay_){
        delay = delay_;
        admin = msg.sender;
    }

    modifier onlyOwner(){
        require (admin == msg.sender, "only owner"); // 只有管理员才能发送交易
        _;// 调用下一个修饰器
    }

    modifier onlyTimeLock(){
        require(msg.sender==address(this), "Timelock: Caller not Timelock");
        _;
    }

    function changeAdmin(address newAdmin)public onlyTimeLock{
        admin = newAdmin;
        
        emit NewAdmin(newAdmin);
    }
    //0x000000000000000000000000Ab8483F64d9C6d1EcF9b849Ae677dD3315835cb2

  

    function getHash(address target,uint value, string memory signature, bytes memory data, uint256 executeTime)public pure returns (bytes32){
        return keccak256(abi.encodePacked(target,value,signature,data,executeTime));
    }


    /**
     * @dev 创建交易并添加到时间锁队列中。
     * @param target: 目标合约地址
     * @param value: 发送eth数额
     * @param signature: 要调用的函数签名（function signature）
     * @param data: call data，里面是一些参数
     * @param executeTime: 交易执行的区块链时间戳
     *
     * 要求：executeTime 大于 当前区块链时间戳+delay
     */
    function queueTransaction(address target, uint256 value, string memory signature, bytes memory data, uint256 executeTime) public onlyOwner returns (bytes32) {
        // 检查：交易执行时间满足锁定时间
        require(executeTime >= getBlockTimestamp() + delay, "Timelock::queueTransaction: Estimated execution block must satisfy delay.");
        // 计算交易的唯一识别符：一堆东西的hash
        bytes32 txHash = getTxHash(target, value, signature, data, executeTime);
        // 将交易添加到队列
        queuedTransactions[txHash] = true;

        emit QueueTransaction(txHash, target, value, signature, data, executeTime);
        return txHash;
    }

    /**
     * @dev 取消特定交易。
     *
     * 要求：交易在时间锁队列中
     */
    function cancelTransaction(address target, uint256 value, string memory signature, bytes memory data, uint256 executeTime) public onlyOwner{
        // 计算交易的唯一识别符：一堆东西的hash
        bytes32 txHash = getTxHash(target, value, signature, data, executeTime);
        // 检查：交易在时间锁队列中
        require(queuedTransactions[txHash], "Timelock::cancelTransaction: Transaction hasn't been queued.");
        // 将交易移出队列
        queuedTransactions[txHash] = false;

        emit CancelTransaction(txHash, target, value, signature, data, executeTime);
    }

    /**
     * @dev 执行特定交易。
     *
     * 要求：
     * 1. 交易在时间锁队列中
     * 2. 达到交易的执行时间
     * 3. 交易没过期
     */
    function executeTransaction(address target, uint256 value, string memory signature, bytes memory data, uint256 executeTime) public payable onlyOwner returns (bytes memory) {
        bytes32 txHash = getTxHash(target, value, signature, data, executeTime);
        // 检查：交易是否在时间锁队列中
        require(queuedTransactions[txHash], "Timelock::executeTransaction: Transaction hasn't been queued.");
        // 检查：达到交易的执行时间
        require(getBlockTimestamp() >= executeTime, "Timelock::executeTransaction: Transaction hasn't surpassed time lock.");
        // 检查：交易没过期
       require(getBlockTimestamp() <= executeTime + GRACE_PERIOD, "Timelock::executeTransaction: Transaction is stale.");
        // 将交易移出队列
        queuedTransactions[txHash] = false;
        console.log(target);
        console.log(value);
        console.log(signature);
        
        console.log(executeTime);
        // 获取call data
        bytes memory callData;
        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }
        // 利用call执行交易
        (bool success, bytes memory returnData) = target.call{value: value}(callData);
        require(success, "Timelock::executeTransaction: Transaction execution reverted.");

        emit ExecuteTransaction(txHash, target, value, signature, data, executeTime);

        return returnData;
    }

    function callData(string memory signature, bytes memory data) public  pure returns(bytes memory returnData){
         
        returnData =  abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
    }

    function targetcall(address target, uint value, bytes memory callData)public {
         (bool success, bytes memory returnData) = target.call{value: value}(callData);
        require(success, "Timelock::executeTransaction: Transaction execution reverted.");
    }

    /**
     * @dev 获取当前区块链时间戳
     */
    function getBlockTimestamp() public view returns (uint) {
        return block.timestamp;
    }

    /**
     * @dev 将一堆东西拼成交易的标识符
     */
    function getTxHash(
        address target,
        uint value,
        string memory signature,
        bytes memory data,
        uint executeTime
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(target, value, signature, data, executeTime));
    }

    function abiEncode(address add) public pure returns (bytes memory res){
        res = abi.encode(add);
    }

}