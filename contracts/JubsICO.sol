pragma solidity ^0.4.15;

import './ERC20Basic.sol';
import './StandardToken.sol';

contract JubsICO is StandardToken {
    using SafeMath for uint256;

    //Information coin
    string public name = "HONOR";
    string public symbol = "HNR";
    uint256 public decimals = 18;
    uint256 public totalSupply = 10 * (10*7) * (10 ** decimals); //100 000 000 HNR

    //Adress informated in white paper 
    address public walletETH;                           //Wallet ETH
    address public icoWallet;                           //63%
    address public preIcoWallet;                        //7%
    address public teamWallet;                          //10%
    address public bountyMktWallet;                     //7%
    address public arbitrationWallet;                   //5%
    address public rewardsWallet;                       //5%
    address public advisorsWallet;                      //2%
    address public operationWallet;                     //1%       

    //Utils ICO   
    uint256 public icoStage = 0;        
    uint256 public tokensSold = 0;                      //total number of tokens sold
    uint256 public totalRaised = 0;                     //total amount of money raised in wei
    uint256 public totalTokenToSale = 0;
    uint256 public rate = 3500;                         //HNR/ETH rate / initial 50%
    bool public pauseEmergence = false;                 //the owner address can set this to true to halt the crowdsale due to emergency
    

    //Time Start and Time end
    //Stage pre sale                                            //50%
    uint256 public icoStartTimestampStage = 1515974400;         //15/01/2018 @ 00:00am (UTC)
    uint256 public icoEndTimestampStage = 1518911999;           //18/02/2018 @ 11:59pm (UTC)

    //Stage 1                                                   //25%
    uint256 public icoStartTimestampStage1 = 1518998400;        //19/02/2018 @ 00:00am (UTC)
    uint256 public icoEndTimestampStage1 = 1519603199;          //25/02/2018 @ 11:59pm (UTC)

    //Stage 2                                                   //20%
    uint256 public icoStartTimestampStage2 = 1519603200;        //26/02/2018 @ 00:00am (UTC)
    uint256 public icoEndTimestampStage2 = 1520207999;          //04/03/2018 @ 11:59pm (UTC)

    //Stage 3                                                   //15%
    uint256 public icoStartTimestampStage3 = 1520208000;        //05/03/2018 @ 00:00am (UTC)
    uint256 public icoEndTimestampStage3 = 1520812799;          //11/03/2018 @ 11:59pm (UTC)

    //Stage 4                                                   //10%
    uint256 public icoStartTimestampStage4 = 1520812800;        //12/02/2018 @ 00:00am (UTC)
    uint256 public icoEndTimestampStage4 = 1521417599;          //18/02/2018 @ 11:59pm (UTC)

    //end of the waiting time for the team to withdraw 
    uint256 public teamEndTimestamp = 1579046400;               //01/15/2020 @ 12:00am (UTC) 
                                                                

// =================================== Events ================================================

    event Burn(address indexed burner, uint256 value);  


// =================================== Constructor =============================================
       
    function JubsICO (
        address  _walletETH,
        address  _icoWallet,
        address  _preIcoWallet,
        address  _teamWallet,
        address  _bountyMktWallet,
        address  _arbitrationWallet,
        address  _rewardsWallet,
        address  _advisorsWallet,
        address  _operationWallet
        )
        public 
        {
            require(_walletETH != 0x0);
            require(_icoWallet != 0x0);
            require(_preIcoWallet != 0x0);
            require(_teamWallet != 0x0);
            require(_bountyMktWallet != 0x0);
            require(_arbitrationWallet != 0x0);
            require(_rewardsWallet != 0x0);
            require(_advisorsWallet != 0x0);            
            
            //set wallet that will receive ether
            icoWallet = _icoWallet;

            //set wallet
            walletETH = _walletETH;
            preIcoWallet = _preIcoWallet;
            teamWallet = _teamWallet;
            bountyMktWallet = _bountyMktWallet;
            arbitrationWallet = _arbitrationWallet;
            rewardsWallet = _rewardsWallet;
            advisorsWallet = _advisorsWallet;
            operationWallet = _operationWallet;

            //Distribution Token  
            balances[icoWallet] = totalSupply.mul(63).div(100);                 //totalSupply * 63%
            balances[preIcoWallet] = totalSupply.mul(7).div(100);               //totalSupply * 7%
            balances[teamWallet] = totalSupply.mul(10).div(100);                //totalSupply * 10%
            balances[bountyMktWallet] = totalSupply.mul(7).div(100);            //totalSupply * 7%
            balances[arbitrationWallet] = totalSupply.mul(5).div(100);          //totalSupply * 5%
            balances[rewardsWallet] = totalSupply.mul(5).div(100);              //totalSupply * 5%
            balances[advisorsWallet] = totalSupply.mul(2).div(100);             //totalSupply * 2%
            balances[operationWallet] = totalSupply.mul(1).div(100);            //totalSupply * 1%      

            //set pause
            pause();

            //set token to sale
            totalTokenToSale = balances[icoWallet].add(balances[preIcoWallet]);           
    }

 // ======================================== Modifier ==================================================

    modifier acceptsFunds() {   
        if (icoStage == 0) {
            require(msg.value >= 0.3);    
            require(now >= icoStartTimestampStage);          
            require(now <= icoEndTimestampStage); 
        }

        if (icoStage == 1) {
            require(now >= icoStartTimestampStage1);          
            require(now <= icoEndTimestampStage1);            
        }

        if (icoStage == 2) {
            require(now >= icoStartTimestampStage2);          
            require(now <= icoEndTimestampStage2);            
        }

        if (icoStage == 3) {
            require(now >= icoStartTimestampStage3);          
            require(now <= icoEndTimestampStage3);            
        }

        if (icoStage == 4) {
            require(now >= icoStartTimestampStage4);          
            require(now <= icoEndTimestampStage4);            
        }             
               
        _;
    }    

    modifier nonZeroBuy() {
        require(msg.value > 0);
        _;

    }

    modifier PauseEmergence {
        require(!pauseEmergence);
        _;
    }


//========================================== Functions ===========================================================================

    /// fallback function to buy tokens
    function () PauseEmergence nonZeroBuy acceptsFunds payable public {  
        uint256 amount = msg.value.mul(rate);

        assignTokens(msg.sender, amount);
        totalRaised = totalRaised.add(msg.value);

        forwardFundsToWallet();
    } 

    function forwardFundsToWallet() internal {        
        walletETH.transfer(msg.value);              // immediately send Ether to wallet address, propagates exception if execution fails
    }

    function assignTokens(address recipient, uint256 amount) internal {        
        balances[recipient] = balances[recipient].add(amount);
        tokensSold = tokensSold.add(amount);        
       
        //test token sold, if it was sold more than the total available right total token total
        if (tokensSold > totalTokenToSale) {
            uint256 diferenceTotalSale = totalTokenToSale.sub(tokensSold);
            totalTokenToSale = tokensSold;
            totalSupply = tokensSold.add(diferenceTotalSale);
        }
        
        Transfer(0x0, recipient, amount);
    }  
    

    function manuallyAssignTokens(address recipient, uint256 amount) public onlyOwner {
        require(tokensSold < totalSupply);
        assignTokens(recipient, amount);
    }

    function setRate(uint256 _rate) public onlyOwner { 
        require(_rate < 0);               
        rate = _rate;        
    }

    function setIcoStage(uint256 _icoStage) public onlyOwner {    
        require(_icoStage <= 0); 
        require(_icoStage >= 4);             
        icoStage = _icoStage;        
    }

    function setPauseEmergence() public onlyOwner {        
        pauseEmergence = true;
    }

    function setUnPauseEmergence() public onlyOwner {        
        pauseEmergence = false;
    }   

    function sendTokenTeam(address _to, uint256 amount) public onlyOwner {
        require(_to != 0x0);

        //test deadline to request token
        require(now >= teamEndTimestamp);
        assignTokens(_to, amount);
    }

    function burn(uint256 _value) public whenNotPaused {
        require(_value > 0);

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }   
    
}