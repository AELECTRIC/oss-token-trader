pragma solidity ^0.4.8;

import './TokenInterface.sol';

contract TokenSample is TokenInterface {

    uint8 public constant decimals = 18;

    bytes32 public symbol;
    bytes32 public name;
    uint totalTokens;

    // Owner of this contract
    address public owner;

    // nonce for each account
    mapping(address => uint) nonces;

    // Balances for each account
    mapping(address => uint) balances;

    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping(address => uint)) allowed;

    // Constructor
    function TokenSample(address _owner, bytes32 _tokenSymbol, bytes32 _tokenName, uint _supplyVolume) public {
        owner = _owner;
        balances[owner] = _supplyVolume;
        symbol = _tokenSymbol;
        name = _tokenName;
        totalTokens = _supplyVolume;
    }

    function totalSupply() public constant returns (uint totalSupply) {
        return totalTokens;
    }

    // What is the balance of a particular account?
    function nonceOf(address _owner) public constant returns (uint nonce) {
        return nonces[_owner];
    }

    // What is the balance of a particular account?
    function balanceOf(address _owner) public constant returns (uint balance) {
        return balances[_owner];
    }

    // Transfer the balance from owner's account to another account
    function transfer(address _to, uint _amount) public returns (bool success) {
        return transferInternal(msg.sender, _to, _amount);
    }

    // Send _value amount of tokens from address _from to address _to
    // The transferFrom method is used for a withdraw workflow, allowing contracts to send
    // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
    // fees in sub-currencies; the command should fail unless the _from account has
    // deliberately authorized the sender of the message via some mechanism; we propose
    // these standardized APIs for approval:
    function transferFrom(address _from, address _to, uint _amount) public returns (bool success) {
        if (allowed[_from][msg.sender] >= _amount && transferInternal(_from, _to, _amount)) {
            allowed[_from][msg.sender] -= _amount;
            return true;
        }
        return false;
    }

    function transferWithSign(address _to, uint _amount, uint _nonce, bytes _sign) public returns (bool success) {
        bytes32 hash = calcEnvHash('transferWithSign');
        hash = keccak256(hash, _to);
        hash = keccak256(hash, _amount);
        hash = keccak256(hash, _nonce);
        address from = recoverAddress(hash, _sign);

        if (_nonce == nonces[from] && transferInternal(from, _to, _amount)) {
            nonces[from]++;
            return true;
        }
        return false;
    }

    function transferInternal(address _from, address _to, uint _amount) private returns (bool success) {
        if (balances[_from] >= _amount && _amount > 0 && balances[_to] + _amount > balances[_to]) {
            balances[_from] -= _amount;
            balances[_to] += _amount;
            Transfer(_from, _to, _amount);
            return true;
        }
        return false;
    }

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint _amount) public returns (bool success) {
        return approveInternal(msg.sender, _spender, _amount);
    }

    function approveWithSign(address _spender, uint _amount, uint _nonce, bytes _sign) public returns (bool success) {
        bytes32 hash = calcEnvHash('approveWithSign');
        hash = keccak256(hash, _spender);
        hash = keccak256(hash, _amount);
        hash = keccak256(hash, _nonce);
        address from = recoverAddress(hash, _sign);

        if (_nonce == nonces[from] && approveInternal(from, _spender, _amount)) {
            nonces[from]++;
            return true;
        }
        return false;
    }

    function approveInternal(address _from, address _spender, uint _amount) private returns (bool success) {
        allowed[_from][_spender] = _amount;
        Approval(_from, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }

    function calcEnvHash(bytes32 _functionName) public constant returns (bytes32 hash) {
        hash = keccak256(this);
        hash = keccak256(hash, _functionName);
    }

    function recoverAddress(bytes32 _hash, bytes _sign) public pure returns (address recoverdAddr) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        require(_sign.length == 65);

        assembly {
            r := mload(add(_sign, 32))
            s := mload(add(_sign, 64))
            v := byte(0, mload(add(_sign, 96)))
        }

        if (v < 27) v += 27;

        require(v == 27 || v == 28);

        recoverdAddr = ecrecover(_hash, v, r, s);
        require(recoverdAddr != 0);
    }
}