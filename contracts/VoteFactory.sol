pragma solidity ^ 0.4.24;

import "./Ownable.sol";

contract VoteFactory is Ownable {

    event CreateVote(uint256 indexed voteId, string question);
    event AddAnswer(uint256 indexed answerId, string answer);
    event PersonVote(uint256 indexed voteId, uint256 answerId);


    struct Vote {
        string question;
        string[] answers;
        mapping(uint256 => uint256) countVotes;
        mapping(address => bool) voted;
    }

    Vote[] public votes;

    uint256 pendingBalance;

    mapping(uint => address) voteToOwner;
    mapping(address => uint) ownerVoteCount;

    modifier onlyOwnerOf(uint256 _voteId) {
        require(voteToOwner[_voteId] == msg.sender);
        _;
    }

    function donate() payable public {
        pendingBalance += msg.value;
    }

    function withdraw() external onlyOwner {
        owner.transfer(pendingBalance);
    }

    function createVote(string _question) public {
        uint256 voteId = votes.push(Vote(_question, new string[](0))) - 1;
        voteToOwner[voteId] = msg.sender;
        ownerVoteCount[msg.sender]++;
        emit CreateVote(voteId, _question);
    }

    function addAnswer(uint256 _voteId, string _answer) public onlyOwnerOf(_voteId) {
        uint256 answerId = votes[_voteId].answers.push(_answer) - 1;
        emit AddAnswer(answerId, _answer);
    }

    function vote(uint256 _voteId, uint256 _answerId) public {
        Vote storage myVote = votes[_voteId];
        require(_answerId < myVote.answers.length);
        require(!myVote.voted[msg.sender]);
        myVote.countVotes[_voteId]++;
        myVote.voted[msg.sender] = true;
        emit PersonVote(_voteId, _answerId);
    }


    function getQuestion(uint _voteId) view external returns(string) {
        return votes[_voteId].question;
    }    

    function getAnswer(uint _voteId, uint _answerId) view external returns(string) {
        return votes[_voteId].answers[_answerId];
    }

    function countAnswers(uint _voteId) view external returns(uint) {
        return votes[_voteId].answers.length;
    }   

    function countVotes(uint _voteId, uint _answerId) external view returns(uint) {
        return votes[_voteId].countVotes[_answerId];
    }
}