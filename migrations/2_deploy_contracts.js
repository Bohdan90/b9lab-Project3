var RockPaperScissors = artifacts.require("./RockPaperScissors.sol");

module.exports = function(deployer) {
  deployer.deploy(RockPaperScissors,'0x14723a09acff6d2a60dcdf7aa4aff308fddc160c','0xca35b7d915458ef540ade6068dfe2f44e8fa733c');
};
