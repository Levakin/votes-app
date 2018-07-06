pragma solidity ^ 0.4.24;

import "./Ownable.sol";

contract VoteFactory is Ownable {

    event CreateVote(uint indexed voteId, string question);
    event AddAnswer(uint indexed answerId, string answer);
    event PersonVote(uint indexed _voteId, uint _answerId);


    struct Vote {
        string question;
        string[] answers;
        mapping(uint => uint) countVotes;
        mapping(address => bool) voted;
    }

    Vote[] public votes;

    mapping(uint => address) voteToOwner;
    mapping(address => uint) ownerVoteCount;

    modifier onlyOwnerOf(uint _voteId) {
        require(voteToOwner[_voteId] == msg.sender);
        _;
    }

    // function deposit() payable external onlyOwner {

    // }

    // function withdraw() external onlyOwner {
    //     owner.transfer(this.balance);
    // }

    function createVote(string _question) public  returns(bool){
        uint voteId = votes.push(Vote(_question, new string[](0))) - 1;
        voteToOwner[voteId] = msg.sender;
        ownerVoteCount[msg.sender]++;
        emit CreateVote(voteId, _question);
        return true;
    }

    function addAnswer(uint _voteId, string _answer) public onlyOwnerOf(_voteId)  returns(bool){
        Vote storage myVote = votes[_voteId];
        uint answerId = myVote.answers.push(_answer) - 1;
        emit AddAnswer(answerId, _answer);
        return true;
    }

    function vote(uint _voteId, uint _answerId) public returns(bool){
        Vote storage myVote = votes[_voteId];
        require(_answerId < myVote.answers.length);
        require(!myVote.voted[msg.sender]);
        myVote.countVotes[_voteId]++;
        myVote.voted[msg.sender] = true;
        emit PersonVote(_voteId, _answerId);
        return true;
    }


    function getQuestion(uint _voteId) view external returns(string) {
        Vote storage myVote = votes[_voteId];
        return myVote.question;
    }    

    function getAnswer(uint _voteId, uint _answerId) view external returns(string) {
        Vote storage myVote = votes[_voteId];
        return myVote.answers[_answerId];
    }

    function countAnswers(uint _voteId) view external returns(uint) {
        Vote storage myVote = votes[_voteId];
        return myVote.answers.length;
    }   

    function countVotes(uint _voteId, uint _answerId) external view returns(uint) {
        return votes[_voteId].countVotes[_answerId];
    }
}