pragma solidity ^0.4.18;

contract Donations {

    address public owner; // Contract creator's address
    uint public fundingGoal = 1; // Funding goal value
    uint public durationInMinutes = 1; // Duration for each donation
    //uint public amountRaised = 0; // Amount currently raised
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
		fundingGoal = fundingGoal * 1 ether;
		deadline = now + (durationInMinutes * 1 minutes);
	}
    
    /*
    *   Donate to organization
    */
	function sendDonation(address _to, uint _amount) public payable returns(bool success) {
	    require(!donationClosed);
		if (balanceOf[msg.sender] < _amount) {
            return false;
        }
		balanceOf[msg.sender] -= _amount;
		//amountRaised += _amount;
        _to.transfer(_amount);
		Donate(msg.sender, _to, _amount);
		return true;
	}
	
	/*
	*   Check if goal is reached. Can only check after deadline = true
	*/
	function checkGoalReached() public returns(bool) {
	    if(getBalance() >= fundingGoal || now >= deadline) {
	        fundingGoalReached = true;
	        donationClosed = true;
	        transferDonation(owner, getBalance());
	        SendRaisedDonation(owner, getBalance());
	        return true;
	    }
	    return false;
	}
	
	function transferDonation(address _to, uint _amount) public {
	    _to.transfer(_amount);
	}
    
    /*
    *   Check contract's balance
    */
    function getBalance() public view returns(uint) {
		return this.balance;
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