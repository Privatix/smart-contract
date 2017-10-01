# Sale

Source file [../../contracts/Sale.sol](../../contracts/Sale.sol).

<br />

<hr />

```javascript
// BK Ok - Consider updating to a recent version
pragma solidity ^0.4.13;

// BK Ok - Carefully check for new commits between testing and mainnet deployment
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
// BK Next 2 Ok
import './Token.sol';
import './MultiOwners.sol';


// BK Ok
contract Sale is MultiOwners {
    // BK Ok
    using SafeMath for uint256;

    // Minimal possible cap in ethers
    // BK Ok
    uint256 public softCap;

    // Maximum possible cap in ethers
    // BK Ok
    uint256 public hardCap;

    // totalEthers received
    // BK Ok
    uint256 public totalEthers;

    // Ssale token
    // BK Ok
    Token public token;

    // Withdraw wallet
    // BK Ok
    address public wallet;

    // Maximum available to sell tokens
    // BK Ok
    uint256 public maximumTokens;

    // Minimal ether
    // BK Ok
    uint256 public minimalEther;

    // Token per ether
    // BK Ok
    uint256 public weiPerToken;

    // start and end timestamp where investments are allowed (both inclusive)
    // BK Next 2 Ok
    uint256 public startTime;
    uint256 public endTime;

    // refund if softCap is not reached
    // BK Ok
    bool public refundAllowed;

    // 
    // BK Ok
    mapping(address => uint256) public etherBalances;

    // 
    // BK Ok
    mapping(address => uint256) public whitelist;

    // bounty tokens
    // BK Ok
    uint256 public bountyAvailable;

    // team tokens
    // BK Ok
    uint256 public teamAvailable;

    // founder tokens
    // BK Ok
    uint256 public founderAvailable;

    // softcap reached flag
    // BK Ok
    bool public softCapReached;


    // BK Ok
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    // BK Ok
    modifier validPurchase() {
        // BK Ok
        bool withinPeriod = (now >= startTime && now <= endTime);
        // BK Ok
        bool nonZeroPurchase = msg.value != 0;

        // BK Ok
        require(withinPeriod && nonZeroPurchase);

        // BK Ok
        _;        
    }

    // BK Ok - Not used
    modifier isStarted() {
        // BK Ok
        require(now >= startTime);

        // BK Ok
        _;        
    }

    // BK Ok
    modifier isExpired() {
        // BK Ok
        require(now > endTime);

        // BK Ok
        _;        
    }

    // BK Ok - Constructor
    function Sale(uint256 _startTime, address _wallet) {
        // BK Ok
        require(_startTime >=  now);
        // BK Ok
        require(_wallet != 0x0);

        // BK Ok
        token = new Token();

        // BK Ok
        wallet = _wallet;
        // BK Ok
        startTime = _startTime;

        // BK Next 5 Ok
        minimalEther = 1e16; // 0.01 ether
        endTime = _startTime + 28 days;
        weiPerToken = 1e18 / 100e8; // token price
        hardCap = 57142e18;
        softCap = 3350e18;

    
        // We love our Pre-ITO backers
        // BK Next block Ok
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

        // BK Ok
        maximumTokens = token.totalSupply() + 8000000e8;

        // Also we like KYC
        // BK Ok
        whitelist[0x38C0fC6F24013ED3F7887C05f95d17A8883be4bA] = 100e18;
    }

    /*
     * @dev fallback for processing ether
     */
    // BK Ok
    function() payable {
        // BK Ok
        return buyTokens(msg.sender);
    }

    /*
     * @dev calculate amount
     * @return token amount that we should send to our dear investor
     */
    // BK NOTE - Only for testing this function:
    // BK NOTE - * can be marked as constant
    // BK NOTE - * can be marked as public
    // BK NOTE - * rename to `calcAmountAt(...)`, add `uint256 at`, replace `now` below with `at`, and when calling, call as 
    // BK NOTE -   `calcAmountAt(msg.value, block.timestamp)`, then can test the time parameter
    function calcAmount(uint256 _value) internal returns (uint256) {
        // BK Ok
        uint rate;

        // BK Next block Ok
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
        // BK Ok
        return ((_value * rate) / weiPerToken) / 100;
    }

    // BK NOTE - Consider adding a parameter `uint256 amount` and calling as `checkWhitelist(contributor, msg.value)`
    // BK Ok
    function checkWhitelist(address contributor) internal returns (bool) {
        // BK Ok
        if(startTime + 1 days < now) {
            // BK Ok
            return true;
        }
        // BK Ok
        return etherBalances[contributor] + msg.value <= whitelist[contributor];
    }


    /*
     * @dev grant backer until first 24 hours
     * @param contributor address
     */
    // BK Ok
    function addWhitelist(address contributor, uint256 amount) onlyOwner returns (bool) {
        // BK Ok
        whitelist[contributor] = amount;
        // BK Ok
        return true;
    }


    /*
     * @dev sell token and send to contributor address
     * @param contributor address
     */
    // BK Ok
    function buyTokens(address contributor) payable validPurchase {
        // BK Ok
        uint256 amount = calcAmount(msg.value);
        // BK Ok
        uint256 ethers = msg.value;

        // BK Ok
        require(checkWhitelist(contributor));
        // BK Ok - The following check should be before the `checkWhitelist(contributor)` check
        require(contributor != 0x0) ;
        // BK Ok
        require(minimalEther <= msg.value);
        // BK Ok
        require(totalEthers + ethers <= hardCap);
        // BK Ok
        require(token.totalSupply() + amount <= maximumTokens);

        // BK Ok
        token.mint(contributor, amount);
        // BK Ok
        TokenPurchase(0x0, contributor, msg.value, amount);

        // BK NOTE - `totalEthers` should be made more consistent
        // BK Ok
        if(!softCapReached) {
            // BK NOTE - Keeping track of contributions if soft cap not reached
            // BK Ok
            etherBalances[contributor] = etherBalances[contributor] + ethers;
        // BK Ok
        } else {
            // BK Ok
            totalEthers = totalEthers + ethers;
        }
    }

    // @withdraw to wallet
    // BK Ok
    function withdraw() public {
        // BK Ok
        require(softCapReached);
        // BK Ok
        require(this.balance > 0);

        // BK Ok
        wallet.transfer(this.balance);
    }

    // @withdraw token to wallet
    // BK NOTE - Only can only withdraw tokens after 1 year
    // BK Ok
    function withdrawTokenToFounder() public {
        // BK Ok
        require(token.balanceOf(this) > 0);
        // BK Ok
        require(softCapReached);
        // BK Ok
        require(startTime + 1 years < now);

        // BK Ok
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
```
