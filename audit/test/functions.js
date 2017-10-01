// Jun 12 2017
var ethPriceUSD = 380.39;

// -----------------------------------------------------------------------------
// Accounts
// -----------------------------------------------------------------------------
var accounts = [];
var accountNames = {};

addAccount(eth.accounts[0], "Account #0 - Miner");
addAccount(eth.accounts[1], "Account #1 - Contract Owner");
addAccount(eth.accounts[2], "Account #2 - Wallet");
addAccount(eth.accounts[3], "Account #3 - Whitelisted");
addAccount(eth.accounts[4], "Account #4 - Not Whitelisted");
addAccount(eth.accounts[5], "Account #5");
addAccount(eth.accounts[6], "Account #6");
addAccount(eth.accounts[7], "Account #7");
// addAccount(eth.accounts[8], "Account #8");
// addAccount(eth.accounts[9], "Account #9");
// addAccount(eth.accounts[10], "Account #10");
addAccount("0x992066a964C241eD4996E750284d039B14A19fA5", "Test 01");
addAccount("0x1F4df63B8d32e54d94141EF8475c55dF4db2a02D", "Test 02");
addAccount("0xce192Be11DdE37630Ef842E3aF5fBD7bEA15C6f9", "Test 03");
addAccount("0x18D2AD9DFC0BA35E124E105E268ebC224323694a", "Test 04");
addAccount("0x4eD1db98a562594CbD42161354746eAafD1F9C44", "Test 05");
addAccount("0x00FEbfc7be373f8088182850FeCA034DDA8b7a67", "Test 06");
addAccount("0x86850f5f7D035dD96B07A75c484D520cff13eb58", "Test 07");
addAccount("0x08750DA30e952B6ef3D034172904ca7Ec1ab133A", "Test 08");
addAccount("0x4B61eDe41e7C8034d6bdF1741cA94910993798aa", "Test 09");
addAccount("0xdcb018EAD6a94843ef2391b3358294020791450b", "Test 10");
addAccount("0xb62E27446079c2F2575C79274cd905Bf1E1e4eDb", "Test 11");
addAccount("0xFF37732a268a2ED27627c14c45f100b87E17fFDa", "Test 12");
addAccount("0x7bDeD0D5B6e2F9a44f59752Af633e4D1ed200392", "Test 13");
addAccount("0x995516bb1458fa7b192Bb4Bab0635Fc9Ab447FD1", "Test 14");
addAccount("0x95a7BEf91A5512d954c721ccbd6fC5402667FaDe", "Test 15");
addAccount("0x3E10553fff3a5Ac28B9A7e7f4afaFB4C1D6Efc0b", "Test 16");
addAccount("0x7C8E7d9BE868673a1bfE0686742aCcb6EaFFEF6F", "Test 17");

var minerAccount = eth.accounts[0];
var contractOwnerAccount = eth.accounts[1];
var wallet = eth.accounts[2];
var account3 = eth.accounts[3];
var account4 = eth.accounts[4];
var account5 = eth.accounts[5];
var account6 = eth.accounts[6];
var account7 = eth.accounts[7];
// var account8 = eth.accounts[8];
// var account9 = eth.accounts[9];
// var account10 = eth.accounts[10];

var baseBlock = eth.blockNumber;

function unlockAccounts(password) {
  for (var i = 0; i < eth.accounts.length; i++) {
    personal.unlockAccount(eth.accounts[i], password, 100000);
  }
}

function addAccount(account, accountName) {
  accounts.push(account);
  accountNames[account] = accountName;
}


// -----------------------------------------------------------------------------
// Token Contract
// -----------------------------------------------------------------------------
var tokenContractAddress = null;
var tokenContractAbi = null;

function addTokenContractAddressAndAbi(address, tokenAbi) {
  tokenContractAddress = address;
  tokenContractAbi = tokenAbi;
}


// -----------------------------------------------------------------------------
// Account ETH and token balances
// -----------------------------------------------------------------------------
function printBalances() {
  var token = tokenContractAddress == null || tokenContractAbi == null ? null : web3.eth.contract(tokenContractAbi).at(tokenContractAddress);
  var decimals = token == null ? 8 : token.decimals();
  var i = 0;
  var totalTokenBalance = new BigNumber(0);
  console.log("RESULT:  # Account                                             EtherBalanceChange                Token Name");
  console.log("RESULT: -- ------------------------------------------ --------------------------- -------------------- ---------------------------");
  accounts.forEach(function(e) {
    var etherBalanceBaseBlock = eth.getBalance(e, baseBlock);
    var etherBalance = web3.fromWei(eth.getBalance(e).minus(etherBalanceBaseBlock), "ether");
    var tokenBalance = token == null ? new BigNumber(0) : token.balanceOf(e).shift(-decimals);
    totalTokenBalance = totalTokenBalance.add(tokenBalance);
    console.log("RESULT: " + pad2(i) + " " + e  + " " + pad(etherBalance) + " " + padToken(tokenBalance, decimals) + " " + accountNames[e]);
    i++;
  });
  console.log("RESULT: -- ------------------------------------------ --------------------------- -------------------- ---------------------------");
  console.log("RESULT:                                                                           " + padToken(totalTokenBalance, decimals) + " Total Token Balances");
  console.log("RESULT: -- ------------------------------------------ --------------------------- -------------------- ---------------------------");
  console.log("RESULT: ");
}

function pad2(s) {
  var o = s.toFixed(0);
  while (o.length < 2) {
    o = " " + o;
  }
  return o;
}

function pad(s) {
  var o = s.toFixed(18);
  while (o.length < 27) {
    o = " " + o;
  }
  return o;
}

function padToken(s, decimals) {
  var o = s.toFixed(decimals);
  var l = parseInt(decimals)+12;
  while (o.length < l) {
    o = " " + o;
  }
  return o;
}


// -----------------------------------------------------------------------------
// Transaction status
// -----------------------------------------------------------------------------
function printTxData(name, txId) {
  var tx = eth.getTransaction(txId);
  var txReceipt = eth.getTransactionReceipt(txId);
  var gasPrice = tx.gasPrice;
  var gasCostETH = tx.gasPrice.mul(txReceipt.gasUsed).div(1e18);
  var gasCostUSD = gasCostETH.mul(ethPriceUSD);
  console.log("RESULT: " + name + " gas=" + tx.gas + " gasUsed=" + txReceipt.gasUsed + " costETH=" + gasCostETH +
    " costUSD=" + gasCostUSD + " @ ETH/USD=" + ethPriceUSD + " gasPrice=" + gasPrice + " block=" + 
    txReceipt.blockNumber + " txIx=" + tx.transactionIndex + " txId=" + txId);
}

function assertEtherBalance(account, expectedBalance) {
  var etherBalance = web3.fromWei(eth.getBalance(account), "ether");
  if (etherBalance == expectedBalance) {
    console.log("RESULT: OK " + account + " has expected balance " + expectedBalance);
  } else {
    console.log("RESULT: FAILURE " + account + " has balance " + etherBalance + " <> expected " + expectedBalance);
  }
}

function gasEqualsGasUsed(tx) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  return (gas == gasUsed);
}

function failIfGasEqualsGasUsed(tx, msg) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  if (gas == gasUsed) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    console.log("RESULT: PASS " + msg);
    return 1;
  }
}

function passIfGasEqualsGasUsed(tx, msg) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  if (gas == gasUsed) {
    console.log("RESULT: PASS " + msg);
    return 1;
  } else {
    console.log("RESULT: FAIL " + msg);
    return 0;
  }
}

function failIfGasEqualsGasUsedOrContractAddressNull(contractAddress, tx, msg) {
  if (contractAddress == null) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    var gas = eth.getTransaction(tx).gas;
    var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
    if (gas == gasUsed) {
      console.log("RESULT: FAIL " + msg);
      return 0;
    } else {
      console.log("RESULT: PASS " + msg);
      return 1;
    }
  }
}


function addCrowdsaleContractAddressAndAbi(address, abi) {
  crowdsaleContractAddress = address;
  crowdsaleContractAbi = abi;
}

var crowdsaleFromBlock = 0;
function printCrowdsaleContractDetails() {
  console.log("RESULT: crowdsaleContractAddress=" + crowdsaleContractAddress);
  // console.log("RESULT: crowdsaleContractAbi=" + JSON.stringify(crowdsaleContractAbi));
  if (crowdsaleContractAddress != null && crowdsaleContractAbi != null) {
    var contract = eth.contract(crowdsaleContractAbi).at(crowdsaleContractAddress);
    console.log("RESULT: crowdsale.softCap=" + contract.softCap() + " " + contract.softCap().shift(-18));
    console.log("RESULT: crowdsale.hardCap=" + contract.hardCap() + " " + contract.hardCap().shift(-18));
    console.log("RESULT: crowdsale.token=" + contract.token());
    console.log("RESULT: crowdsale.wallet=" + contract.wallet());
    console.log("RESULT: crowdsale.maximumTokens=" + contract.maximumTokens() + " " + contract.maximumTokens().shift(-8));
    console.log("RESULT: crowdsale.minimalEther=" + contract.minimalEther() + " " + contract.minimalEther().shift(-18));
    console.log("RESULT: crowdsale.weiPerToken=" + contract.weiPerToken() + " " + contract.weiPerToken().shift(-18));
    console.log("RESULT: crowdsale.startTime=" + contract.startTime() + " " + new Date(contract.startTime() * 1000).toUTCString());
    console.log("RESULT: crowdsale.endTime=" + contract.endTime() + " " + new Date(contract.endTime() * 1000).toUTCString());
    console.log("RESULT: crowdsale.refundAllowed=" + contract.refundAllowed());
    console.log("RESULT: crowdsale.bountyAvailable=" + contract.bountyAvailable() + " " + contract.bountyAvailable().shift(-8));
    console.log("RESULT: crowdsale.teamAvailable=" + contract.teamAvailable() + " " + contract.teamAvailable().shift(-8));
    console.log("RESULT: crowdsale.founderAvailable=" + contract.founderAvailable() + " " + contract.founderAvailable().shift(-8));
    console.log("RESULT: crowdsale.softCapReached=" + contract.softCapReached());

    var latestBlock = eth.blockNumber;
    var i;

    var tokenPurchaseEvents = contract.TokenPurchase({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    tokenPurchaseEvents.watch(function (error, result) {
      console.log("RESULT: TokenPurchase " + i++ + " #" + result.blockNumber + ": purchaser=" + result.args.purchaser +
        " beneficiary=" + result.args.beneficiary + " value=" + result.args.value.shift(-18) + " amount=" + result.args.amount.shift(-8));
    });
    tokenPurchaseEvents.stopWatching();

    crowdsaleFromBlock = parseInt(latestBlock) + 1;
  }
}


//-----------------------------------------------------------------------------
// Token Contract
//-----------------------------------------------------------------------------
var tokenFromBlock = 0;
function printTokenContractDetails() {
  console.log("RESULT: tokenContractAddress=" + tokenContractAddress);
  if (tokenContractAddress != null && tokenContractAbi != null) {
    var contract = eth.contract(tokenContractAbi).at(tokenContractAddress);
    var decimals = contract.decimals();
    console.log("RESULT: token.owner=" + contract.owner());
    console.log("RESULT: token.totalSupply=" + contract.totalSupply().shift(-decimals));
    console.log("RESULT: token.name=" + contract.name());
    console.log("RESULT: token.symbol=" + contract.symbol());
    console.log("RESULT: token.decimals=" + decimals);
    console.log("RESULT: token.transferAllowed=" + contract.transferAllowed());
    console.log("RESULT: token.mintingFinished=" + contract.mintingFinished());

    var latestBlock = eth.blockNumber;
    var i;

    var burnEvents = contract.Burn({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    burnEvents.watch(function (error, result) {
      console.log("RESULT: Burn " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    burnEvents.stopWatching();

    var transferAllowedEvents = contract.TransferAllowed({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    transferAllowedEvents.watch(function (error, result) {
      console.log("RESULT: TransferAllowed " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    transferAllowedEvents.stopWatching();

    var mintEvents = contract.Mint({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    mintEvents.watch(function (error, result) {
      console.log("RESULT: Mint " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    mintEvents.stopWatching();

    var mintFinishedEvents = contract.MintFinished({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    mintFinishedEvents.watch(function (error, result) {
      console.log("RESULT: MintFinished " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    mintFinishedEvents.stopWatching();

    var approvalEvents = contract.Approval({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    approvalEvents.watch(function (error, result) {
      console.log("RESULT: Approval " + i++ + " #" + result.blockNumber + " owner=" + result.args.owner + " spender=" + result.args.spender + " value=" +
        result.args.value.shift(-decimals));
    });
    approvalEvents.stopWatching();

    var transferEvents = contract.Transfer({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    transferEvents.watch(function (error, result) {
      console.log("RESULT: Transfer " + i++ + " #" + result.blockNumber + ": from=" + result.args.from + " to=" + result.args.to +
        " value=" + result.args.value.shift(-decimals));

    });
    transferEvents.stopWatching();

    tokenFromBlock = latestBlock + 1;
  }
}
