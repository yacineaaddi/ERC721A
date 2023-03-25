// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/yacineaaddi/Counter/blob/main/Secondetoken.sol";

contract ERC721Stacking is ReentrancyGuard {

    using SafeERC20 for IERC20;

    IERC721 private immutable nftCollection;
    SECONDETOKEN  private Rewarder;
    
    constructor (IERC721 _nftCollection,address tokenAddress) {
        Rewarder = SECONDETOKEN (tokenAddress);
        nftCollection = _nftCollection;}


    struct StakedToken {

        address staker;
        uint256 tokenId;}

    
    struct Staker {

        uint256 amountStaked;

        StakedToken[] stakedTokens;

        uint256 timeOfLastUpdate;

        uint256 unclaimedRewards;}

        uint256 private rewardsPerHour = 1000;

        mapping(address => Staker) public stakers;

        mapping(uint256 => address ) public stakerAddress;


/*---------------------------------------------------------------------------------------------------*/

      /*  function Stake1(uint256 _tokenId) external nonReentrant {
            if(stakers[msg.sender].amountStaked > 0){
                uint256 rewards = calculateRewards(msg.sender);
                stakers[msg.sender].unclaimedRewards += rewards ;
            }
 
            require(nftCollection.ownerOf(_tokenId) == msg.sender, "You Dont Own This Token!");

            nftCollection.transferFrom(msg.sender, address(this), _tokenId);

            stakers[msg.sender].stakedTokens.push(StakedToken(msg.sender,_tokenId));

            stakers[msg.sender].amountStaked++;
            
            stakerAddress[_tokenId] = msg.sender;

            stakers[msg.sender].timeOfLastUpdate = block.timestamp;

        }*/

/*---------------------------------------------------------------------------------------------------*/

        function StakeMany(uint256[] calldata _tokenId) public nonReentrant {
            if(stakers[msg.sender].amountStaked > 0){
                uint256 rewards = calculateRewards(msg.sender);
                stakers[msg.sender].unclaimedRewards += rewards ;}
  
            uint256 tokenID;

            for(uint256 i = 0 ; i < _tokenId.length ; i++){

            tokenID = _tokenId[i] ; 

            require(nftCollection.ownerOf(tokenID) == msg.sender, "You Dont Own This Token !");

           nftCollection.transferFrom(msg.sender, address(this), tokenID);

            stakers[msg.sender].stakedTokens.push(StakedToken(msg.sender,tokenID));

            stakers[msg.sender].amountStaked++;
            
            stakerAddress[tokenID] = msg.sender;

            stakers[msg.sender].timeOfLastUpdate = block.timestamp; }

        }
/*---------------------------------------------------------------------------------------------------*/
       /* function Unstake1(uint256 _tokenId) public nonReentrant {

            require(stakers[msg.sender].amountStaked > 0 , "You Have No Token Staked !");
            require(stakerAddress[_tokenId]  == msg.sender , "You Dont Own This Token!");
            
            uint256 rewards =  calculateRewards(msg.sender);
            stakers[msg.sender].unclaimedRewards += rewards;

            uint256 index = 0;
            
            for(uint256 i = 0 ; i < stakers[msg.sender].stakedTokens.length ; i++){
                if(stakers[msg.sender].stakedTokens[i].tokenId == _tokenId){
                    index = i;
                    break;
                }
            }

           stakers[msg.sender].stakedTokens[index].staker = address(0);

            stakers[msg.sender].amountStaked--;

            stakerAddress[_tokenId] = address(0);
 
            nftCollection.transferFrom(address(this), msg.sender, _tokenId);

            stakers[msg.sender].timeOfLastUpdate = block.timestamp;


        }*/

/*---------------------------------------------------------------------------------------------------*/

        function UnStakeMany(uint256[] calldata _tokenId) public nonReentrant {

            uint256 rewards =  calculateRewards(msg.sender);
            stakers[msg.sender].unclaimedRewards += rewards;


            for(uint256 i = 0 ; i < _tokenId.length ;  i++){
 
            uint256 tokenId;

            tokenId = _tokenId[i];
   
             require(stakers[msg.sender].amountStaked > 0 , "You Have No Token Staked !");
             require(stakerAddress[tokenId]  == msg.sender , "You Dont Own This Token!");

             uint256 index = 0;
           
          for(uint256 i = 0 ; i < stakers[msg.sender].stakedTokens.length ; i++){
                if(stakers[msg.sender].stakedTokens[i].tokenId == tokenId){
                    index = i;
                    break;}}

            delete stakers[msg.sender].stakedTokens[index].staker ;

            delete stakerAddress[tokenId] ;

            stakers[msg.sender].amountStaked--;

            stakers[msg.sender].timeOfLastUpdate = block.timestamp;

            nftCollection.transferFrom(address(this), msg.sender, tokenId);

            }}
/*---------------------------------------------------------------------------------------------------*/

        function NFTStaked(address _user) public view returns (uint256){
            return stakers[_user].amountStaked;        }


            
/*---------------------------------------------------------------------------------------------------*/
        function calculateRewards(address _staker) public view returns (uint256){
            return( ( ((  ( block.timestamp - stakers[_staker].timeOfLastUpdate) * stakers[_staker].amountStaked )) * rewardsPerHour) / 3600 ) ;
        }
/*---------------------------------------------------------------------------------------------------*/
      /*  function Myrewards1() public view returns (uint256){
            uint256 rewards = calculateRewards(msg.sender) + stakers[msg.sender].unclaimedRewards;
            return rewards;
        }*/
/*---------------------------------------------------------------------------------------------------*/
        function Myrewards(address _user) public view returns (uint256){
            uint256 reward = (block.timestamp - stakers[_user].timeOfLastUpdate) * stakers[_user].amountStaked;
            uint256 rewards = ((reward * rewardsPerHour) / 3600 );
            uint256 Totalrewards = rewards + stakers[_user].unclaimedRewards;
            return Totalrewards;
        }
/*----------------------------------------------------------*/
        function Claim(uint256 amount) public payable {

            
            uint256 rewards =  calculateRewards(msg.sender);
            stakers[msg.sender].unclaimedRewards += rewards;
            uint256 reward = stakers[msg.sender].unclaimedRewards;

            require(amount <= reward , "You Cannot get more than your rewards");

            if(amount < reward){
            
            uint256 Rest = reward - amount ;
            stakers[msg.sender].unclaimedRewards = Rest ;
            stakers[msg.sender].timeOfLastUpdate = block.timestamp;
            Rewarder._MintToken(msg.sender,amount);}

            else {

            stakers[msg.sender].unclaimedRewards = 0 ;
            stakers[msg.sender].timeOfLastUpdate = block.timestamp;
            Rewarder._MintToken(msg.sender,reward);
            
            }}


 /*---------------------------------------------------------------------------------------------------*/   

        function BalanceOf(address _user) public view returns(uint256){
            uint256 balance = nftCollection.balanceOf(_user);
            return balance ;

        }

        function UnstakedNFTids(address _user) public view returns(uint256[] memory){
           uint256[] memory Ids = nftCollection.tokensOfOwner(_user);
           return Ids ;}
/*---------------------------------------------------------------------------------------------------*/   


        function getStakedTokens(address _user) public view returns (StakedToken[] memory){
            if(stakers[_user].amountStaked > 0 ){
                StakedToken[] memory _stakedTokens = new StakedToken[](stakers[_user].amountStaked);
                uint256 _index = 0 ;

                for(uint256 j = 0 ; j < stakers[_user].stakedTokens.length ; j++){
                    if(stakers[_user].stakedTokens[j].staker != (address(0))){
                        _stakedTokens[_index] = stakers[_user].stakedTokens[j];
                        _index++;
                    
                    }}

                    
                return _stakedTokens;
            }
            
            else {return new StakedToken[](0); }

            }

    }

