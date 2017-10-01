# MultiOwners

Source file [../../contracts/MultiOwners.sol](../../contracts/MultiOwners.sol).

<br />

<hr />

```javascript
// BK Ok - Consider updating to a recent version
pragma solidity ^0.4.11;


// BK Ok
contract MultiOwners {

    // BK Next 2 Ok
    event AccessGrant(address indexed owner);
    event AccessRevoke(address indexed owner);
    
    // BK Ok
    mapping(address => bool) owners;

    // BK Ok - Constructor
    function MultiOwners() {
        // BK Ok
        owners[msg.sender] = true;
    }

    // BK Ok
    modifier onlyOwner() { 
        // BK Ok 
        require(owners[msg.sender] == true);
        // BK Ok
        _; 
    }

    // BK Ok - Constant function
    function isOwner() constant returns (bool) {
        // BK Ok
        return owners[msg.sender] ? true : false;
    }

    // BK Ok - Constant function
    function checkOwner(address maybe_owner) constant returns (bool) {
        // BK Ok
        return owners[maybe_owner] ? true : false;
    }


    // BK Ok - Only an existing owner can execute this function
    function grant(address _owner) onlyOwner {
        // BK Ok
        owners[_owner] = true;
        // BK Ok
        AccessGrant(_owner);
    }

    // BK Ok - Only an existing owner can execute this function
    function revoke(address _owner) onlyOwner {
        // BK Ok
        require(msg.sender != _owner);
        // BK Ok
        owners[_owner] = false;
        // BK Ok
        AccessRevoke(_owner);
    }
}

```
