// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "challenges/ISolvable.sol";
import "challenges/1-HelloWorld.sol";
import "challenges/2-Bank.sol";
import "challenges/3-Multicall.sol";
import "challenges/4-MerkleAirDrop.sol";
import "challenges/MerkleAirDropFactory.sol";
import "challenges/5-ABIOptimizooor.sol";
import "challenges/6-Vault.sol";


contract Core {

    // number of challenges
    uint256 public constant CHAL_NUM = 6;
    
    // Basis Points. 1000 = 100%
    uint256 public constant BP = 1000;
    
    // maximum time to solve a challenge and get a positive score
    uint256 public constant MAX_TIME_TO_SOLVE = 8 hours;

    // address of the adversary that the teams will impersonate
    address public immutable advAddress;

    // maximum score for each challenge
    uint256[CHAL_NUM] public SCORES = [10, 50, 65, 75, 100, 70];

    // timestamp when the challenges where deployed
    uint256 public immutable deployedTimestamp;
    
    // addresses of the challenges
    Solvable[CHAL_NUM] public challenges;

    // cached scores of the challenges
    uint256[CHAL_NUM] public cachedScores;

    error ChallengeSolvedAtDeployment(uint256 index);
    error InvalidChallengeIndex(uint256 index);
    
    constructor(address _advAddress) payable {
        deployedTimestamp = 1720441034; // Event start
        advAddress = _advAddress;
        __deployAll();
    }

    /**
     * @notice Deploys a particular challenge.
     * @param index the index of the challenge to deploy.
     * Warning! Any progress on that particular challenge will be lost.
     */
    function deployChallenge(uint256 index) public payable {
        Solvable challenge;
        if(index == 0) {
            challenge = new HelloWorld();
        }
        else if(index == 1) {
            challenge = new Bank{value: 1 ether}();
        }
        else if (index == 2) {
            address impl = address(new MultiCall());           
            challenge = new MultiCallProxy(impl);
            MultiCall(address(challenge)).deposit{value: 1 ether}();
        }
        else if (index == 3) {
            challenge = MerkleAirDropFactory.deploy(advAddress); // gift one AirDrop to the adversary
        }
        else if (index == 4) {
            challenge = new ABIOptimizooor();
        }
        else if (index == 5) {
            challenge = new Vault();
        }
        else {
            revert InvalidChallengeIndex(index);
        }

        // the challenge must NOT be already solved at deployment time
        if (challenge.isSolved()) revert ChallengeSolvedAtDeployment(index);

        challenges[index] = Solvable(challenge);
    }
    
    /**
     * @notice Returns the sum of the scores of all the challenges.
     */
    function getScoreAll() external returns(uint256 totalScore) {
        for (uint256 index = 0; index < CHAL_NUM; index++) {
            totalScore += getScore(index);
        }
    }

    function getScoreArray() external returns(uint256[CHAL_NUM] memory scoreArray) {
        for (uint256 index = 0; index < CHAL_NUM; index++) {
            scoreArray[index] = getScore(index);
        }
    }
    
    /**
     * @notice Returns the score for a particular challenge.
     * @param index the index of the challenge to score.
     */
    function getScore(uint256 index) public returns(uint256 score) {
        uint256 cachedScore = cachedScores[index];
        
        // if the challenge was already solved, return the cached score
        if (cachedScore != 0) return cachedScore;

        // otherwise, score the challenge

        // not solved, score is 0
        if (!challenges[index].isSolved()) return 0;
        
        // timeToSolve in seconds
        uint256 timeToSolve = block.timestamp - deployedTimestamp;

        // too much time taken to solve, score is 0
        if (timeToSolve >= MAX_TIME_TO_SOLVE) return 0;
        
        // compute the score: score is inversly proportional to the time taken to solve the challenge
        score = SCORES[index] * (BP - (timeToSolve * BP / MAX_TIME_TO_SOLVE));
        cachedScores[index] = score;
    }

    function __deployAll() private {
        for (uint256 i = 0; i < CHAL_NUM; i++) {
            deployChallenge(i);
        }
    }
}
