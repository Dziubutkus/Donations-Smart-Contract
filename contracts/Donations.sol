pragma solidity ^0.4.18;

import "./ConvertLib.sol";

/*
*   Author:         Dziugas Butkus
*   Description:    DAPP that lets contract's owner to create donation events. Everyone can donate ether to one pool until deadline.
*                   After deadline, raised funds are transfered to organization and contract's owner has to create a new donation event.
*/

contract Donations {

    address public owner; // Contract creator's address
    address public contractsAddress; // Contract's address
    address public organizationAddress; // Address to donate to
    uint public fundingGoal = 1; // Funding goal value
    uint public durationInMinutes = 1; // Duration for each donation
    uint public deadline; // Donation stops at deadline
    bool public donationClosed = true;
    bool public fundingGoalReached = true;
    
    mapping (address => uint) balanceOf;

    event SendRaisedDonation(address donationTo, uint totalAmountRaised);
    event Donate(address sender, address receiver, uint256 amountDonated);
    event ChangeDonation(address beneficiary, uint fundingGoal, uint durationInMinutes);
    
    /** 
    *   Things to pay attention to:
    *   Add states
    *   Fix modifiers
    *   Fix security (require(), ifs())
    */

    // Give access to functions after deadline
    modifier afterDeadline {
        if (now >= deadline) {
            _;
        }
    }

    // Give access to functions during the donation event
    modifier duringDeadline {
        if (now < deadline) {
            _;
        }
    }
    // Make functions only accessable by the contract's owner
    modifier onlyOwner { 
        require(msg.sender == owner);  
        _; 
    }
    
    /*
    *   Default constructor
    */
    function Donations() public {
		owner = msg.sender;
		contractsAddress = this;
		//fundingGoal = fundingGoal * 1 ether;
		//deadline = now + (durationInMinutes * 1 minutes);
	}
    
    /*
    *   Create a donation event.
    *   @params: 
    *   _organization       - organization's address
    *   _fundingGoal        - set the intended amount of ether to raise
    *   _durationInMinutes  - the duration of donation event in minutes
    */
    function changeDonation(address _organization, uint _fundingGoal, uint _durationInMinutes) onlyOwner afterDeadline public {
        // Security
        require(msg.sender == owner);
        require(donationClosed == true);
        require(fundingGoalReached == true);
        // Set variables
        organizationAddress = _organization;
        fundingGoal = _fundingGoal * 1 ether;
        durationInMinutes = _durationInMinutes;
        // Set deadline
        deadline = now + (durationInMinutes * 1 minutes);
        // Set booleans
        donationClosed = false;
        fundingGoalReached = false;
    }

    /*
    *   Send donation to the pool
    *   @params:
    *   _amount - amount of ether to donate
    */
	function sendDonation(uint _amount) public payable beforeDeadline returns(bool success) {
	    require(!donationClosed);
        require(_amount > 0);
		if (balanceOf[msg.sender] < _amount) {
    		balanceOf[msg.sender] -= _amount;
            contractsAddress.transfer(_amount);
    		Donate(msg.sender, owner, _amount);
    		return true;
		}
		return false;
	}
	
	/*
	*   Check if goal is reached. Can only check after deadline = true
    *   If goal is reached, call transferDonation() to send raised ether to organization
	*/
	function checkGoalReached() public payable afterDeadline returns(bool) {
	    if (getBalance() >= fundingGoal || now >= deadline) {
            // Stop donation proccess
	        fundingGoalReached = true;
	        donationClosed = true;
            // Transfer raised ether to organization
	        transferDonation(getBalance());
	        SendRaisedDonation(contractsAddress, getBalance());
	        return true;
	    }
	    return false;
	}
	
    /*
    *   Transfer raised donation to organization after deadline
    *   @params:
    *   _amount - amount of ether to send to organization. (_amount comes from getBalance())
    */
	function transferDonation(uint _amount) public payable afterDeadline {
	    owner.transfer(_amount);
	}
    
    /*
    *   Get contract's balance in wei
    */
    function getBalance() public view returns(uint) {
		return contractsAddress.balance;
	}

    /*
    *   Get contract's balance in ether with 2 decimal points
    */
    function getBalanceInEth() public view returns(uint) {
		return ConvertLib.convert(getBalance(), 2);
	}

    /*
    *   Delete this smart contract from blockchain
    */
    function kill() public onlyOwner {
        if (msg.sender == owner) {
            selfdestruct(owner);
        }
    }
}