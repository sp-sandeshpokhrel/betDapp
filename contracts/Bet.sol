// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Bet is Ownable, ChainlinkClient {
    using Chainlink for Chainlink.Request;

    uint256 private constant ORACLE_PAYMENT = (1 * LINK_DIVISIBILITY) / 10; // 0.1 * 10**18
    mapping(uint => uint) public score; //0 for home team win 1 for draw 2 for away team win, maps eventid to score
    mapping(bytes32 => uint) public requestIdToMatchId;
    enum betType {
        WIN,
        DRAW,
        LOSE
    }
    uint[] public eventsId;

    struct Bets {
        uint amount;
        betType wld;
    }

    //mapping(address => Bets[]) public userBets;
    mapping(address => mapping(uint => Bets[])) public userBets;
    mapping(uint => bool) public eventCheck;
    mapping(uint => bool) public eventScore;

    constructor() {
        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
    }

    function createEvent(uint newEventId) external onlyOwner {
        require(eventCheck[newEventId] == false, "Event already initialized");
        eventsId.push(newEventId);
        eventCheck[newEventId] = true;
    }

    //0x00041F080c6624Cb34649fee8492f50b5fb13a01--operator/oracle contract
    //0x326C977E6efc84E512bB9C30f76E30c160eD06FB -- link on goerli
    //c0fdd13cfcca4e308d0948cd1de7ef23--jobid
    function betNow(uint bet, uint _eventId) public payable {
        require(eventCheck[_eventId] == true, "Event is not initialized");
        require(msg.value > 1000000000000000, "Minimum bet is 0.001 ETH");
        if (bet == uint(betType.WIN)) {
            userBets[msg.sender][_eventId].push(Bets(msg.value, betType.WIN));
        } else if (bet == uint(betType.DRAW)) {
            userBets[msg.sender][_eventId].push(Bets(msg.value, betType.DRAW));
        } else if (bet == uint(betType.LOSE)) {
            userBets[msg.sender][_eventId].push(Bets(msg.value, betType.LOSE));
        } else {
            revert("Bet type not valid");
        }
    }

    function requestMatchScore(
        address _oracle,
        string memory _jobId,
        uint matchId
    ) public {
        require(eventCheck[matchId] == true, "Event is not initialized");
        Chainlink.Request memory req = buildChainlinkRequest(
            bytes32(abi.encodePacked(_jobId)),
            address(this),
            this.fulfillScore.selector
        );

        req.add("matchId", Strings.toString(matchId));
        bytes32 requestId = sendChainlinkRequestTo(
            _oracle,
            req,
            ORACLE_PAYMENT
        );
        requestIdToMatchId[requestId] = matchId;
    }

    function fulfillScore(
        bytes32 _requestId,
        uint256 _score
    ) public recordChainlinkFulfillment(_requestId) {
        eventScore[requestIdToMatchId[_requestId]] = true;
        score[requestIdToMatchId[_requestId]] = _score;
    }

    function claimBet(uint _event) public {
        require(eventCheck[_event] = true, "Event is not registered");
        require(eventScore[_event] = true, "Score is not fetched yet");
        Bets[] memory currentUserBets = userBets[msg.sender][_event];
        require(
            currentUserBets.length > 0,
            "No bets done or remain to claim by user"
        );
        for (uint i = 0; i < currentUserBets.length; i++) {
            if (uint(currentUserBets[i].wld) == score[_event]) {
                payable(msg.sender).transfer(currentUserBets[i].amount);
            }
        }
        //check for the event if completed then distribute money accordingly
    }

    function getUserBetArray(
        uint _eventId
    ) public view returns (Bets[] memory bets) {
        return userBets[msg.sender][_eventId];
    }
}
