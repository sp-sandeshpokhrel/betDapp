// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Bet is Ownable {
    enum betType {
        WIN,
        DRAW,
        LOSE
    }
    uint[] public eventsId;
    struct Bets {
        address account;
        uint amount;
    }
    mapping(uint => Bets[]) public win;
    mapping(uint => Bets[]) public lose;
    mapping(uint => Bets[]) public draw;
    mapping(uint => bool) public eventCheck;

    function createEvent(uint newEventId) external onlyOwner {
        require(eventCheck[newEventId] == false, "Event already initialized");
        eventsId.push(newEventId);
        eventCheck[newEventId] = true;
    }

    function betNow(uint bet, uint _eventId) public payable {
        require(eventCheck[_eventId] == true, "Event is not initialized");
        if (bet == uint(betType.WIN)) {
            win[_eventId].push(Bets(msg.sender, msg.value));
        } else if (bet == uint(betType.DRAW)) {
            draw[_eventId].push(Bets(msg.sender, msg.value));
        } else if (bet == uint(betType.LOSE)) {
            lose[_eventId].push(Bets(msg.sender, msg.value));
        } else {
            revert("Bet type not valid");
        }
    }

    function claimBet(uint _event) public {
        //check for the event if completed then distribute money accordingly
    }

    function getBetArray(
        uint bet,
        uint _eventId
    ) public view returns (Bets[] memory bets) {
        if (bet == uint(betType.WIN)) {
            return win[_eventId];
        } else if (bet == uint(betType.DRAW)) {
            return draw[_eventId];
        } else if (bet == uint(betType.LOSE)) {
            return lose[_eventId];
        }
    }
}
