// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GamingPlatform is Ownable {
    // Token interface for rewards
    IERC20 public rewardToken;

    // Struct to store player information
    struct Player {
        uint256 totalPoints;
        uint256 rewardsEarned;
    }

    mapping(address => Player) public players;

    // Events
    event PlayerRegistered(address indexed player);
    event PointsAwarded(address indexed player, uint256 points);
    event RewardsClaimed(address indexed player, uint256 rewards);

    // Constructor to set the reward token
    constructor(address _rewardToken) {
        rewardToken = IERC20(_rewardToken);
    }

    // Function to register a new player
    function registerPlayer() public {
        require(players[msg.sender].totalPoints == 0, "Player already registered.");
        players[msg.sender] = Player(0, 0);
        emit PlayerRegistered(msg.sender);
    }

    // Function to award points to a player
    function awardPoints(address player, uint256 points) public onlyOwner {
        require(players[player].totalPoints >= 0, "Player not registered.");
        players[player].totalPoints += points;
        players[player].rewardsEarned = calculateRewards(players[player].totalPoints);
        emit PointsAwarded(player, points);
    }

    // Function to calculate rewards based on points
    function calculateRewards(uint256 points) public pure returns (uint256) {
        // Simple reward calculation: 1 point = 1 token
        return points;
    }

    // Function to allow a player to claim their rewards
    function claimRewards() public {
        Player storage player = players[msg.sender];
        uint256 rewards = player.rewardsEarned;

        require(rewards > 0, "No rewards to claim.");
        require(rewardToken.balanceOf(address(this)) >= rewards, "Insufficient contract balance.");

        player.rewardsEarned = 0; // Reset rewards after claiming
        rewardToken.transfer(msg.sender, rewards);
        emit RewardsClaimed(msg.sender, rewards);
    }

    // Function to deposit rewards into the contract
    function depositRewards(uint256 amount) public onlyOwner {
        require(rewardToken.transferFrom(msg.sender, address(this), amount), "Failed to deposit rewards.");
    }
}
