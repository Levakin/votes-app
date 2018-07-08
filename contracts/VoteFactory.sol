pragma solidity ^0.4.24;

import "./Ownable.sol";

contract VoteFactory is Ownable {

    event CreateVote(
        address indexed person,
        uint256 indexed voteId,
        string question
    );
    event ChangeVote(
        address indexed person,
        uint256 indexed voteId,
        string question
    );
    event AddAnswer(
        address indexed person,
        uint256 indexed answerId,
        string answer
    );
    event ChangeAnswer(
        address indexed person,
        uint256 indexed voteId,
        uint256 indexed answerId,
        string answer
    );
    event PersonVote(
        address indexed person,
        uint256 indexed voteId,
        uint256 indexed answerId
    );


    struct Vote {
        string question;
        string[] answers;
        mapping(uint256 => uint256) countVoted;
        mapping(address => bool) voted;
    }

    Vote[] public votes;

    uint256 pendingBalance;

    mapping(uint256 => address) voteToOwner;
    mapping(address => uint256) ownerVoteCount;

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

    function createVote(string _question) public returns(uint256) {
        uint256 voteId = votes.push(Vote(_question, new string[](0))) - 1;
        voteToOwner[voteId] = msg.sender;
        ownerVoteCount[msg.sender]++;
        emit CreateVote(msg.sender, voteId, _question);
        return voteId;
    }

    function changeVote(uint256 _voteId, string _question)
        public
        onlyOwnerOfVote(_voteId)
    {
        votes[_voteId].question = _question;
        emit ChangeVote(msg.sender, _voteId, _question);
    }

    function addAnswer(uint256 _voteId, string _answer)
        public
        onlyOwnerOfVote(_voteId)
        returns(uint256)
    {
        uint256 answerId = votes[_voteId].answers.push(_answer) - 1;
        emit AddAnswer(msg.sender, answerId, _answer);
        return answerId;
    }

    function changeAnswer(uint256 _voteId, uint256 _answerId, string _answer)
        public
        onlyOwnerOfVote(_voteId)
    {
        votes[_voteId].answers[_answerId] = _answer;
        emit ChangeAnswer(msg.sender, _voteId, _answerId, _answer);
    }

    function vote(uint256 _voteId, uint256 _answerId) public {
        Vote storage myVote = votes[_voteId];
        require(!myVote.voted[msg.sender]);
        myVote.countVoted[_voteId]++;
        myVote.voted[msg.sender] = true;
        emit PersonVote(msg.sender, _voteId, _answerId);
    }

    function getQuestion(uint256 _voteId) view public returns(string) {
        return votes[_voteId].question;
    }    

    function getAnswer(uint256 _voteId, uint256 _answerId)
        view
        public
        returns(string)
    {
        return votes[_voteId].answers[_answerId];
    }

    function countVotes() view public returns(uint256) {
        return votes.length;
    } 

    function countAnswers(uint256 _voteId) view public returns(uint256) {
        return votes[_voteId].answers.length;
    }   

    function countVoted(uint256 _voteId, uint256 _answerId)
        view
        public
        returns(uint256)
    {
        return votes[_voteId].countVoted[_answerId];
    }
}