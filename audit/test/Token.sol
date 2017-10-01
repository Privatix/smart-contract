pragma solidity ^0.4.15;

import './MintableToken.sol';


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
}
