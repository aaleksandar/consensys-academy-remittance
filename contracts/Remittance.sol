pragma solidity ^0.4.14;

import './Destructible.sol';

contract Remittance is Destructible {

	struct PendingTransaction {
    address sender;
    uint deadline;
    uint value;
  }

  event LogDeposit(address sender, uint value, uint deadline, bytes32 hash);
  event LogWithdraw(address sender, uint value, bytes32 hash);
  event LogRefund(address sender, uint value, bytes32 hash);
  event LogSender(address sender);

	mapping (bytes32 => PendingTransaction) public pendingTransactions;

	function deposit(address receiver, uint deadline, bytes32 emailPass, bytes32 smsPass) payable returns(bool success) {
		require(deadline  > 0);
		require(msg.value > 0);
		require(msg.sender != receiver);
		LogSender(receiver);

		bytes32 hash = keccak256(receiver, emailPass, smsPass);
		PendingTransaction storage pendingTransaction = pendingTransactions[hash];
		require(pendingTransaction.deadline == 0);

		pendingTransaction.sender = msg.sender;
		pendingTransaction.deadline = block.number + deadline;
		pendingTransaction.value = msg.value;

		pendingTransactions[hash] = pendingTransaction;

		LogDeposit(msg.sender, msg.value, deadline, hash);
		return true;
	}

	function withdraw(bytes32 emailPass, bytes32 smsPass) returns(bool success) {
		LogSender(msg.sender);
		bytes32	hash = keccak256(msg.sender, emailPass, smsPass);
		PendingTransaction storage pendingTransaction = pendingTransactions[hash];

		require(pendingTransaction.deadline >= block.number);

		uint value = pendingTransaction.value;
		msg.sender.transfer(value);

		delete pendingTransactions[hash];

		LogWithdraw(msg.sender, value, hash);
		return true;
	}

	function refund(bytes32 emailPass, bytes32 smsPass) returns(bool success) {
		bytes32	hash = keccak256(msg.sender, emailPass, smsPass);
		PendingTransaction storage pendingTransaction = pendingTransactions[hash];

		require(pendingTransaction.deadline < block.number);
		require(pendingTransaction.sender == msg.sender);

		uint value = pendingTransaction.value;
		msg.sender.transfer(value);

		delete pendingTransactions[hash];

		LogRefund(msg.sender, value, hash);
		return true;
	}
}
