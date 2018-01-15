var Donations = artifacts.require("Donations");

contract('Donations', function() {
    it("Should work", function() {
        return Donations.deployed().then(function(instance) {
            var donation = instance;
            return donation.getBalance();
        });
    });
});