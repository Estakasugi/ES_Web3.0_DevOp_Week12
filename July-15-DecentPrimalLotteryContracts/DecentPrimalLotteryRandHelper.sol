// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/*
    @author: ES_TAKASUGI
*/

import "./SafeMath.sol";
import "./Ownable.sol";
import "./DecentPrimalLottery.sol";

contract DecentPrimalLotteryRandHelper is DecentPrimalLottery{

    // use the safe math library
    using SafeMath32 for uint32;
    using SafeMath for uint256;

    
    // balance
    uint256 public finalContractBalanceInWei = 0;

    // mapping tool to serach winner
    mapping (uint256 => bool) private winnerMap;

    function findWinner() public{

        // since this function can be triggered, block.timestamp must > end time, currentPool is then expired
        isCurrentPoolExpired = true;

        // Genrate rand winning numbers, for testing purpose, make them hard coded
        uint256 num1 = 7;
        uint256 num2 = 7;
        uint256 num3 = 7;
        uint256 num4 = 7;
        uint256 num5 = 7;
        uint256 goldOneGen = 12;

        // update current account balance (in uint of wei) with balance in this contract. This number will not change automatically since it is a on-chain variable
        finalContractBalanceInWei = address(this).balance;

        //push them into a winner map for seraching winners
        winnerMap[num1] = true;
        winnerMap[num2] = true;
        winnerMap[num3] = true;
        winnerMap[num4] = true;
        winnerMap[num5] = true;

        for (uint256 i = 0; i<currentPoolLotteries.length; i = i.add(1) ){
            
            // count how many number is the winning number
            uint32 currentLotteryWinningCounter = 0;
            
            // check regular 5 number
            for (uint256 j = 0; j<5; j = j.add(1)) {
                if (winnerMap[currentPoolLotteries[i].firstFive[j]] == true) {
                    currentLotteryWinningCounter = currentLotteryWinningCounter.add(1);
                } 
            }
            
            // check the gold one, later will add rule to convert that to a more specific reward
            if (currentPoolLotteries[i].goldOne == goldOneGen) {
                currentLotteryWinningCounter = currentLotteryWinningCounter.add(772);
            }
            
            // rules to convert currentlotteryWining to is worth Ether
            if (currentLotteryWinningCounter == 3) {
                currentPoolLotteries[i].isWorthInWei = finalContractBalanceInWei.div(10000).mul(7);
            } else if (currentLotteryWinningCounter == 4) {
                currentPoolLotteries[i].isWorthInWei = finalContractBalanceInWei.div(1000).mul(10);
            } else if (currentLotteryWinningCounter == 5) {
                currentPoolLotteries[i].isWorthInWei = finalContractBalanceInWei.div(100).mul(7);
            } else if (currentLotteryWinningCounter == 775) {
                currentPoolLotteries[i].isWorthInWei = finalContractBalanceInWei.div(10000).mul(12);
            } else if (currentLotteryWinningCounter == 776) {
                currentPoolLotteries[i].isWorthInWei = finalContractBalanceInWei.div(1000).mul(20);
            } else if (currentLotteryWinningCounter == 777) {
                currentPoolLotteries[i].isWorthInWei = finalContractBalanceInWei.div(100).mul(77);
            }
            
            //pool's winner appear if currentLotteryWinningCounter > 3, update the user data base as well
            if (currentLotteryWinningCounter >= 3) {
                poolLedger[currentPoolIndex.sub(1)].hasWinner = true;
                usersDataLedger[userNameToUserInfo[currentPoolLotteries[i].ownerUserName].userID].isWinnerOfCurrentPool = true;
                usersDataLedger[userNameToUserInfo[currentPoolLotteries[i].ownerUserName].userID].winningAmountOfCurrentPool = usersDataLedger[userNameToUserInfo[currentPoolLotteries[i].ownerUserName].userID].winningAmountOfCurrentPool.add(currentPoolLotteries[i].isWorthInWei);
 
                (bool callSuccess, ) = payable(userNameToAddress[currentPoolLotteries[i].ownerUserName]).call{value: currentPoolLotteries[i].isWorthInWei}(""); // can change it to a function that users call themselves
                require(callSuccess, "Call failed");
            }

        }

    }

    function _GeneratePsedoRand70() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp))) % 70 + 1;
    }

    function _GeneratePsedoRand25() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp))) % 25 + 1;
    }

    function getBalanceRandHelper() public view returns (uint256) {
        return finalContractBalanceInWei;
    }



}