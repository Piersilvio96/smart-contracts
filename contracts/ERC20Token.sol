// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Token is ERC20 {

    // fields
    address public owner;


    // modifiers
    modifier isOwner(){
        require(msg.sender == owner, "You are not allowed");
        _;
    }

    // event
    event TransferEmitted(address from, address to, uint256 value, string reason);

    // functions
    constructor(string memory name, string memory code) ERC20(name, code) {
        owner = msg.sender;
    }

    function mint(address walletAddress, uint256 mintSupply) public isOwner{
        _mint(walletAddress, mintSupply);
    }

    function transferFromWithReason(address from, address to, uint256 value, string calldata reason) public {
        transferFrom(from, to, value);
        emit TransferEmitted(from, to, value, reason);
    }

    function transferWithReason(address to, uint256 value, string calldata reason) public {
        transfer(to, value);
        emit TransferEmitted(msg.sender, to, value, reason);
    }

    function burn(address walletAddress, uint256 value) public {
        _burn(walletAddress, value);
    }

}
