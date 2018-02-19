pragma solidity ^0.4.8;

import './ERC20Interface.sol';

contract TokenInterface is ERC20Interface {
    function nonceOf(address _owner) public constant returns (uint nonce);
    function approveWithSign(address _spender, uint _amount, uint _nonce, bytes _sign) public returns (bool success);
    function transferWithSign(address _to, uint _amount, uint _nonce, bytes _sign) public returns (bool success);
}