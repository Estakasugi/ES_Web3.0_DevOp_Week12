// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/*
    @author: ES_TAKASUGI
*/

import "./DecentPrimalLotteryPool.sol";
import "./DecentPrimalLotteryUser.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./DecentPrimalLottery.sol";
import "./DecentPrimalLotteryRandHelper.sol";

contract DecentPrimalLotteryHelper is DecentPrimalLottery, DecentPrimalLotteryRandHelper {
    
    // use the safe math library
    using SafeMath32 for uint32;
    using SafeMath for uint256;

    // pool reset flag
    bool hasPoolRecentReseted = false;

    // once contracts been deployed, following things happens
    constructor() {
        createPool(); // the first pool is created
    }


    // this function check if the msg sender is the winner, the first user who check this function will trigger the find winner function and shall be rewarded with ether worth of 3 lottery tickets
    function amITheWinner() public validUser() returns(bool) {
        require(block.timestamp > poolLedger[currentPoolIndex.sub(1)].poolEndTime, "The pool does not end yet");
        
        // if the pool does not find winners yet
        if (poolLedger[currentPoolIndex.sub(1)].hasWinner == false) {
            findWinner();
            // reward the first caller
            (bool callSuccess, ) = payable(msg.sender).call{value: lotteryTicketPrice.mul(5).div(10)}("");
            require(callSuccess, "Call failed");
        }

        // return if the caller is a winner
        return usersDataLedger[addressToUserInfo[msg.sender].userID].isWinnerOfCurrentPool;

    }

    // this function return all lotteryTokens a user has bought
    function lotteryListView() public view validUser() returns(uint256[] memory){
        uint256 currentLen = (usersDataLedger[addressToUserInfo[msg.sender].userID].totalCostInEtherCurrentPool)/(lotteryTicketPrice);
        uint256[] memory result = new uint256[](currentLen);
        uint counter = 0;
        for(uint256 i = 0; i<currentPoolLotteries.length; i = i.add(1)) {
            if (userNameToAddress[currentPoolLotteries[i].ownerUserName] == msg.sender) {
                result[counter] = i;
                counter = counter.add(1);
            }
        }

        return result;
    }


    // this function allow contract owner to extract remainings after prize distributed from the current lottery pool
    function withdrawFromCurrentPool() public onlyOwner() {

        // after creation, the currentPoolIndex will increase by one for the creation of the next pool. To access the current one, simply do currentPoolIndex -1, the next one, currentPoolIndex
        require((isCurrentPoolExpired == true), "You can not withdraw from the pool before the pool expired");
        poolLedger[currentPoolIndex.sub(1)].poolAccumulateInEther = 0;

        (bool callSuccess, ) = payable(0x972f1d1799B5Af0988ea78d2d97Bd7a9BAceE252).call{value: address(this).balance}(""); // change address in payable into the distribution contract's address
        require(callSuccess, "Call failed");

        resetPool();
        resetUserLedger();
        resetCurrentPoolLotteries();
    }


    // this function reset the pool
    function resetPool() internal {
        require(block.timestamp >= poolLedger[currentPoolIndex.sub(1)].poolEndTime); // after creation, the currentPoolIndex will increase by one for the creation of the next pool. To access the current one, simply do currentPoolIndex -1
        isCurrentPoolExpired = true;
        createPool();
        isCurrentPoolExpired = false;
        hasPoolRecentReseted = true;
        finalContractBalanceInWei = 0;
    }

    // this function reset user ledger
    function resetUserLedger() internal {
        require(hasPoolRecentReseted, "resetUserLedger can't be used at this time");

        for (uint256 i = 0; i < usersDataLedger.length; i = i.add(1)) {
            usersDataLedger[i].totalCostInEtherCurrentPool = 0;
            usersDataLedger[i].isWinnerOfCurrentPool = false;
            usersDataLedger[i].winningAmountOfCurrentPool = 0;
        }
        
        hasPoolRecentReseted = false;
    }


    // this function reset lottery ledger 
    function resetCurrentPoolLotteries() internal {
        lotteryTicketCount = 0;
        delete currentPoolLotteries;
    }




}