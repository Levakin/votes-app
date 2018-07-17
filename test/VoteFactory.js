
var expectThrow = require("./helpers/expectThrow");
var VoteFactory = artifacts.require("VoteFactory");

contract('VoteFactory', async (accounts) => {
    var instance ;

    beforeEach('setup contract for each test', async function () {
        instance = await VoteFactory.deployed();
    });

    it("should create new vote correctly", async () => {

        let question = "vote's question";

        await instance.createVote(question);
    });

    it("should get second question", async() => {

        let expectedQuestion = "vote's question";

        await instance.createVote("first");

        let voteId = (await instance.createVote.call(expectedQuestion)).toNumber();
        await instance.createVote(expectedQuestion);

        let createdQuestion = await instance.getQuestion.call(voteId);

        assert.equal(expectedQuestion, createdQuestion, "Vote wasn't created successfully");
    });

    it("should change second question", async() => {
        let initialQuestion = "vote's question";
        let expectedQuestion = "changed question";

        await instance.createVote("first");

        let voteId = (await instance.createVote.call(initialQuestion)).toNumber();
        await instance.createVote(initialQuestion);

        await instance.setQuestion(voteId, expectedQuestion);        
        let changedQuestion = await instance.getQuestion.call(voteId);

        assert.equal(expectedQuestion, changedQuestion, "Vote wasn't changed successfully");
    });

    it("should get correct second answer", async() => {
        
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

    it("should change second answer", async() => {
        
        let question = "vote's question";
        let firstAnswer = "first";
        let secondAnswer = "second";
        let changedAnswer = "changed";

        let voteId = (await instance.createVote.call(question)).toNumber();
        await instance.createVote(question);

        await instance.addAnswer(voteId, firstAnswer);

        let answerId = (await instance.addAnswer.call(voteId, firstAnswer)).toNumber();
        await instance.addAnswer(voteId, secondAnswer);

        await instance.setAnswer(voteId, answerId, changedAnswer);
        let answer = await instance.getAnswer(voteId, answerId);

        assert.equal(answer, changedAnswer, "Answer wasn't changed successfully");
    });

    it("two people should vote for second answer", async() => {
        
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

        await instance.startVote(voteId);

        await instance.cast(voteId, answerId, {from : accounts[1]});
        await instance.cast(voteId, answerId, {from : accounts[2]});
        let numCast = (await instance.countCast.call(voteId, answerId)).toNumber();
        
        assert.equal(numCast, expectedNum, "not 2 voted successfully");
    });

    it("person should vote for first answer and revote for second", async() => {
        let question = "vote's question";
        let firstAnswer = "first";
        let secondAnswer = "second";
        let expectedNum = 2;
        await instance.createVote(question);
        let voteId = (await instance.createVote.call(question)).toNumber();
        await instance.createVote(question);

        let firstAnswerId = (await instance.addAnswer.call(voteId, firstAnswer)).toNumber();
        await instance.addAnswer(voteId, firstAnswer);

        let secondAnswerId = (await instance.addAnswer.call(voteId, secondAnswer)).toNumber();
        await instance.addAnswer(voteId, secondAnswer);

        await instance.startVote(voteId);

        await instance.cast(voteId, firstAnswerId, {from : accounts[1]});
        await instance.cast(voteId, secondAnswerId, {from : accounts[2]});
        await instance.cast(voteId, secondAnswerId, {from : accounts[1]});
        let numCast = (await instance.countCast.call(voteId, secondAnswerId)).toNumber();
        
        assert.equal(numCast, expectedNum, "not revoted successfully");
    });
    
    it("should throw when smb doesn't have access to add answers", async() => {
        let question = "vote's question";
        let answer = "answer";
        let voteId = (await instance.createVote.call(question)).toNumber();
        await instance.createVote(question);
        await instance.addAnswer(voteId, answer);
        await expectThrow(instance.addAnswer(voteId, answer, {from: accounts[1]}));
    });

    it("should start and stop vote", async() => {
        let stopped = 2;
        let question = "vote's question";

        let voteId = (await instance.createVote.call(question)).toNumber();
        await instance.createVote(question);
        await instance.startVote(voteId);
        await instance.stopVote(voteId);

        let state = (await instance.getState.call(voteId)).toNumber();
        assert.equal(state, stopped, "not stopped");
    });

    it("should get correct results", async() => {
        let question = "vote's question";
        let firstAnswer = "first";
        let secondAnswer = "second";

        await instance.createVote(question);
        let voteId = (await instance.createVote.call(question)).toNumber();
        await instance.createVote(question);

        await instance.addAnswer(voteId, firstAnswer);

        let answerId = (await instance.addAnswer.call(voteId, secondAnswer)).toNumber();
        await instance.addAnswer(voteId, secondAnswer);

        await instance.startVote(voteId);

        await instance.cast(voteId, answerId, {from : accounts[1]});
        await instance.cast(voteId, answerId, {from : accounts[2]});
        
        await instance.stopVote(voteId);


        let result = await instance.getResultsQuestion.call(voteId);
        
        assert.equal(result, secondAnswer, "not correct result");
    });
});

/*
    it("", async() => {

    });
*/
