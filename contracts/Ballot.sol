// SPDX-License-Identifier: MIT

pragma solidity >0.5.0;
contract Ballot {

    // 包含錢包地址以及他的選擇
    struct vote{ 
        address voterAddress;
        string choice;
    }
    //投票人
    struct voter{ 
        string voterName;
        uint allowedVote; //可投票數
        bool voted; 
    }
    //uint private countResult = 0; // 計算同意數量
    //uint public finalResult = 0; // 投票結束由countResult->finalResult 變為public 
    //uint public totalVote = 0; // 已投票的數量
    
    // 所有的可投票人in voterRegister
    uint public totalVoter = 0; 
    // 所有可選舉
    uint public totalCandidate = 0;
    // 存候選人的array
    uint public candidatesIndex;
    string [] public candidates;
    
    string public elected = 'None';
 

    
    address public ballotOfficialAddress;      
    string public ballotOfficialName;
    string public proposal; 
    
    // 
    mapping(uint => vote) private votes; 
    mapping(address => voter) public voterRegister; // 可投票人 public 
    // 候選人得票記錄
    mapping(string => uint) public candidateBallotAmount;
    
    enum State { Created, Voting, Ended } // 列舉變數投票狀態
	State public state;  //state狀態變數
	
	//creates a new ballot contract
	constructor(string memory _ballotOfficialName, string memory _proposal)  public { // manager name、topic 
        ballotOfficialAddress = msg.sender;
        ballotOfficialName = _ballotOfficialName;
        proposal = _proposal;
        
        state = State.Created; // 狀態為created 
    }
    
    
	modifier condition(bool _condition) {
		require(_condition);
		_;
	}

	modifier onlyOfficial() {
		require(msg.sender == ballotOfficialAddress);
		_;
	}

	modifier inState(State _state) {
		require(state == _state);
		_;
	}
	
	modifier checkRemainingVote(uint _ballotAmount) {
	    require(_ballotAmount <= voterRegister[msg.sender].allowedVote);
	    _;
	}
    
    event remainingVoteAmount(address voter, uint remainVoteAmount);
    event voterAdded(address voter);  
    event voteStarted();
    event voteDone(address voter);
    event candidateAdd(uint index, string cName);
    event voteEnded(string cName);
    event candidateInfo(string cName, uint amount);

    //add voter
    function addVoter(address _voterAddress, string memory _voterName, uint _allowedVote)
        public
        inState(State.Created)
        onlyOfficial
    {
        voter memory v;
        v.voterName = _voterName;
        v.allowedVote = _allowedVote;
        voterRegister[_voterAddress] = v;
        totalVoter++;
        emit voterAdded(_voterAddress);
    }
    
    function getCanNum() public view returns (uint length){
        return candidates.length;
    }
    
    function addCandidate (string memory _cName) public inState(State.Created) onlyOfficial {
        candidates.push(_cName);
        // for (uint i = 0; i <  candidates.length; i++){
        //     candidateBallotAmount[candidates[i]] = 0;
        // }
        candidateBallotAmount[_cName] = 0;
        emit candidateAdd(totalCandidate, _cName);
        totalCandidate ++ ;
        
    }
    
    
    //declare voting starts now
    function startVote()
        public
        inState(State.Created)
        onlyOfficial
    {
        state = State.Voting;     
        emit voteStarted();
    }

    //voters vote by indicating their choice (candidate name)
    function doVote(string memory _choice , uint _ballotAmount)
        public
        inState(State.Voting)
        checkRemainingVote(_ballotAmount)
        returns (bool voted)
    {   
        bool success = false;
        
        if (bytes(voterRegister[msg.sender].voterName).length != 0 
        && voterRegister[msg.sender].allowedVote > 0){
            vote memory v;
            v.voterAddress = msg.sender;
            v.choice = _choice;
            
            candidateBallotAmount[_choice] += _ballotAmount;
            voterRegister[msg.sender].allowedVote -= _ballotAmount;
            emit remainingVoteAmount(msg.sender, voterRegister[msg.sender].allowedVote);
            success = true;
            if(voterRegister[msg.sender].allowedVote == 0){
                voterRegister[msg.sender].voted = true;
                emit voteDone(msg.sender);
            }
        }
        return success;
    }
    
    //end votes
    function endVote()
        public
        inState(State.Voting)
        onlyOfficial
    {
        uint max = 0 ;
        state = State.Ended;
        for  (uint i = 0; i < candidates.length; i++) {
            string memory currCandidateName = candidates[i];
            uint howmuch = candidateBallotAmount[currCandidateName];
            
            emit candidateInfo(currCandidateName, howmuch);
            
            if (max < candidateBallotAmount[currCandidateName]){
                max = candidateBallotAmount[currCandidateName];
                elected = currCandidateName;
            }
        }
        for (uint r = 0; r < candidates.length; r++){
          if (candidateBallotAmount[candidates[r]] == max ){
              emit voteEnded(candidates[r]);
            }
        }

        

    }
}