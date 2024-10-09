pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract SepoliaFaucet is ReentrancyGuard {
    using ECDSA for bytes32;

    address public owner;
    uint256 public dailyLimit;
    uint256 public totalLimit;
    bool public faucetActive = true;
        
    mapping(address => uint256) public totalWithdrawn;
    mapping(address => uint256) public lastWithdrawTime;
    uint256 public withdrawFrequency;
    mapping(address => bool) public whitelist;

    // Events for logging actions in the contract
    event WhitelistUpdated(address indexed _address, bool _status);
    event Withdrawal(address indexed _user, uint256 _amount);
    event WithdrawAll(address indexed _relayer, uint256 _balance);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event FaucetStatusUpdated(bool active);

    // Modifier to restrict access to the owner only
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    // Modifier to restrict access to whitelisted addresses only
    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], "Address not whitelisted");
        _;
    }

    // Modifier to check if the faucet is active
    modifier faucetIsActive() {
        require(faucetActive, "Faucet is currently inactive");
        _;
    }

    // Constructor to set the contract deployer as the owner
    constructor() payable {
        dailyLimit = 0.1 ether;
        totalLimit = 1 ether;
        withdrawFrequency = 24 hours;
        owner = msg.sender;
        whitelist[owner] = true;
        emit WhitelistUpdated(owner, true);
    }

    // Function to add an address to the whitelist, only callable by the owner
    function addToWhitelist(address _address) external onlyOwner {
        whitelist[_address] = true;
        emit WhitelistUpdated(_address, true);
    }

    // Function to remove an address from the whitelist, only callable by the owner
    function removeFromWhitelist(address _address) external onlyOwner {
        whitelist[_address] = false;
        emit WhitelistUpdated(_address, false);
    }

    // Function to deposit ETH into the contract, only callable by the owner
    function deposit() external payable onlyOwner {}

    // Function to allow a third party (relayer) to request withdrawal on behalf of a user
    function requestWithdraw(address _user, uint256 _amount) external onlyWhitelisted nonReentrant faucetIsActive {
        require(_amount <= dailyLimit, "Exceeds daily withdrawal limit");
        require(totalWithdrawn[_user] + _amount <= totalLimit, "Exceeds total withdrawal limit");
        require(block.timestamp - lastWithdrawTime[_user] >= withdrawFrequency, "Withdrawal only allowed based on frequency limit");
        require(address(this).balance >= _amount, "Not enough balance to cover requested amount");

        totalWithdrawn[_user] += _amount;
        lastWithdrawTime[_user] = block.timestamp;

        // Transfer ETH to the user
        (bool success, ) = _user.call{value: _amount}("");
        require(success, "Transfer failed");

        emit Withdrawal(_user, _amount);
    }

    // Function to allow whitelisted addresses to withdraw the entire balance of the faucet
    function withdrawAll() external onlyWhitelisted nonReentrant faucetIsActive {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds available");

        // Transfer entire balance to the contract owner
        (bool success, ) = owner.call{value: balance}("");
        require(success, "Withdraw failed");

        emit WithdrawAll(msg.sender, balance);
    }

    // Function to transfer ownership of the contract to a new owner
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    // Function to update daily limit, only callable by the owner
    function updateDailyLimit(uint256 _newLimit) external onlyOwner {
        dailyLimit = _newLimit;
    }

    // Function to update total limit, only callable by the owner
    function updateTotalLimit(uint256 _newLimit) external onlyOwner {
        totalLimit = _newLimit;
    }

    // Function to update withdraw frequency, only callable by the owner
    function updateWithdrawFrequency(uint256 _newFrequency) external onlyOwner {
        withdrawFrequency = _newFrequency;
    }

    // Function to activate or deactivate the faucet, only callable by the owner
    function toggleFaucetStatus() external onlyOwner {
        faucetActive = !faucetActive;
        emit FaucetStatusUpdated(faucetActive);
    }

    // Function to get the current balance of the contract
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // Fallback function to receive ETH directly
    receive() external payable {}
}
