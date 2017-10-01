# Privatix Crowdsale Contract Audit

[https://privatix.io/](https://privatix.io/).

Commits
[c2f6d3d](https://github.com/Privatix/smart-contract/commit/c2f6d3d88f66eeb3f1c88cb76550e9a93ae387fc),
[58152e4](https://github.com/Privatix/smart-contract/commit/58152e4759a61c86448008376345aa72bc3cd4c6),
[609c861](https://github.com/Privatix/smart-contract/commit/609c86107087823ffd678bcc1fcebba917f79a51) and
[ce37920](https://github.com/Privatix/smart-contract/commit/ce37920852e289ba26543bc9316075c9a66cdad7).

<br />

<hr />

## Summary

<br />

<hr />

## Table Of Contents

* [Summary](#summary)
* [Recommendations](#recommendations)
  * [First Review Recommendations](#first-review-recommendations)
  * [Second Review Recommendations](#second-review-recommendations)
  * [Third Review Recommendations](#third-review-recommendations)
* [Risks](#risks)
* [Testing](#testing)
  * [Test 1](#test-1)
* [Code Review](#code-review)

<br />

<hr />

## Recommendations

### First Review Recommendations

* **LOW IMPORTANCE** The event `Transfer(...)` in *Token* is a duplicate of `Transfer(...)` in *ERC20Basic* and should be removed
  * [x] Removed in [58152e4](https://github.com/Privatix/smart-contract/commit/58152e4759a61c86448008376345aa72bc3cd4c6)
* **MEDIUM IMPORTANCE** What is the `burn(...)` function for? It breaks the trustlessness of the token contract as the owner can destroy any
  account's token balance. The reply from the developer is that `burn(...)` is only for use by `Sale.refund(...)`.
  
  Replace `function burn(address from) onlyOwner returns (bool) {` with `function burn(address from) internal returns (bool) {` and this
  prevents the contract owner from directly executing the `burn(...)` function, but allows `Sale.refund(...)` to burn refunded tokens
  
  * [x] The developer has brought to my attention that the owner of the *Token* contract is the *Sale* contract, not the crowdsale contract
    owner, so this is not an issue. Also, the `internal` keyword change will prevent this function from working correctly, as the call
    is across contracts from *Sale* to *Token*
* **LOW IMPORTANCE** *Token* has the following statements `StandardToken.transferFrom(from, to, value);`, `BasicToken.transfer(to, value);`,
  `MintableToken.finishMinting();` and `MintableToken.mint(contributor, amount);`. Consider replacing these with
  `super.transferFrom(from, to, value);`, `super.transfer(to, value);`, `super.finishMinting();` and `super.mint(contributor, amount);` as any
  intermediate contract functions may be bypassed
  * [x] Updated in [58152e4](https://github.com/Privatix/smart-contract/commit/58152e4759a61c86448008376345aa72bc3cd4c6)
* **LOW IMPORTANCE** The expression `((hardCap / 1000) * 999)` in *Sale* should be rewritten as `((hardCap * 999) / 1000)` for more precision
  in the calculated result. See the following sample calculation

      pragma solidity ^0.4.16;

      contract Test {
          uint public hardCap = 57142e18;
          uint public calc1;
          uint public calc2;
    
          function Test() public {
              // Result 57142000000000000000000
              calc1 = ((hardCap / 1000) * 999);
              // Result 57084858000000000000000
              calc2 = hardCap * 999 / 1000;
          }
      }

  * [x] Fixed in [58152e4](https://github.com/Privatix/smart-contract/commit/58152e4759a61c86448008376345aa72bc3cd4c6)
* **MEDIUM IMPORTANCE** *Sale* and *Token* depend on the OpenZeppelin libraries, and the latest version of the OpenZeppelin libraries will
  be used when compiling the *Sale* and *Token* contracts for deployment. There are frequent changes to this library (last set of changes
  5d, 7d, 7d, 8d, 9d, 11d, 12d, 15d, 16d, ... ago). There is a risk that you may compile in partially tested changes. Consider hand-assembling
  the combined source code with a particular OpenZeppelin commit, testing with this version, and checking for further bug fix commits before
  deployment to mainnet. Or note what OpenZeppelin commit you are testing with, and review all new changes in OpenZeppelin before deployment
  to mainnet
  * [x] Developer has been made aware of this
* **LOW IMPORTANCE** In `Sale.updateStatus()` the bounty, team and founders allocations are calculated as 3%, 7% and 7% respectively. Say the
  totalSupply is 100, bounty%=3, team%=7, founders%=7. totalSupply after allocation is 100+3+7+7=117. bounty=3/117=2.56%, team=founders=7/117=
  5.98%. Is this 2.56%, 5.98% and 5.98% the intended distribution?
  * [x] Developer has updated the code in [58152e4](https://github.com/Privatix/smart-contract/commit/58152e4759a61c86448008376345aa72bc3cd4c6)
  * [ ] BK to confirm the calculations are correct
* **LOW IMPORTANCE** In `Sale.updateStatus()`, rewrite the expressions for the bounty, team and founders allocation calculations for more 
  precision. e.g. `bountyAvailable = token.totalSupply() / 100 * 3;` should be `bountyAvailable = (token.totalSupply() * 3) / 100;`.
  Multiplication before division
  * [x] Fixed in [58152e4](https://github.com/Privatix/smart-contract/commit/58152e4759a61c86448008376345aa72bc3cd4c6)
* **LOW IMPORTANCE** In *MultiOwners*, consider logging events when new owners are granted access, and existing owners are revoked access
  * [x] Added in [58152e4](https://github.com/Privatix/smart-contract/commit/58152e4759a61c86448008376345aa72bc3cd4c6)
* **LOW IMPORTANCE** As stated in the [ERC20 Token Standard](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md#decimals),
  `decimals` should be defined as `uint8`
  * [x] Fixed in [58152e4](https://github.com/Privatix/smart-contract/commit/58152e4759a61c86448008376345aa72bc3cd4c6)
* **LOW IMPORTANCE** In *Token*, consider adding `bool _transferAllowed` to the `TransferAllowed(...)` event, removing the `if(...)` condition in
  `finishMinting(...)`, and logging the `_transferAllowed` value
  * [x] Updated in [58152e4](https://github.com/Privatix/smart-contract/commit/58152e4759a61c86448008376345aa72bc3cd4c6)
* **LOW IMPORTANCE** In *Token*, `mint(...)` can be called by anyone, but `MintableToken.mint(...)` will only allow the owner to execute
  `Token.mint(...)`. Just a small suggestion to add `onlyOwner` to `Token.mint(...)` to explicitly inform the readers of the source code
  that only the owner can execute this function
  * [x] Updated in [58152e4](https://github.com/Privatix/smart-contract/commit/58152e4759a61c86448008376345aa72bc3cd4c6)

<br />

### Second Review Recommendations

* **LOW IMPORTANCE** Consider updating the Solidity version number from `^0.4.11` and `^0.4.13` to a recent version
  * [x] Updated to `^0.4.15` in [ce37920](https://github.com/Privatix/smart-contract/commit/ce37920852e289ba26543bc9316075c9a66cdad7)
* **LOW IMPORTANCE** The modifier `Sale.isStarted()` is not used. Consider removing this modifier
* **LOW IMPORTANCE** In `Sale.calcAmount(...)`, rewrite `return ((_value / weiPerToken) / 100) * rate;` as
  `return (_value * rate / weiPerToken) / 100;` for better precision
  * [x] Fixed in [609c861](https://github.com/Privatix/smart-contract/commit/609c86107087823ffd678bcc1fcebba917f79a51) 
* **LOW IMPORTANCE** Two `Transfer(0x0, ...)` events are logged for each minting event. `Token.mint(...)` emits one `Transfer(0x0, ...)` event and
  then calls `MintableToken.mint(...)` that also emits one `Transfer(0x0, ...)` event. `Token.mint(...)` can probably be removed as it does not
  add any functionality over `MintableToken.mint(...)`

      Mint 0 #229 {"amount":"11199999999860","to":"0x992066a964c241ed4996e750284d039b14a19fa5"}
      Mint 1 #229 {"amount":"9333333333170","to":"0x1f4df63b8d32e54d94141ef8475c55df4db2a02d"}
      ...
      Transfer 0 #229: from=0x0000000000000000000000000000000000000000 to=0x992066a964c241ed4996e750284d039b14a19fa5 value=111999.9999986
      Transfer 1 #229: from=0x0000000000000000000000000000000000000000 to=0x992066a964c241ed4996e750284d039b14a19fa5 value=111999.9999986
      Transfer 2 #229: from=0x0000000000000000000000000000000000000000 to=0x1f4df63b8d32e54d94141ef8475c55df4db2a02d value=93333.3333317
      Transfer 3 #229: from=0x0000000000000000000000000000000000000000 to=0x1f4df63b8d32e54d94141ef8475c55df4db2a02d value=93333.3333317
      ...

  * [ ] Fixed in [ce37920](https://github.com/Privatix/smart-contract/commit/ce37920852e289ba26543bc9316075c9a66cdad7)

<br />

### Third Review Recommendations

* **MEDIUM IMPORTANCE** While the crowdsale contract can be made as safe as possible, it it still a bespoke contract with little testing compared
  to the hardware wallets or multisig wallets. For this reason, the risk of ETH being stolen or stuck in this contract can be reduced by
  immediately transferring all ETH contributions to the crowdsale wallet. As there is a `softCap` where refunds will be available to 
  participants if the `softCap` is not reached, store the ETH in the crowdsale contract until the `softCap` is reached. After this, transfer
  all ETH balances immediately to the crowdsale wallet using `wallet.transfer(eth.balance);`.
  
  For this to occur, the calculation of `softCapReached` will need to be moved into `buyTokens(...)`. And a few other changes need to be made.

<br />

<hr />

## Risks

<br />

<hr />

## Testing

Note that this testing uses the OpenZeppelin library commit 
[5cf5036](https://github.com/OpenZeppelin/zeppelin-solidity/commit/5cf503673faea92c1b5c615c3f8358febf06e160).

<br />

### Test 1

The following functions were tested using the script [test/01_test1.sh](test/01_test1.sh) with the summary results saved
in [test/test1results.txt](test/test1results.txt) and the detailed output saved in [test/test1output.txt](test/test1output.txt):

* [x] Deploy *Sale* contract
* [x] Add whitelisted addresses
* [x] Send contribution before start - expecting failure
* [x] Send contribution after start - success for whitelisted account, failure for non-whitelisted account
* [x] Send contribution after whitelist period over - success for whitelisted and non-whitelisted account
* [x] Send contribution to hard cap
* [x] Attempt transfers - failure
* [x] Finish crowdsale
* [x] Move crowdsale funds to wallet
* [x] Transfer tokens
* [x] Withdraw tokens to founder after long wait period

<br />

### Test 2

The following functions were tested using the script [test/02_test2.sh](test/02_test2.sh) with the summary results saved
in [test/test2results.txt](test/test2results.txt) and the detailed output saved in [test/test2output.txt](test/test2output.txt):

* [x] Deploy *Sale* contract
* [x] Add whitelisted addresses
* [x] Send small contribution after whitelist period over
* [x] Finish crowdsale
* [x] Move crowdsale funds and tokens to wallet - expecting failure
* [x] Withdraw refunds

<br />

<hr />

## Code Review

* [x] [code-review/MultiOwners.md](code-review/MultiOwners.md)
  * [x] contract MultiOwners 
* [ ] [code-review/Sale.md](code-review/Sale.md)
  * [ ] contract Sale is MultiOwners 
* [x] [code-review/Token.md](code-review/Token.md)
  * [x] contract Token is MintableToken 


<br />

### OpenZeppelin Code Review

From [OpenZeppelin Solidity contracts](https://github.com/OpenZeppelin/zeppelin-solidity/tree/master/contracts).

Commit [5cf5036](https://github.com/OpenZeppelin/zeppelin-solidity/commit/5cf503673faea92c1b5c615c3f8358febf06e160).

* [ ] [openzeppelin-code-review/math/SafeMath.md](openzeppelin-code-review/math/SafeMath.md)
  * [ ] library SafeMath
* [ ] [openzeppelin-code-review/ownership/Ownable.md](openzeppelin-code-review/ownership/Ownable.md)
  * [ ] contract Ownable
* [ ] [openzeppelin-code-review/token/ERC20Basic.md](openzeppelin-code-review/token/ERC20Basic.md)
  * [ ] contract ERC20Basic 
* [ ] [openzeppelin-code-review/token/ERC20.md](openzeppelin-code-review/token/ERC20.md)
  * [ ] contract ERC20 is ERC20Basic 
* [ ] [openzeppelin-code-review/token/BasicToken.md](openzeppelin-code-review/token/BasicToken.md)
  * [ ] contract BasicToken is ERC20Basic 
* [ ] [openzeppelin-code-review/token/StandardToken.md](openzeppelin-code-review/token/StandardToken.md)
  * [ ] contract StandardToken is ERC20, BasicToken 
* [ ] [openzeppelin-code-review/token/MintableToken.md](openzeppelin-code-review/token/MintableToken.md)
  * [ ] contract MintableToken is StandardToken, Ownable 

<br />

### Code Not Reviewed

The following contracts are for the Presale funding that is now completed:

* [ ] [../contracts/Presale.sol](../contracts/Presale.sol)
  * [ ] contract Presale 
* [ ] [../contracts/PresaleToken.sol](../contracts/PresaleToken.sol)
  * [ ] contract PresaleToken is MintableToken 

The following contracts are for testing and the testing framework:

* [ ] [../contracts/Migrations.sol](../contracts/Migrations.sol)
  * [ ] contract Migrations 

