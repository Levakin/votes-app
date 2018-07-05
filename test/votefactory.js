var VoteFactory = artifacts.require("VoteFactory");

contract('VoteFactory', accounts => {
    it("should create new Vote", () => {
        VoteFactory.deployed().then(instance => {
            instance.createVote.call("Test vote");
        }).then(()=>{
            assert.equal()
        })
    })
});