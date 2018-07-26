var VoteFactory = artifacts.require('VoteFactory')

module.exports = deployer => {
  deployer.deploy(VoteFactory)
}
