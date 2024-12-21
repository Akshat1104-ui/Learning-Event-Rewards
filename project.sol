// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LearningEventRewards {
    // Struct to represent a learning event
    struct LearningEvent {
        string name;
        uint256 rewardAmount;
        bool isActive;
    }

    // Owner of the contract
    address public owner;

    // Mapping to track participation streaks
    mapping(address => uint256) public participationStreak;

    // Mapping to track event participation
    mapping(uint256 => mapping(address => bool)) public eventParticipation;

    // Array to store all learning events
    LearningEvent[] public learningEvents;

    // Events
    event EventCreated(uint256 eventId, string name, uint256 rewardAmount);
    event Participated(address indexed participant, uint256 eventId, uint256 streak);
    event RewardDistributed(address indexed participant, uint256 amount);

    // Modifier for owner-only functions
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    // Constructor to set the owner
    constructor() {
        owner = msg.sender;
    }

    // Function to create a new learning event
    function createEvent(string memory name, uint256 rewardAmount) public onlyOwner {
        require(rewardAmount > 0, "Reward amount must be greater than zero");
        learningEvents.push(LearningEvent({name: name, rewardAmount: rewardAmount, isActive: true}));
        emit EventCreated(learningEvents.length - 1, name, rewardAmount);
    }

    // Function to participate in a learning event
    function participateInEvent(uint256 eventId) public {
        require(eventId < learningEvents.length, "Invalid event ID");
        LearningEvent storage learningEvent = learningEvents[eventId];
        require(learningEvent.isActive, "Event is not active");
        require(!eventParticipation[eventId][msg.sender], "Already participated in this event");

        // Mark the user as having participated in this event
        eventParticipation[eventId][msg.sender] = true;

        // Update participation streak
        participationStreak[msg.sender] += 1;

        // Distribute reward
        uint256 reward = learningEvent.rewardAmount;
        payable(msg.sender).transfer(reward);

        emit Participated(msg.sender, eventId, participationStreak[msg.sender]);
        emit RewardDistributed(msg.sender, reward);
    }

    // Function to deactivate an event
    function deactivateEvent(uint256 eventId) public onlyOwner {
        require(eventId < learningEvents.length, "Invalid event ID");
        learningEvents[eventId].isActive = false;
    }

    // Function to fund the contract
    function fundContract() public payable onlyOwner {}

    // Function to withdraw funds from the contract
    function withdrawFunds(uint256 amount) public onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");
        payable(owner).transfer(amount);
    }
}