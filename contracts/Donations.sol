pragma solidity ^0.4.18;

/*
*   Author:         Dziugas Butkus
*   Description:    Lets users donate to charities. Funds are transfered directly to charity's address.
*                   Owner creates donation events, duration and goals in ether.
*/

contract Donations {

    address public owner; // Contract owner's address
    address public organizationAddress; // Organization's address
    uint public donationGoal; // Amount of ether to raise
    uint public durationInMinutes; // Length of donation event
    uint public deadline; // Deadline of donation event
    uint public raisedAmount; // Amount of ether raised
    
    enum State { Active, Inactive}
    State state;
    
    mapping (address => uint) balanceOf;
    
    event StartDonationEvent(address organizationAddress, uint donationGoal, uint durationInMinutes);
    event DonateEvent(address donator, address organizationAddress, uint amountDonated);
    event CancelDonationEvent(address organizationAddress, uint raisedAmount);
    event FromContractToOwnerEvent(address owner, uint contractsBalance);
    
    // Allow access to owner only
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    // Constructor, called only once
    function Donations() public {
        owner = msg.sender;
    }
    
    // Prevent random funds from being sent to contract
    function () public payable {
        revert();
    }
    
    /*
    *   startDonation()
    *   change donation address, donation goal, and donation duration only after no other event is happening
    */
    function startDonation(address _organizationAddress, uint _donationGoal, uint _durationInMinutes) public onlyOwner {
        require(state == State.Inactive); // Donation event must have ended
        organizationAddress = _organizationAddress; // Set organization's address
        donationGoal = (_donationGoal * 1 ether); // Set donation's goal
        durationInMinutes = _durationInMinutes;
        deadline = now + (durationInMinutes * 1 minutes); // Set donation's deadline
        state = State.Active;
        
        StartDonationEvent(organizationAddress, donationGoal, durationInMinutes);
    }
    
    /*
    *   sendDonation()
    *   send donation directly to organization's address
    */
    function sendDonation() public payable returns(bool success) {
        //require(msg.sender != owner);
        require(state == State.Active);
        require(msg.value > 0);
        uint amount = msg.value;
        if (balanceOf[msg.sender] <= amount) {
            organizationAddress.transfer(amount);
            raisedAmount += amount;
    		DonateEvent(msg.sender, organizationAddress, amount);
    		return true;
		}
		return false;
    }
    
    /*
    *   checkDonationEnded()
    *   check if donation event has ended 
    *   allow access only during active event, as there is no need to check status when it is ended
    */
    function checkDonationEnded() public {
        require(state == State.Active); // Donation even must be active
        if(now >= deadline) {
            state = State.Inactive;   
            raisedAmount = 0;
        }
    }
    
    /*
    *   cancelDonation()
    *   Let owner cancel donation event. Useful if there is a typo in organization address, duration.
    *   When users donate, funds are automatically transfered to organization address, so owner can't
    *   steal.
    */
    function cancelDonation() public onlyOwner {
        require(state == State.Active);
        deadline += durationInMinutes;
        state = State.Inactive;
        CancelDonationEvent(organizationAddress, raisedAmount);
        raisedAmount = 0;
    }

    /*
    *   fromContractToOwner()
    *   If for some reason ether is sent to contract's address, owner can gete the funds back.
    *   Future plans: keep track of transactions and send back if they end up in contract's address
    *   to prevent owner from stealing.
    */
    function fromContractToOwner() public onlyOwner {
        uint contractsBalance = this.balance;
        owner.transfer(contractsBalance);
        FromContractToOwnerEvent(owner, contractsBalance);
    }

    /*
    *   getRaisedAmount()
    *   Return amount of ether raised during current event, to keep track of statistics
    *   ***SHOULD USE ALREADY EXISTING EVENTS INSTEAD OF THIS FUNCTION TO SAVE GAS***
    */
    function getRaisedAmount() public onlyOwner returns(uint) {
        require(state == State.Active);
        return raisedAmount;
    }

    /*
    *   kill()
    *   delete this smart contract from blockchain
    */
    function kill() public onlyOwner {
        if (msg.sender == owner) {
            selfdestruct(owner);
        }
    }
    
}
