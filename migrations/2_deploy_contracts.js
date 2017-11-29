var TempusToken = artifacts.require("./TempusToken.sol");

module.exports = function(deployer) {
  deployer.deploy(TempusToken);
};
