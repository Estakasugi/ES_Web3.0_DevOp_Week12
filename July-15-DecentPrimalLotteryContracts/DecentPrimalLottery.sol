// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/*
    @author: ES_TAKASUGI
*/

import "./DecentPrimalLotteryPool.sol";
import "./DecentPrimalLotteryUser.sol";
import "./SafeMath.sol";

contract DecentPrimalLottery is DecentPrimalLotteryPool, DecentPrimalLotteryUser {
    
    using SafeMath for uint256;
    using SafeMath32 for uint32;

    // unit ticket price of a lottery
    uint256 lotteryTicketPrice = 0.0005 ether;

    // id of lotteryTickets
    uint256 lotteryTicketCount = 0;

    // data structure for lottery ticket
    struct LotteryToken {
        uint8[5] firstFive;
        uint8 goldOne;
        string ownerUserName;
        uint256 isWorthInWei;
        uint32 poolNumber;
        uint256 lotteryID;
    }

    //data base for lotteries in the current pool
    LotteryToken[] internal currentPoolLotteries;

    //this function allow registered user to purchase lottery ticket
    function buyLotteryToken(uint8 _firstFive_one, uint8 _firstFive_two, 
                             uint8 _firstFive_three, uint8 _firstFive_four, 
                             uint8 _firstFive_five, uint8 _goldOne) public payable validUser() {
        
        // require current time less than pool end time
        require((block.timestamp < poolLedger[currentPoolIndex.sub(1)].poolEndTime), "current pool ends, wait for the next pool");


        // requrie number check
        require((_firstFive_one >= 1) && (_firstFive_one <= 70), "first five number should be between 1 and 70 (include both)");
        require((_firstFive_two >= 1) && (_firstFive_two <= 70), "first five number should be between 1 and 70 (include both)");
        require((_firstFive_three >= 1) && (_firstFive_three <= 70), "first five number should be between 1 and 70 (include both)");
        require((_firstFive_four >= 1) && (_firstFive_four <= 70), "first five number should be between 1 and 70 (include both)");
        require((_firstFive_five >= 1) && (_firstFive_five <= 70), "first five number should be between 1 and 70 (include both)");
        require((_goldOne >= 1) && (_goldOne <= 25), "gold number should be between 1 and 25 (include both)");
        
        // check if amount of paying is correct
        require(msg.value == lotteryTicketPrice, "Please pay the lottery ticket amount, 0.0005 ether");
        
        uint8[5] memory firstFiveArray = [_firstFive_one, _firstFive_two, _firstFive_three, _firstFive_four, _firstFive_five];
        
        // create a lottery ticket, and push it to the lottery pool
        // after creation, the currentPoolIndex will increase by one for the creation of the next pool. To access the current one, simply do currentPoolIndex -1, the next one, currentPoolIndex
        currentPoolLotteries.push(LotteryToken(firstFiveArray, _goldOne, addressToUserInfo[msg.sender].userName, 0, currentPoolIndex.sub(1), lotteryTicketCount)); 
        
        // 1 more ticket was sold
        lotteryTicketCount = lotteryTicketCount.add(1);

        //user's total cost in ether increasing
        // addressToUserInfo[msg.sender].totalCostInEtherCurrentPool = addressToUserInfo[msg.sender].totalCostInEtherCurrentPool.add(lotteryTicketPrice);
        usersDataLedger[addressToUserInfo[msg.sender].userID].totalCostInEtherCurrentPool = usersDataLedger[addressToUserInfo[msg.sender].userID].totalCostInEtherCurrentPool.add(lotteryTicketPrice);

        //pool's total accumulation increasing
        poolLedger[currentPoolIndex.sub(1)].poolAccumulateInEther = poolLedger[currentPoolIndex.sub(1)].poolAccumulateInEther.add(lotteryTicketPrice);

        //check if current pool's accumulate greater than 3 times of max user pay, if so, startpool
        uint256 maxAmountFromUser = findMaxCostInEtherAmongUsers();
        if ( poolLedger[currentPoolIndex.sub(1)].poolAccumulateInEther > maxAmountFromUser.mul(3) ){
            poolStart();
        }
        
    }

    //check lottery by id
    function checkLotteryByID(uint256 _Id) public view validUser() returns(LotteryToken memory) {
        return currentPoolLotteries[_Id];
    }

    function getBalanceLottery() public view returns (uint256) {
        return address(this).balance;
    }




}