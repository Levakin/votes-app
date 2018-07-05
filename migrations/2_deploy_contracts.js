var VoteFactory = artifacts.require("VoteFactory");
// var VoteHelper = artifacts.require("VoteHelper");
var Ownable = artifacts.require("Ownable");


module.exports = deployer => {
    deployer.deploy(Ownable);
    deployer.link(Ownable, VoteFactory);
    deployer.deploy(VoteFactory);
    // deployer.link(VoteFactory, VoteHelper);
    // deployer.deploy(VoteHelper);
};