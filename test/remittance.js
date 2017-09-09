var Remittance = artifacts.require("./Remittance.sol");

contract('Remittance', function(accounts) {
  var contract;

  const alice = accounts[0];
  const bob   = accounts[1];
  const carol = accounts[2];

  const emailPass = '0x1111'
  const smsPass   = '0x2222'


  beforeEach(function() {
    return Remittance.new({from: alice})
      .then(function(instance){
        contract = instance;
      });
  });


  it("should allow to deposit money", function() {
    var aliceBefore = web3.eth.getBalance(alice);

    return contract.deposit(carol, 1000, emailPass, smsPass, { from: alice, value: 100 })
      .then(function(tx) {
        assert.isOk(tx, 'Deposit failed!');
      });
  });

  it("should allow to withdraw money", function() {
    var aliceBefore = web3.eth.getBalance(alice);
    var carolBefore = web3.eth.getBalance(carol);

    return contract.withdraw(emailPass, smsPass, { from: carol })
      .then(function(tx) {
        assert.isOk(tx, 'Withdraw failed!');
      });
  });

  it("should transfer money", function() {
    const gasPrice = 10;

    var aliceBefore = web3.eth.getBalance(alice);
    var carolBefore = web3.eth.getBalance(carol);

    return contract.deposit(carol, 1000, emailPass, smsPass, { from: alice, value: 100 })
      .then(function(tx) {
        return contract.withdraw(emailPass, smsPass, { from: carol, gasPrice: gasPrice })
      }).then(function(tx) {
        weiUsed = tx.receipt.gasUsed * gasPrice;

        var aliceAfter = web3.eth.getBalance(alice);
        var carolAfter = web3.eth.getBalance(carol);

        assert.equal(aliceBefore.toNumber(), aliceAfter.plus(100).toNumber());
        assert.equal(carolBefore.minus(weiUsed).plus(100).toNumber(), carolAfter.toNumber());
      });
  });

});
