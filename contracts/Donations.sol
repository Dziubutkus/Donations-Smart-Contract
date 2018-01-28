pragma solidity ^0.4.18;

import "./ConvertLib.sol";

/*
*   Author:         Dziugas Butkus
*   Description:    DAPP that lets contract's owner to create donation events. Everyone can donate ether to one pool until deadline.
*                   After deadline, raised funds are transfered to organization and contract's owner has to create a new donation event.
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
    
    // Allow access to owner only
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    // Constructor, called only once
    function Donations() public {
        owner = msg.sender;
        organizationAddress = this;
        state = State.Inactive;
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
        require(msg.sender != owner);
        require(state == State.Active);
        require(msg.value > 0);
        if (balanceOf[msg.sender] <= msg.value) {
    		balanceOf[msg.sender] -= msg.value;
            organizationAddress.transfer(msg.value);
            raisedAmount += msg.value;
    		DonateEvent(msg.sender, organizationAddress, msg.value);
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
        if(now >= deadline)
        {
            state = State.Inactive;   
            raisedAmount = 0;
        }
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