pragma solidity ^0.4.18;

contract Donations {

    address public owner; // Contract creator's address
    address public contractsAddress; // Contract's address
    uint public fundingGoal = 1; // Funding goal value
    uint public durationInMinutes = 1; // Duration for each donation
    uint public deadline; // Donation stops at deadline
    bool public donationClosed = false;
    bool public fundingGoalReached = false;
    
    mapping (address => uint) balanceOf;

    event SendRaisedDonation(address donationTo, uint totalAmountRaised);
    event Donate(address sender, address receiver, uint256 amountDonated);
    
    /*
    *   Give access to functions after deadline
    */
    modifier afterDeadLine {
        if (now >= deadline) {
            _;
        }
    }
    
    /*
    *   Default constructor
    */
    function Donations() public {
		owner = msg.sender;
		contractsAddress = this;
		fundingGoal = fundingGoal * 1 ether;
		deadline = now + (durationInMinutes * 1 minutes);
	}
    
    /*
    *   Donate to organization
    */
	function sendDonation(uint _amount) public payable returns(bool success) {
	    require(!donationClosed);
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
	*/
	function checkGoalReached() public payable returns(bool) {
	    if (getBalance() >= fundingGoal || now >= deadline) {
	        fundingGoalReached = true;
	        donationClosed = true;
	        transferDonation(getBalance());
	        SendRaisedDonation(contractsAddress, getBalance());
	        return true;
	    }
	    return false;
	}
	
	function transferDonation(uint _amount) public payable {
	    owner.transfer(_amount);
	}
    
    /*
    *   Check contract's balance
    */
    function getBalance() public view returns(uint) {
		return contractsAddress.balance;
	}


    /*
    *   Delete this smart contract from blockchain
    */
    function kill() public {
        if (msg.sender == owner) {

            selfdestruct(owner);
        }
    }
}