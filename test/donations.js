var Donations = artifacts.require("Donations");

contract('Donations', function(balances) {
    it("Should run", function() {
        return Donations.deployed().then(function(instance) {
            return instance.getBalance.call(accounts[0]);
        });
    });
});