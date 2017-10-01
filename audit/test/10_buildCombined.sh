#!/bin/sh

cat SafeMath.sol Ownable.sol ERC20Basic.sol ERC20.sol BasicToken.sol StandardToken.sol MintableToken.sol MultiOwners.sol Token.sol Sale.sol > Temp.sol

perl -pi -e "s/^import.*$//" Temp.sol
perl -pi -e "s/^pragma.*$//" Temp.sol

echo "pragma solidity ^0.4.16;" > Combined.sol
cat Temp.sol >> Combined.sol

rm Temp.sol
