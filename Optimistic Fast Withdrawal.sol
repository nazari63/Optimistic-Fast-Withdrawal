// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ILiquidityProvider {
    function provideLiquidity(address user, uint256 amount) external;
}

contract OptimisticFastWithdrawal {
    address public admin;
    ILiquidityProvider public liquidityProvider;
    mapping(address => uint256) public pendingWithdrawals;

    event WithdrawalRequested(address indexed user, uint256 amount);
    event WithdrawalCompleted(address indexed user, uint256 amount);

    constructor(address _liquidityProvider) {
        admin = msg.sender;
        liquidityProvider = ILiquidityProvider(_liquidityProvider);
    }

    function requestWithdrawal(uint256 amount) external {
        pendingWithdrawals[msg.sender] += amount;
        liquidityProvider.provideLiquidity(msg.sender, amount);
        emit WithdrawalRequested(msg.sender, amount);
    }

    function completeWithdrawal(address user, uint256 amount) external {
        require(msg.sender == admin, "Only admin can complete withdrawals");
        require(pendingWithdrawals[user] >= amount, "Insufficient pending balance");
        pendingWithdrawals[user] -= amount;
        emit WithdrawalCompleted(user, amount);
    }
}