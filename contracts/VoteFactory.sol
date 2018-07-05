pragma solidity ^ 0.4 .24;

import "./Ownable.sol";

contract VoteFactory is Ownable {

    event NewVote(uint indexed voteId, string question);
    event NewAnswer(uint answerId, string answer);

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

    function deposit() payable external onlyOwner {

    }

    function withdraw() external onlyOwner {
        owner.transfer(this.balance);
    }

    function createVote(string _question) public {
        uint voteId = votes.push(Vote(_question, new string[](0))) - 1;
        voteToOwner[voteId] = msg.sender;
        ownerVoteCount[msg.sender]++;
        emit NewVote(voteId, _question);
    }

    function addAnswer(uint _voteId, string _answer) public onlyOwnerOf(_voteId) {
        Vote storage myVote = votes[_voteId];
        uint answerId = myVote.answers.push(_answer) - 1;
        emit NewAnswer(answerId, _answer);
    }

    function getAnswer(uint _voteId, uint _answerId) view external returns(string) {
        Vote storage myVote = votes[_voteId];
        return myVote.answers[_answerId];
    }

    function countAnswers(uint _voteId) view external returns(uint) {
        Vote storage myVote = votes[_voteId];
        return myVote.answers.length;
    }

    function vote(uint _voteId, uint _answerId) public {
        Vote storage myVote = votes[_voteId];
        require(_answerId < myVote.answers.length);
        require(!myVote.voted[msg.sender]);
        myVote.countVotes[_voteId]++;
        myVote.voted[msg.sender] = true;
    }

    function countVotes(uint _voteId, uint _answerId) external view returns(uint) {
        return votes[_voteId].countVotes[_answerId];
    }
}