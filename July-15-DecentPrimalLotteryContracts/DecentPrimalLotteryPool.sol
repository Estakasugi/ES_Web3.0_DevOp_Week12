// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/*
    @author: ES_TAKASUGI
    
    @state variables:

*/

import "./Ownable.sol";
import "./SafeMath.sol";

contract DecentPrimalLotteryPool is Ownable {
    
    // use the safe math library
    using SafeMath32 for uint32;
    using SafeMath for uint256;

    // initate pool related varaibales
    uint32 internal currentPoolIndex = 0; 
    uint256 public poolOpenTime = 10 seconds; // each lottery pool will open for 180 days, July 8th change to 10 sec for testing purpose
    bool public isCurrentPoolExpired = false;

    // setup pool structure
    struct Pool {
        uint32 poolId;
        uint256 poolAccumulateInEther;
        uint256 poolStartTime;
        uint256 poolEndTime;
        bool hasWinner;
    }

    // data Base For pools
    Pool[] internal poolLedger;


    // this function give administrator privilage to start a new pool with restriction
    function createPool() internal {

        require(currentPoolIndex == 0 || isCurrentPoolExpired == true, "the current pool is not expired yet"); // the administor can only start a new pool if : 1, they are creating the first pool, 2. the current pool has expired
        
        uint256 startTime = block.timestamp.add(777777777777 days); // until certain conditions are met, the pool won't start
        poolLedger.push(Pool(currentPoolIndex, 0, startTime, startTime.add(poolOpenTime), false)); // initiate a pool annd store its information to the lottery pool data base
        
        currentPoolIndex = currentPoolIndex.add(1); //safe math version of currentPoolIndex++
    }


    // this function give public access to the current pool information, non-users can also see this information
    function checkPoolInforamtion(uint32 _poolNumber) public view returns(uint32, uint256, uint256, uint256, bool) {
        
        require(_poolNumber < currentPoolIndex, "the pool  you are checking is not available yet");
        return(poolLedger[_poolNumber].poolId, poolLedger[_poolNumber].poolAccumulateInEther, 
               poolLedger[_poolNumber].poolStartTime, poolLedger[_poolNumber].poolEndTime, 
               poolLedger[_poolNumber].hasWinner);
    }

    
    // this function starts the pool's timer
    function poolStart() internal {
        poolLedger[currentPoolIndex.sub(1)].poolStartTime = block.timestamp; // after creation, the currentPoolIndex will increase by one for the creation of the next pool. To access the current one, simply do currentPoolIndex -1
        poolLedger[currentPoolIndex.sub(1)].poolEndTime = poolLedger[currentPoolIndex.sub(1)].poolStartTime.add(poolOpenTime);
    }

    

}