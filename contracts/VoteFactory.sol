pragma solidity ^0.4.24;

import "./Ownable.sol";

contract VoteFactory is Ownable {

    event CreateVote(
        address indexed person,
        uint256 indexed voteId,
        string question
    );
    event SetQuestion(
        address indexed person,
        uint256 indexed voteId,
        string question
    );
    event AddAnswer(
        address indexed person,
        uint256 indexed voteId,
        uint256 indexed answerId,
        string answer
    );
    event SetAnswer(
        address indexed person,
        uint256 indexed voteId,
        uint256 indexed answerId,
        string answer
    );
    event PersonCast(
        address indexed person,
        uint256 indexed voteId,
        uint256 indexed answerId
    );

    enum State {
        Initial,
        Started,
        Stopped
    }

    struct Vote {
        State state;
        string question;
        string[] answers;
        mapping(address => uint256) personToAnswer;
        mapping(uint256 => uint256) numCast;
        mapping(address => bool) voted;
    }    

    Vote[] public votes;

    // uint256 pendingBalance;

    mapping(uint256 => address) voteToOwner;
    // mapping(address => uint256) ownerVoteCount;

    modifier onlyOwnerOfVote(uint256 _voteId) {
        require(voteToOwner[_voteId] == msg.sender);
        _;
    }

    modifier onlyVoteState(uint256 _voteId, State _state) {
        require(votes[_voteId].state == _state);
        _;
    }

    function donate() payable public {
        owner.transfer(msg.value);
    }

    // function withdraw() public onlyOwner {
    //     owner.transfer(pendingBalance);
    // }

    function createVote(string _question) public returns(uint256) {
        uint256 voteId = votes.push(Vote(State.Initial, _question, new string[](0))) - 1;
        voteToOwner[voteId] = msg.sender;
        // ownerVoteCount[msg.sender]++;
        emit CreateVote(msg.sender, voteId, _question);
        return voteId;
    }

    function setQuestion(uint256 _voteId, string _question)
        public
        onlyVoteState(_voteId, State.Initial)
        onlyOwnerOfVote(_voteId)
    {
        votes[_voteId].question = _question;
        emit SetQuestion(msg.sender, _voteId, _question);
    }

    function startVote(uint256 _voteId)
        public
        onlyOwnerOfVote(_voteId)
        onlyVoteState(_voteId, State.Initial)
    {
        votes[_voteId].state = State.Started;
    }

    function stopVote(uint256 _voteId)
        public
        onlyOwnerOfVote(_voteId)
        onlyVoteState(_voteId, State.Started)
    {
        votes[_voteId].state = State.Stopped;
    }

    function addAnswer(uint256 _voteId, string _answer)
        public
        onlyOwnerOfVote(_voteId)
        onlyVoteState(_voteId, State.Initial)
        returns(uint256)
    {
        uint256 answerId = votes[_voteId].answers.push(_answer) - 1;
        emit AddAnswer(msg.sender, _voteId, answerId, _answer);
        return answerId;
    }

    function setAnswer(uint256 _voteId, uint256 _answerId, string _answer)
        public
        onlyOwnerOfVote(_voteId)
        onlyVoteState(_voteId, State.Initial)
    {
        votes[_voteId].answers[_answerId] = _answer;
        emit SetAnswer(msg.sender, _voteId, _answerId, _answer);
    }

    function cast(uint256 _voteId, uint256 _answerId) 
        public
        onlyVoteState(_voteId, State.Started) 
    {
        Vote storage myVote = votes[_voteId];
        if(!myVote.voted[msg.sender]){
            myVote.numCast[_answerId]++;
            myVote.personToAnswer[msg.sender] = _answerId;
            myVote.voted[msg.sender] = true;
        } else {
            require(myVote.personToAnswer[msg.sender] != _answerId);
            myVote.numCast[myVote.personToAnswer[msg.sender]]--;
            myVote.numCast[_answerId]++;
            myVote.personToAnswer[msg.sender] = _answerId;            
        }
        emit PersonCast(msg.sender, _voteId, _answerId);
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

    function getState(uint256 _voteId) public view returns(State) {
        return votes[_voteId].state;
    }

    function countVotes() view public returns(uint256) {
        return votes.length;
    } 

    function countAnswers(uint256 _voteId) view public returns(uint256) {
        return votes[_voteId].answers.length;
    }   

    function countCast(uint256 _voteId, uint256 _answerId)
        view
        public
        returns(uint256)
    {
        return votes[_voteId].numCast[_answerId];
    }

    function getResults(uint256 _voteId)
        view
        public
        onlyVoteState(_voteId, State.Stopped)
        returns(uint256 result)
    {
        uint maxCast;
        uint numCast;
        for (uint i = 0; i < countAnswers(_voteId); i++) {
            numCast = countCast(_voteId, i);            
            if(numCast > maxCast){
                result = i;
                maxCast = numCast;
            }
        }
        return result;
    }

    function getResultsQuestion(uint256 _voteId)
        view
        public
        onlyVoteState(_voteId, State.Stopped)
        returns(string)
    {
        return getAnswer(_voteId, getResults(_voteId));
    }
}