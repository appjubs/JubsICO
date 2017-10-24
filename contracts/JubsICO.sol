pragma solidity ^0.4.15;

/**
 * @title JubsICO
 * @Autor Daniel Marques (Dkdaniz)
 * @dev see https://github.com/appjubs/JubsICO/blob/master/contracts/JubsICO.sol
 */


import './ERC20Basic.sol';
import './StandardToken.sol';

contract JubsICO is StandardToken {
    using SafeMath for uint256;

    //Information coin
    string public name = "Jubs Coin Service";
    string public symbol = "JCS";
    uint256 public decimals = 18;
    uint256 public totalSupply = 300000000 * (10*7) * (10 ** decimals); //300 000 000 JCS

    //Adress informated in white paper
    address public wallet;
    address public investorsWallet;                     //3%
    address public workingCapitalWallet;                //10%
    address public walletToken;                         //70%    
    address public teamWallet;                          //10%
    address public rewardWallet;                        //5%
    address public advisior;                            //2%        

    //Utils ICO
    uint256 public tokensSold = 0;                      // total number of tokens sold
    uint256 public totalRaised = 0;                     // total amount of money raised in wei
    uint256 public totalTokenToSale = 0;
    uint256 public rate = 350;                          // JCS/ETH rate
    uint256 public icoEtherMinCap;                      // in wei
    uint256 public icoEtherMaxCap;                      // in wei
    bool public pauseEmergence = false;                 //the owner address can set this to true to halt the crowdsale due to emergency

    //Time Start and Time end
    uint256 public icoStartTimestamp = 1484179199;      //01/11/2017 @ 11:59pm (UTC)
    uint256 public icoEndTimestamp = 1512000000;        //30/11/2017 @ 11:59pm (UTC)
    uint256 public teamEndTimestamp = 1572566400;       //11/01/2019 @ 12:00am (UTC) end of the waiting time for the team to withdraw 
                                                        //their coins exactly 2 years later

// =================================== Events ================================================

    event Burn(address indexed burner, uint256 value);


// =================================== Constructor =============================================
    
    function JubsICO (
        address _wallet,
        address _investorsWallet,
        address _workingCapitalWallet,
        address _walletToken,
        address _teamWallet,
        address _rewardWallet,
        address _advisior,
        uint256 _icoEtherMinCap,
        uint256 _icoEtherMaxCap)
        public 
        {
            require(_wallet != 0x0);
            require(_investorsWallet != 0x0);
            require(_workingCapitalWallet != 0x0);
            require(_walletToken != 0x0);
            require(_teamWallet != 0x0);
            require(_rewardWallet != 0x0);
            require(_advisior != 0x0);            
            require(_icoEtherMinCap > 0);
            require(_icoEtherMaxCap > 0);
            require(_icoEtherMaxCap > _icoEtherMinCap); 
            
            //set wallet that will receive ether
            wallet = _wallet;

            //set wallet            
            investorsWallet = _investorsWallet;                    
            workingCapitalWallet = _workingCapitalWallet;                
            walletToken = _walletToken;                         
            teamWallet = _teamWallet;                         
            rewardWallet = _rewardWallet;                        
            advisior = _advisior; 

            //Set Min and Max EtherCap
            icoEtherMinCap = _icoEtherMinCap;
            icoEtherMaxCap = _icoEtherMaxCap;

            //Distribution Token            
            balances[_investorsWallet] = totalSupply.mul(3).div(100);           //totalSupply * 3%
            balances[_workingCapitalWallet] = totalSupply.mul(10).div(100);     //totalSupply * 10%      
            balances[_walletToken] = totalSupply.mul(70).div(100);              //totalSupply * 70%
            balances[_teamWallet] = totalSupply.mul(10).div(100);               //totalSupply * 10%
            balances[_rewardWallet] = totalSupply.mul(5).div(100);              //totalSupply * 5%
            balances[_advisior] = totalSupply.mul(2).div(100);      

            //set pause
            pause();

            //set token to sale
            totalTokenToSale = balances[_walletToken];           
    }

 // ======================================== Modifier ==================================================

    modifier acceptsFunds() {        
        require(icoStartTimestamp != 0 && now >= icoStartTimestamp);          
        require(now <= icoEndTimestamp || totalRaised < icoEtherMinCap);        
        require(totalRaised < icoEtherMaxCap);
        _;
    }    

    modifier nonZeroBuy() {
        require(msg.value > 0);
        _;

    }

    modifier testPauseEmergence {
        require(!pauseEmergence);
        _;
    }


//========================================== Functions ===========================================================================

     /// fallback function to buy tokens
    function () testPauseEmergence nonZeroBuy acceptsFunds payable public {  
        uint256 amount = msg.value.mul(rate);

        assignTokens(msg.sender, amount);
        totalRaised = totalRaised.add(msg.value);

        forwardFundsToWallet();
    } 

    function forwardFundsToWallet() internal {
        wallet.transfer(msg.value); // immediately send Ether to wallet address, propagates exception if execution fails
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
        require(!isIcoFinished());
        rate = _rate;        
    }

    function setPauseEmergence() public onlyOwner {        
        pauseEmergence = true;
    }

    function setUnPauseEmergence() public onlyOwner {        
        pauseEmergence = false;
    }

    function isIcoFinished() public constant returns (bool icoFinished) {
        return (totalRaised >= icoEtherMinCap && icoEndTimestamp != 0 && now > icoEndTimestamp) || (totalRaised >= icoEtherMaxCap);
    }

    function sendTokenTeam(address _to, uint256 amount) public onlyOwner returns (bool sendTokenTeam) {
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