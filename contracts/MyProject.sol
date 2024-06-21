// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

//import "hardhat/console.sol";

contract MyProject {
    address payable public owner;
    uint256 public balance;

    event Deposit(uint256 amount);
    event Withdraw(uint256 amount);
    event InterestAdded(uint256 interestAmount);
    event ServiceChargeDeducted(uint256 serviceChargeAmount);

    constructor(uint initBalance) payable {
        owner = payable(msg.sender);
        balance = initBalance;
    }

    function getBalance() public view returns(uint256) {
        return balance;
    }

    function deposit(uint256 _amount) public payable {
        uint _previousBalance = balance;

        // make sure this is the owner
        require(msg.sender == owner, "You are not the owner of this account");

        // perform transaction
        balance += _amount;

        // assert transaction completed successfully
        assert(balance == _previousBalance + _amount);

        // emit the event
        emit Deposit(_amount);
    }

    // custom error
    error InsufficientBalance(uint256 balance, uint256 withdrawAmount);

    function withdraw(uint256 _withdrawAmount) public {
        require(msg.sender == owner, "You are not the owner of this account");
        uint _previousBalance = balance;
        if (balance < _withdrawAmount) {
            revert InsufficientBalance({
                balance: balance,
                withdrawAmount: _withdrawAmount
            });
        }

        // withdraw the given amount
        balance -= _withdrawAmount;
        payable(msg.sender).transfer(_withdrawAmount);

        // assert the balance is correct
        assert(balance == (_previousBalance - _withdrawAmount));

        // emit the event
        emit Withdraw(_withdrawAmount);
    }

    function addInterest(uint256 interestRate) public {
        require(msg.sender == owner, "You are not the owner of this account");
        uint _previousBalance = balance;
        // Calculate interest based on the interest rate
        uint256 interestAmount = (balance * interestRate) / 100; // Interest rate is in basis points

        // Add interest to the balance
        balance += interestAmount;

         // assert transaction completed successfully
        assert(balance == _previousBalance + interestAmount);

        // Emit the event
        emit InterestAdded(interestAmount);
    }

    function deductServiceCharge(uint256 serviceCharge) public {
        require(msg.sender == owner, "You are not the owner of this account");
        uint _previousBalance = balance;
        // Make sure there are sufficient funds for the service charge
        if (balance < serviceCharge) {
            revert InsufficientBalance({
                balance: balance,
                withdrawAmount: serviceCharge
            });
        }

        // Deduct service charge from the balance
        balance -= serviceCharge;
        
        // assert the balance is correct
        assert(balance == (_previousBalance - serviceCharge));
        // Emit the event
        emit ServiceChargeDeducted(serviceCharge);
    }

    // Fallback function is executed when the contract is called with data that does not match any function
    fallback() external payable {
        balance += msg.value;
        emit Deposit(msg.value);
    }

    // Receive function is executed when the contract is called without any data
    receive() external payable {
        balance += msg.value;
        emit Deposit(msg.value);
    }
}
