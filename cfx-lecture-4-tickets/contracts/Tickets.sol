// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.7.1;

contract Tickets {
    address public owner;

    uint256 public num_tickets;
    uint256 public price_drips;
    uint public event_timestamp;
    mapping (address => uint256) public has_ticket_num;

    event Validated(address visitor);

    constructor(uint256 num, uint256 price, uint timestamp) public {
        owner = msg.sender;
        num_tickets = num;
        price_drips = price * 1e18;
        event_timestamp = timestamp;
    }

    // buy ticket
    function buy() public payable {
        // check that we still have tickets left
        require(num_tickets > 0, "TICKETS: no tickets left");

        // check if the buying price is correct
        require(msg.value == price_drips, "TICKETS: incorrect amount");

        // check if the times is more than 2 hours before the event
        require(block.timestamp <= event_timestamp - 2 hours, "TICKETS: time to the event is less than 2 hours");

        // successful buy
        has_ticket_num[msg.sender] += 1;
        num_tickets -= 1;
    }

    // validate ticket
    function validate(address visitor) public {
        require(msg.sender == owner, "TICKETS: unauthorized");
        require(has_ticket_num[visitor] > 0, "TICKETS: visitor has no ticket");

        has_ticket_num[visitor] -= 1;
        emit Validated(visitor);
    }

    // withdraw profit
    function withdraw() public {
        require(msg.sender == owner, "TICKETS: unauthorized");

        // check if the time is 1 day after the event
        require(block.timestamp >= event_timestamp + 1 days, "TICKETS: time to the event is less than 1 day");
        uint256 profit = address(this).balance;
        msg.sender.transfer(profit);
    }
}