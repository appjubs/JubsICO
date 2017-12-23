var JUBSIco = artifacts.require("./JubsICO.sol");

contract('JubsICO', function(accounts) {  
  it("should put 10000 JubsICO in the first account", function() {
    return JubsICO.deployed().then(function(instance) {
      return instance.getBalance.call(accounts[0]);
    }).then(function(balance) {    
      buy.equal(balance.valueOf(), 10000, "10000 wasn't in the first account");
    });
  });  
});
