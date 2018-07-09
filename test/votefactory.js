var VoteFactory = artifacts.require("VoteFactory");

contract('VoteFactory', async (accounts) => {

    it("should create new vote correctly", async () => {
        let instance = await VoteFactory.deployed();

        let question = "vote's question";

        await instance.createVote(question);
    });

    it("should create two votes and get second question", async() => {
        let instance = await VoteFactory.deployed();

        let expectedQuestion = "vote's question";

        await instance.createVote("first");

        let voteId = (await instance.createVote.call(expectedQuestion)).toNumber();
        await instance.createVote(expectedQuestion);

        let createdQuestion = await instance.getQuestion.call(voteId);

        assert.equal(expectedQuestion, createdQuestion, "Vote wasn't created successfully");
    });

    it("should create two votes and change second question", async() => {
        let instance = await VoteFactory.deployed();
        let initialQuestion = "vote's question";
        let expectedQuestion = "changed question";

        await instance.createVote("first");

        let voteId = (await instance.createVote.call(initialQuestion)).toNumber();
        await instance.createVote(initialQuestion);

        await instance.changeVote(voteId, expectedQuestion);        
        let changedQuestion = await instance.getQuestion.call(voteId);

        assert.equal(expectedQuestion, changedQuestion, "Vote wasn't changed successfully");
    });

    it("should create vote, add two answers and get correct second answer", async() => {
        let instance = await VoteFactory.deployed();
        
        let question = "vote's question";
        let firstAnswer = "first";
        let secondAnswer = "second";

        let voteId = (await instance.createVote.call(question)).toNumber();
        await instance.createVote(question);

        await instance.addAnswer(voteId, firstAnswer);
        
        let answerId = (await instance.addAnswer.call(voteId, firstAnswer)).toNumber();
        await instance.addAnswer(voteId, secondAnswer);
        let answer = await instance.getAnswer(voteId, answerId);

        assert.equal(answer, secondAnswer, "Answer wasn't added successfully");
    });

    it("should create vote, add two answers and change second answer", async() => {
        let instance = await VoteFactory.deployed();
        
        let question = "vote's question";
        let firstAnswer = "first";
        let secondAnswer = "second";
        let changedAnswer = "changed";

        let voteId = (await instance.createVote.call(question)).toNumber();
        await instance.createVote(question);

        await instance.addAnswer(voteId, firstAnswer);

        let answerId = (await instance.addAnswer.call(voteId, firstAnswer)).toNumber();
        await instance.addAnswer(voteId, secondAnswer);

        await instance.changeAnswer(voteId, answerId, changedAnswer);
        let answer = await instance.getAnswer(voteId, answerId);

        assert.equal(answer, changedAnswer, "Answer wasn't changed successfully");
    });

    it("should create vote, add two answers, two people should vote for second answer", async() => {
        let instance = await VoteFactory.deployed();
        
        let question = "vote's question";
        let firstAnswer = "first";
        let secondAnswer = "second";
        let expectedNum = 2;
        await instance.createVote(question);
        let voteId = (await instance.createVote.call(question)).toNumber();
        await instance.createVote(question);

        await instance.addAnswer(voteId, firstAnswer);

        let answerId = (await instance.addAnswer.call(voteId, secondAnswer)).toNumber();
        await instance.addAnswer(voteId, secondAnswer);
        await instance.vote(voteId, answerId, {from : accounts[1]});
        await instance.vote(voteId, answerId, {from : accounts[2]});
        let numOfVoted = (await instance.countVoted.call(voteId, answerId)).toNumber();
        
        assert.equal(numOfVoted, expectedNum, "not 2 voted successfully");
    });
    
});

/*
    it("", async() => {
        let instance = await VoteFactory.deployed();

    });
*/
