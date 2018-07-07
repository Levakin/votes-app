pragma solidity ^ 0.4.24;

import "./Ownable.sol";

contract VoteFactory is Ownable {

    event CreateVote(uint256 indexed voteId, string question);
    event ChangeVote(uint256 indexed voteId, string question);
    event AddAnswer(uint256 indexed answerId, string answer);
    event ChangeAnswer(uint256 indexed voteId, uint256 indexed answerId, string answer);
    event PersonVote(uint256 indexed voteId, uint256 answerId);


    struct Vote {
        string question;
        string[] answers;
        mapping(uint256 => uint256) countVoted;
        mapping(address => uint256) votedToAnswer;
    }

    Vote[] public votes;

    uint256 pendingBalance;

    mapping(uint => address) voteToOwner;
    mapping(address => uint) ownerVoteCount;

    modifier onlyOwnerOfVote(uint256 _voteId) {
        require(voteToOwner[_voteId] == msg.sender);
        _;
    }

    function donate() payable public {
        pendingBalance += msg.value;
    }

    function withdraw() public onlyOwner {
        owner.transfer(pendingBalance);
    }

    function createVote(string _question) public {
        uint256 voteId = votes.push(Vote(_question, new string[](0))) - 1;
        voteToOwner[voteId] = msg.sender;
        ownerVoteCount[msg.sender]++;
        emit CreateVote(voteId, _question);
    }

    function changeVoteQuestion(uint256 _voteId, string _question) public onlyOwnerOfVote(_voteId){
        votes[_voteId].question = _question;
    }

    function addAnswer(uint256 _voteId, string _answer) public onlyOwnerOfVote(_voteId) {
        uint256 answerId = votes[_voteId].answers.push(_answer) - 1;
        emit AddAnswer(answerId, _answer);
    }

    function changeAnswer(uint256 _voteId, uint256 _answerId, string _answer) public onlyOwnerOfVote(_voteId){
        votes[_voteId].answers[_answerId] = _answer;
    }

    function vote(uint256 _voteId, uint256 _answerId) public {
        Vote storage myVote = votes[_voteId];
        require(myVote.votedToAnswer[msg.sender] != 0);
        myVote.countVoted[_voteId]++;
        myVote.votedToAnswer[msg.sender] = _answerId;
        emit PersonVote(_voteId, _answerId);
    }

    function getQuestion(uint _voteId) view public returns(string) {
        return votes[_voteId].question;
    }    

    function getAnswer(uint _voteId, uint _answerId) view public returns(string) {
        return votes[_voteId].answers[_answerId];
    }

    function countVotes() view public returns(uint) {
        return votes.length;
    } 

    function countAnswers(uint _voteId) view public returns(uint) {
        return votes[_voteId].answers.length;
    }   

    function countVoted(uint _voteId, uint _answerId) view public returns(uint) {
        return votes[_voteId].countVoted[_answerId];
    }
}