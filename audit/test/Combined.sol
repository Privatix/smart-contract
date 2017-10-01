pragma solidity ^0.4.16;



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}



/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}






/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}







/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}







/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}








/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(0x0, _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}



contract MultiOwners {

    event AccessGrant(address indexed owner);
    event AccessRevoke(address indexed owner);
    
    mapping(address => bool) owners;

    function MultiOwners() {
        owners[msg.sender] = true;
    }

    modifier onlyOwner() { 
        require(owners[msg.sender] == true);
        _; 
    }

    function isOwner() constant returns (bool) {
        return owners[msg.sender] ? true : false;
    }

    function checkOwner(address maybe_owner) constant returns (bool) {
        return owners[maybe_owner] ? true : false;
    }


    function grant(address _owner) onlyOwner {
        owners[_owner] = true;
        AccessGrant(_owner);
    }

    function revoke(address _owner) onlyOwner {
        require(msg.sender != _owner);
        owners[_owner] = false;
        AccessRevoke(_owner);
    }
}





contract Token is MintableToken {

    string public constant name = 'Privatix';
    string public constant symbol = 'PRIX';
    uint8 public constant decimals = 8;
    bool public transferAllowed;

    event Burn(address indexed from, uint256 value);
    event TransferAllowed(bool);

    modifier canTransfer() {
        require(mintingFinished && transferAllowed);
        _;        
    }
    
    function transferFrom(address from, address to, uint256 value) canTransfer returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function transfer(address to, uint256 value) canTransfer returns (bool) {
        return super.transfer(to, value);
    }

    function finishMinting(bool _transferAllowed) onlyOwner returns (bool) {
        transferAllowed = _transferAllowed;
        TransferAllowed(_transferAllowed);
        return super.finishMinting();
    }

    function burn(address from) onlyOwner returns (bool) {
        Transfer(from, 0x0, balances[from]);
        Burn(from, balances[from]);

        balances[0x0] += balances[from];
        balances[from] = 0;
    }

    function mint(address contributor, uint256 amount) onlyOwner canMint returns (bool) {
        Transfer(0x0, contributor, amount);
        return super.mint(contributor, amount);
    }
}







contract Sale is MultiOwners {
    using SafeMath for uint256;

    // Minimal possible cap in ethers
    uint256 public softCap;

    // Maximum possible cap in ethers
    uint256 public hardCap;

    // totalEthers received
    uint256 public totalEthers;

    // Ssale token
    Token public token;

    // Withdraw wallet
    address public wallet;

    // Maximum available to sell tokens
    uint256 public maximumTokens;

    // Minimal ether
    uint256 public minimalEther;

    // Token per ether
    uint256 public weiPerToken;

    // start and end timestamp where investments are allowed (both inclusive)
    uint256 public startTime;
    uint256 public endTime;

    // refund if softCap is not reached
    bool public refundAllowed;

    // 
    mapping(address => uint256) public etherBalances;

    // 
    mapping(address => uint256) public whitelist;

    // bounty tokens
    uint256 public bountyAvailable;

    // team tokens
    uint256 public teamAvailable;

    // founder tokens
    uint256 public founderAvailable;

    // softcap reached flag
    bool public softCapReached;


    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    modifier validPurchase() {
        bool withinPeriod = (now >= startTime && now <= endTime);
        bool nonZeroPurchase = msg.value != 0;

        require(withinPeriod && nonZeroPurchase);

        _;        
    }

    modifier isStarted() {
        require(now >= startTime);

        _;        
    }

    modifier isExpired() {
        require(now > endTime);

        _;        
    }

    function Sale(uint256 _startTime, address _wallet) {
        require(_startTime >=  now);
        require(_wallet != 0x0);

        token = new Token();

        wallet = _wallet;
        startTime = _startTime;

        minimalEther = 1e16; // 0.01 ether
        endTime = _startTime + 28 days;
        weiPerToken = 1e18 / 100e8; // token price
        hardCap = 57142e18;
        softCap = 3350e18;

    
        // We love our Pre-ITO backers
        token.mint(0x992066a964C241eD4996E750284d039B14A19fA5, 11199999999860);
        token.mint(0x1F4df63B8d32e54d94141EF8475c55dF4db2a02D, 9333333333170);
        token.mint(0xce192Be11DdE37630Ef842E3aF5fBD7bEA15C6f9, 2799999999930);
        token.mint(0x18D2AD9DFC0BA35E124E105E268ebC224323694a, 1120000000000);
        token.mint(0x4eD1db98a562594CbD42161354746eAafD1F9C44, 933333333310);
        token.mint(0x00FEbfc7be373f8088182850FeCA034DDA8b7a67, 896000000000);
        token.mint(0x86850f5f7D035dD96B07A75c484D520cff13eb58, 634666666620);
        token.mint(0x08750DA30e952B6ef3D034172904ca7Ec1ab133A, 616000000000);
        token.mint(0x4B61eDe41e7C8034d6bdF1741cA94910993798aa, 578666666620);
        token.mint(0xdcb018EAD6a94843ef2391b3358294020791450b, 560000000000);
        token.mint(0xb62E27446079c2F2575C79274cd905Bf1E1e4eDb, 560000000000);
        token.mint(0xFF37732a268a2ED27627c14c45f100b87E17fFDa, 560000000000);
        token.mint(0x7bDeD0D5B6e2F9a44f59752Af633e4D1ed200392, 80000000000);
        token.mint(0x995516bb1458fa7b192Bb4Bab0635Fc9Ab447FD1, 48000000000);
        token.mint(0x95a7BEf91A5512d954c721ccbd6fC5402667FaDe, 32000000000);
        token.mint(0x3E10553fff3a5Ac28B9A7e7f4afaFB4C1D6Efc0b, 24000000000);
        token.mint(0x7C8E7d9BE868673a1bfE0686742aCcb6EaFFEF6F, 17600000000);

        maximumTokens = token.totalSupply() + 8000000e8;

        // Also we like KYC
        whitelist[0x38C0fC6F24013ED3F7887C05f95d17A8883be4bA] = 100e18;
    }

    /*
     * @dev fallback for processing ether
     */
    function() payable {
        return buyTokens(msg.sender);
    }

    /*
     * @dev calculate amount
     * @return token amount that we should send to our dear investor
     */
    function calcAmount(uint256 _value) internal returns (uint256) {
        uint rate;

        if(startTime + 2 days >= now) {
            rate = 140;
        } else if(startTime + 7 days >= now) {
            rate = 130;
        } else if(startTime + 14 days >= now) {
            rate = 120;
        } else if(startTime + 21 days >= now) {
            rate = 110;
        } else {
            rate = 105;
        }
        return ((_value * rate) / weiPerToken) / 100;
    }

    function checkWhitelist(address contributor) internal returns (bool) {
        if(startTime + 1 days < now) {
            return true;
        }
        return etherBalances[contributor] + msg.value <= whitelist[contributor];
    }


    /*
     * @dev grant backer until first 24 hours
     * @param contributor address
     */
    function addWhitelist(address contributor, uint256 amount) onlyOwner returns (bool) {
        whitelist[contributor] = amount;
        return true;
    }


    /*
     * @dev sell token and send to contributor address
     * @param contributor address
     */
    function buyTokens(address contributor) payable validPurchase {
        uint256 amount = calcAmount(msg.value);
        uint256 ethers = msg.value;

        require(checkWhitelist(contributor));
        require(contributor != 0x0) ;
        require(minimalEther <= msg.value);
        require(totalEthers + ethers <= hardCap);
        require(token.totalSupply() + amount <= maximumTokens);

        token.mint(contributor, amount);
        TokenPurchase(0x0, contributor, msg.value, amount);

        if(!softCapReached) {
            etherBalances[contributor] = etherBalances[contributor] + ethers;
        } else {
            totalEthers = totalEthers + ethers;
        }
    }

    // @withdraw to wallet
    function withdraw() public {
        require(softCapReached);
        require(this.balance > 0);

        wallet.transfer(this.balance);
    }

    // @withdraw token to wallet
    function withdrawTokenToFounder() public {
        require(token.balanceOf(this) > 0);
        require(softCapReached);
        require(startTime + 1 years < now);

        token.transfer(wallet, token.balanceOf(this));
    }

    // @refund to backers, if softCap is not reached
    function refund() isExpired public {
        require(refundAllowed);
        require(!softCapReached);
        require(etherBalances[msg.sender] > 0);
        require(token.balanceOf(msg.sender) > 0);
 
        msg.sender.transfer(etherBalances[msg.sender]);
        token.burn(msg.sender);
        etherBalances[msg.sender] = 0;
    }

    function hardCapReached() internal returns (bool) {
        return ((hardCap * 999) / 1000) <= totalEthers;
    }

    // update status (set softCapReached, make available to withdraw ethers to wallet)
    function updateStatus() public {
        // Allow to update only when whitelist stage sale is ended
        require(startTime + 1 days < now);

        if(!softCapReached && this.balance >= softCap) {
            softCapReached = true;
            totalEthers = this.balance;
        }

        if(softCapReached) {        
            bountyAvailable = token.totalSupply() * 3 / 83;
            teamAvailable = token.totalSupply() * 7 / 83;
            founderAvailable = token.totalSupply() * 7 / 83;
        }
    }

    function finishCrowdsale() public {
        updateStatus();

        require(now > endTime || hardCapReached());
        require(!token.mintingFinished());


        if(softCapReached) {
            token.mint(wallet, bountyAvailable);
            token.mint(wallet, teamAvailable);
            token.mint(this, founderAvailable);

            founderAvailable = teamAvailable = bountyAvailable = 0;
            token.finishMinting(true);
        } else {
            refundAllowed = true;
            token.finishMinting(false);
        }
   }

    // @return true if crowdsale event has ended
    function running() public constant returns (bool) {
        return now >= startTime && !(now > endTime || hardCapReached());
    }
}