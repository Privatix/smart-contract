#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Testing the smart contract
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

MODE=${1:-test}

GETHATTACHPOINT=`grep ^IPCFILE= settings.txt | sed "s/^.*=//"`
PASSWORD=`grep ^PASSWORD= settings.txt | sed "s/^.*=//"`

SOURCEDIR=`grep ^SOURCEDIR= settings.txt | sed "s/^.*=//"`

CROWDSALESOL=`grep ^CROWDSALESOL= settings.txt | sed "s/^.*=//"`
CROWDSALEJS=`grep ^CROWDSALEJS= settings.txt | sed "s/^.*=//"`
TOKENSOL=`grep ^TOKENSOL= settings.txt | sed "s/^.*=//"`

DEPLOYMENTDATA=`grep ^DEPLOYMENTDATA= settings.txt | sed "s/^.*=//"`

INCLUDEJS=`grep ^INCLUDEJS= settings.txt | sed "s/^.*=//"`
TEST2OUTPUT=`grep ^TEST2OUTPUT= settings.txt | sed "s/^.*=//"`
TEST2RESULTS=`grep ^TEST2RESULTS= settings.txt | sed "s/^.*=//"`

CURRENTTIME=`date +%s`
CURRENTTIMES=`date -r $CURRENTTIME -u`

BLOCKSINDAY=10

if [ "$MODE" == "dev" ]; then
  # Start time now
  STARTTIME=`echo "$CURRENTTIME" | bc`
else
  # Start time 1m 10s in the future
  STARTTIME=`echo "$CURRENTTIME+90" | bc`
fi
STARTTIME_S=`date -r $STARTTIME -u`
ENDTIME=`echo "$CURRENTTIME+60*2" | bc`
ENDTIME_S=`date -r $ENDTIME -u`

printf "MODE            = '$MODE'\n" | tee $TEST2OUTPUT
printf "GETHATTACHPOINT = '$GETHATTACHPOINT'\n" | tee -a $TEST2OUTPUT
printf "PASSWORD        = '$PASSWORD'\n" | tee -a $TEST2OUTPUT
printf "SOURCEDIR       = '$SOURCEDIR'\n" | tee -a $TEST2OUTPUT
printf "CROWDSALESOL    = '$CROWDSALESOL'\n" | tee -a $TEST2OUTPUT
printf "CROWDSALEJS     = '$CROWDSALEJS'\n" | tee -a $TEST2OUTPUT
printf "TOKENSOL        = '$TOKENSOL'\n" | tee -a $TEST2OUTPUT
printf "DEPLOYMENTDATA  = '$DEPLOYMENTDATA'\n" | tee -a $TEST2OUTPUT
printf "INCLUDEJS       = '$INCLUDEJS'\n" | tee -a $TEST2OUTPUT
printf "TEST2OUTPUT     = '$TEST2OUTPUT'\n" | tee -a $TEST2OUTPUT
printf "TEST2RESULTS    = '$TEST2RESULTS'\n" | tee -a $TEST2OUTPUT
printf "CURRENTTIME     = '$CURRENTTIME' '$CURRENTTIMES'\n" | tee -a $TEST2OUTPUT
printf "STARTTIME       = '$STARTTIME' '$STARTTIME_S'\n" | tee -a $TEST2OUTPUT
printf "ENDTIME         = '$ENDTIME' '$ENDTIME_S'\n" | tee -a $TEST2OUTPUT

# Make copy of SOL file and modify start and end times ---
# `cp modifiedContracts/SnipCoin.sol .`
`cp $SOURCEDIR/$CROWDSALESOL .`
`cp $SOURCEDIR/$TOKENSOL .`
`cp $SOURCEDIR/MultiOwners.sol .`
`cp ../openzeppelin-contracts/math/SafeMath.sol .`
`cp ../openzeppelin-contracts/ownership/Ownable.sol .`
`cp ../openzeppelin-contracts/token/MintableToken.sol .`
`cp ../openzeppelin-contracts/token/StandardToken.sol .`
`cp ../openzeppelin-contracts/token/BasicToken.sol .`
`cp ../openzeppelin-contracts/token/ERC20.sol .`
`cp ../openzeppelin-contracts/token/ERC20Basic.sol .`

# --- Modify parameters ---
`perl -pi -e "s/zeppelin-solidity\/contracts\/math\//.\//" $CROWDSALESOL`
# Modify non-whitelist period from from 1 day to 1 minute
`perl -pi -e "s/startTime \+ 1 days \< now/startTime \+ 1 minutes \< now/" $CROWDSALESOL`
# Modify end date to 3 minutes after start date
`perl -pi -e "s/endTime \= _startTime \+ 28 days/endTime \= _startTime \+ 2 minutes/" $CROWDSALESOL`
`perl -pi -e "s/zeppelin-solidity\/contracts\/token\//.\//" $TOKENSOL`
`perl -pi -e "s/..\/ownership\//.\//" MintableToken.sol`
`perl -pi -e "s/..\/math\//.\//" BasicToken.sol`
# `perl -pi -e "s/bool transferable/bool public transferable/" $TOKENSOL`
# `perl -pi -e "s/MULTISIG_WALLET_ADDRESS \= 0xc79ab28c5c03f1e7fbef056167364e6782f9ff4f;/MULTISIG_WALLET_ADDRESS \= 0xa22AB8A9D641CE77e06D98b7D7065d324D3d6976;/" GimliCrowdsale.sol`
# `perl -pi -e "s/START_DATE = 1505736000;.*$/START_DATE \= $STARTTIME; \/\/ $STARTTIME_S/" GimliCrowdsale.sol`
# `perl -pi -e "s/END_DATE = 1508500800;.*$/END_DATE \= $ENDTIME; \/\/ $ENDTIME_S/" GimliCrowdsale.sol`
# `perl -pi -e "s/VESTING_1_DATE = 1537272000;.*$/VESTING_1_DATE \= $VESTING1TIME; \/\/ $VESTING1TIME_S/" GimliCrowdsale.sol`
# `perl -pi -e "s/VESTING_2_DATE = 1568808000;.*$/VESTING_2_DATE \= $VESTING2TIME; \/\/ $VESTING2TIME_S/" GimliCrowdsale.sol`

DIFFS1=`diff $SOURCEDIR/$CROWDSALESOL $CROWDSALESOL`
echo "--- Differences $SOURCEDIR/$CROWDSALESOL $CROWDSALESOL ---" | tee -a $TEST2OUTPUT
echo "$DIFFS1" | tee -a $TEST2OUTPUT

DIFFS1=`diff $SOURCEDIR/$TOKENSOL $TOKENSOL`
echo "--- Differences $SOURCEDIR/$TOKENSOL $TOKENSOL ---" | tee -a $TEST2OUTPUT
echo "$DIFFS1" | tee -a $TEST2OUTPUT

DIFFS1=`diff ../openzeppelin-contracts/token/MintableToken.sol MintableToken.sol`
echo "--- Differences ../openzeppelin-contracts/token/MintableToken.sol MintableToken.sol ---" | tee -a $TEST2OUTPUT
echo "$DIFFS1" | tee -a $TEST2OUTPUT

DIFFS1=`diff ../openzeppelin-contracts/token/BasicToken.sol BasicToken.sol`
echo "--- Differences ../openzeppelin-contracts/token/BasicToken.sol BasicToken.sol ---" | tee -a $TEST2OUTPUT
echo "$DIFFS1" | tee -a $TEST2OUTPUT

echo "var saleOutput=`solc --optimize --combined-json abi,bin,interface $CROWDSALESOL`;" > $CROWDSALEJS

geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEST2OUTPUT
loadScript("$CROWDSALEJS");
loadScript("functions.js");

var saleAbi = JSON.parse(saleOutput.contracts["$CROWDSALESOL:Sale"].abi);
var saleBin = "0x" + saleOutput.contracts["$CROWDSALESOL:Sale"].bin;
var tokenAbi = JSON.parse(saleOutput.contracts["$TOKENSOL:Token"].abi);
var tokenBin = "0x" + saleOutput.contracts["$TOKENSOL:Token"].bin;

// console.log("DATA: saleAbi=" + JSON.stringify(saleAbi));
// console.log("DATA: saleBin=" + JSON.stringify(saleBin));
// console.log("DATA: tokenAbi=" + JSON.stringify(tokenAbi));
// console.log("DATA: tokenBin=" + JSON.stringify(tokenBin));

unlockAccounts("$PASSWORD");
printBalances();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var saleMessage = "Deploy Crowdsale/Token Contract";
// -----------------------------------------------------------------------------
console.log("RESULT: " + saleMessage);
var saleContract = web3.eth.contract(saleAbi);
// console.log(JSON.stringify(saleContract));
var saleTx = null;
var saleAddress = null;
var token = null;

// console.log("RESULT: parameters=" + $STARTTIME + ", \"" + wallet + "\"");
var sale = saleContract.new($STARTTIME, wallet, {from: contractOwnerAccount, data: saleBin, gas: 6000000},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        saleTx = contract.transactionHash;
      } else {
        saleAddress = contract.address;
        token = web3.eth.contract(tokenAbi).at(sale.token());
        addAccount(saleAddress, "Sale");
        addAccount(sale.token(), "Token '" + token.symbol() + "' '" + token.name() + "'");
        addCrowdsaleContractAddressAndAbi(saleAddress, saleAbi);
        addTokenContractAddressAndAbi(sale.token(), tokenAbi);
        console.log("DATA: saleAddress=" + saleAddress);
      }
    }
  }
);

while (txpool.status.pending > 0) {
}

printTxData("saleAddress=" + saleAddress, saleTx);
printBalances();
failIfGasEqualsGasUsed(saleTx, saleMessage);
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var whitelistMessage = "Whitelist";
// -----------------------------------------------------------------------------
console.log("RESULT: " + whitelistMessage);
var whitelist1Tx = sale.addWhitelist(account3, web3.toWei(1000, "ether"), {from: contractOwnerAccount, gas: 400000});
// var whitelist2Tx = sale.addWhitelist(account4, web3.toWei(1000, "ether"), {from: contractOwnerAccount, gas: 400000});
while (txpool.status.pending > 0) {
}
printTxData("whitelist1Tx", whitelist1Tx);
// printTxData("whitelist2Tx", whitelist2Tx);
printBalances();
failIfGasEqualsGasUsed(whitelist1Tx, whitelistMessage + " - ac3 Whitelist");
// failIfGasEqualsGasUsed(whitelist2Tx, whitelistMessage + " - ac4 Whitelist Capped");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Wait for crowdsale start
// -----------------------------------------------------------------------------
var startTime = sale.startTime();
var startTimeDate = new Date(startTime * 1000);
console.log("RESULT: Waiting until startTime at " + startTime + " " + startTimeDate + " currentDate=" + new Date());
while ((new Date()).getTime() <= startTimeDate.getTime()) {
}
console.log("RESULT: Waited until startTime at " + startTime + " " + startTimeDate + " currentDate=" + new Date());


// -----------------------------------------------------------------------------
// Wait for whitelist period over
// -----------------------------------------------------------------------------
var whitelistOverTime = parseInt(sale.startTime()) + 60;
var whitelistOverTimeDate = new Date(whitelistOverTime * 1000);
console.log("RESULT: Waiting until whitelistOverTime at " + whitelistOverTime + " " + whitelistOverTimeDate + " currentDate=" + new Date());
while ((new Date()).getTime() <= whitelistOverTimeDate.getTime()) {
}
console.log("RESULT: Waited until whitelistOverTime at " + whitelistOverTime + " " + whitelistOverTimeDate + " currentDate=" + new Date());


// -----------------------------------------------------------------------------
var sendContribution4Message = "Send Contribution After Whitelist Over";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution4Message);
var sendContribution4_1Tx = eth.sendTransaction({from: account3, to: saleAddress, gas: 400000, value: web3.toWei("10", "ether")});
var sendContribution4_2Tx = eth.sendTransaction({from: account4, to: saleAddress, gas: 400000, value: web3.toWei("10", "ether")});
while (txpool.status.pending > 0) {
}
printTxData("sendContribution4_1Tx", sendContribution4_1Tx);
printTxData("sendContribution4_2Tx", sendContribution4_2Tx);
printBalances();
failIfGasEqualsGasUsed(sendContribution4_1Tx, sendContribution4Message + " - ac3 10 ETH = 1,400 PRIX");
failIfGasEqualsGasUsed(sendContribution4_2Tx, sendContribution4Message + " - ac4 10 ETH = 1,400 PRIX");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
// Wait for crowdsale end
// -----------------------------------------------------------------------------
var endTimeTime = parseInt(sale.endTime()) + 1;
var endTimeTimeDate = new Date(endTimeTime * 1000);
console.log("RESULT: Waiting until endTimeTime at " + endTimeTime + " " + endTimeTimeDate + " currentDate=" + new Date());
while ((new Date()).getTime() <= endTimeTimeDate.getTime()) {
}
console.log("RESULT: Waited until endTimeTime at " + endTimeTime + " " + endTimeTimeDate + " currentDate=" + new Date());


// -----------------------------------------------------------------------------
var finishCrowdsaleMessage = "Finish Crowdsale";
// -----------------------------------------------------------------------------
console.log("RESULT: " + finishCrowdsaleMessage);
var finishCrowdsale1_1Tx = sale.finishCrowdsale({from: contractOwnerAccount, gas: 400000});
var finishCrowdsale1_2Tx = sale.withdrawTokenToFounder({from: contractOwnerAccount, gas: 400000});
var finishCrowdsale1_3Tx = sale.withdraw({from: contractOwnerAccount, gas: 400000});
while (txpool.status.pending > 0) {
}
printTxData("finishCrowdsale1_1Tx", finishCrowdsale1_1Tx);
printTxData("finishCrowdsale1_2Tx", finishCrowdsale1_2Tx);
printTxData("finishCrowdsale1_3Tx", finishCrowdsale1_3Tx);
printBalances();
failIfGasEqualsGasUsed(finishCrowdsale1_1Tx, finishCrowdsaleMessage + " - Finish Crowdsale");
passIfGasEqualsGasUsed(finishCrowdsale1_2Tx, finishCrowdsaleMessage + " - Withdraw Token To Founder - Expecting Failure");
passIfGasEqualsGasUsed(finishCrowdsale1_3Tx, finishCrowdsaleMessage + " - Withdraw ETH - Expecting Failure");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var refundMessage = "Withdraw Refund";
// -----------------------------------------------------------------------------
console.log("RESULT: " + refundMessage);
var refund_1Tx = sale.refund({from: account3, gas: 100000});
var refund_2Tx = sale.refund({from: account4, gas: 100000});
while (txpool.status.pending > 0) {
}
printTxData("refund_1Tx", refund_1Tx);
printTxData("refund_2Tx", refund_2Tx);
printBalances();
failIfGasEqualsGasUsed(refund_1Tx, refundMessage + " - ac3");
failIfGasEqualsGasUsed(refund_2Tx, refundMessage + " - ac4");
printCrowdsaleContractDetails();
printTokenContractDetails();
console.log("RESULT: ");


EOF
grep "DATA: " $TEST2OUTPUT | sed "s/DATA: //" > $DEPLOYMENTDATA
cat $DEPLOYMENTDATA
grep "RESULT: " $TEST2OUTPUT | sed "s/RESULT: //" > $TEST2RESULTS
cat $TEST2RESULTS
