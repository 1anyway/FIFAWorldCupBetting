//SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";

contract WorldCup {
    address public admin;
    uint8 public currRound;

    string[] public countries = ["GERMANY", "FRANCH", "CHINA", "BRAZIL", "KOREA"];

    mapping (uint8 => mapping (address => Player)) players;
    mapping (uint8 => mapping (Country => address[])) public countryToPlayers;
    mapping (address => uint256) public winnerVaults;

    uint256 public immutable deadline;
    uint256 public lockedAmts;

    enum Country {
        GERMANY,
        FRACH,
        CHINA,
        BRAZIL,
        KOREA
    }

    event Play(uint8 _currRound, address _player, Country _country);
    event Finialize(uint8 _currRound, uint256 _current);
    event ClaimReward(address _claimer, uint256 _amt);


    modifier onlyAdmin {
        require(msg.sender == admin, "not authorized!");
        _;
    }

    struct Player {
        bool isSet;
        mapping (Country => uint256) counts;
    }

    constructor(uint256 _deadline) {
        admin = msg.sender;
        require(_deadline > block.timestamp, "WorldCupLottery: invalid deadline");
        deadline = _deadline;
    }

    function play(Country _selected) payable external {
        require(msg.value == 1 gwei, "invalid funds provided!");
        require(block.timestamp < deadline, "it's all over!");


        // Update countryToPlayers
        countryToPlayers[currRound][_selected].push(msg.sender);

        // Update players
        Player storage player = player[currRound][msg.sender];
        // play.isSet = false
        player.counts[_selected] += 1;

        emit Play(currRound, msg.sender, _selected);
    }

    function finialize(Country _country) onlyAdmin external {
        // Find winners
        address[] memory winners = countryToPlayers[currRound][_country];
        uint256 distributeAmt;

        // Allocate reward amount
        uint currAvalBalance = getValutBalance() - lockedAmts;
        console.log("currAvalBalance:", currAvalBalance, "winners count:", winners.length);


        for (uint i = 0; i < winners.length; i++) {
            address currWinner = winners[i];

            // Get the share each address should get
            Player storage winner = players[currRound][currWinner];
            if (winner.isSet) {
                console.log("this winner has been set already, will be skipped);
                continue;
            }

            winner.isSet = true;

            uint currCounts = winner.counts[_country];
            //uint totalCount += currCount;

            // 
            uint amt = (currAvalBalance / countryToPlayers[currRound][_country].length) * currCounts;

            winnerValuts[currWinner] += amt;
            distributeAmt += amt;
            lockedAmts += amt;

            console.log("winner:", currWinner, "currCounts:", currCounts);
            console.log("reward amt curr:", amt, "total:", winnerValuts[currWinner]);
        }

        uint giftAmt = currAvalBalance - distirbuteAmt;
        if (giftAmt > 0) {
            winnerValuts[admin] += giftAmt;
        }


        emit Finialize(currRound++, uint256(_country));
    }

    function claimReward() external {
        uint256 rewards = winnerVaults[msg.sender];
        require(rewards > 0, "nothing to claim!");

        winnerVaults[msg.sender] = 0;
        lockedAmts -= rewards;
        (bool succeed,) = msg.sender.call{value: rewards}("");
        require(succeed, "claim reward failed!");

        console.log("rewards:", rewards);

        emit ClaimReward(msg.sender, rewards);
    }

    function getValutBalance() public view returns(uint256 bal) {
        bal = address(this).balance;
    }

    function getCountryPlayters(uint8 _round, Country _country) external view returns (uint256) {
        return countryToPlayers[_round][_country].length;
    }

    function getPlayerInfo(uint8 _round, address _player, Country _country) external view returns (uint256) {
        return players[_round][_player].counts[_country];
    }
}
