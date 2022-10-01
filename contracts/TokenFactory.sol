// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./ERC20Token.sol";

contract FactoryToken{

    
    // fields
    address public owner;

    //Defining mappings
    mapping (string => address) public tokens;
    mapping (string => string[]) public fromPartitionRule;
    mapping  (string => string[]) public toPartitionRule;  
    string[] public partitions;
    
    // modifiers
    modifier isOwner(){
        require(msg.sender == owner, "You are not allowed");
        _;
    }

    modifier partitionExists(string memory partition){
        require(tokens[partition] != address(0x0), "Error: Partition is not already used");
        _;
    }
    
    modifier partitionNotExists(string memory partition){
        require(tokens[partition] == address(0x0), "Error: Partition already used");
        _;
    }

    modifier  balanceIsSufficent(string memory partition, address walletAddress, uint256 amount){
        ERC20Token token = ERC20Token(tokens[partition]);
        require(token.balanceOf(walletAddress) >= amount, "ERROR: Balance is not enough");
        _;
    }

    // events

    event AddedFromPartitionRule(string from, string to);
    event AddedToPartitionRule(string from, string to);
    event TokenConversion(string from, string to, address wallet, uint256 amount);

    constructor(){
        owner = msg.sender;
    }
    
    // Generator
    function createToken(string memory partition, string memory name, string memory code) public isOwner{
        tokens[partition] = address(new ERC20Token(name, code));
        fromPartitionRule[partition].push(partition);
        toPartitionRule[partition].push(partition);
        partitions.push(partition);
    }
    

    // Rule Methods
    function addFromPartitionRule(string memory fromPartition,string memory toPartition) public 
    partitionExists(fromPartition)
    partitionExists(toPartition)
    {
        fromPartitionRule[fromPartition].push(toPartition);
        emit AddedFromPartitionRule(fromPartition, toPartition);
    }

    function addToPartitionRule(string memory fromPartition,string memory toPartition) public 
    partitionExists(fromPartition)
    partitionExists(toPartition)
    {
        toPartitionRule[toPartition].push(fromPartition);
        emit AddedToPartitionRule(fromPartition, toPartition);
    }

    // FunctionalMethods
    // SingleToken Handler
    function balanceOf(string memory partition, address walletAddress) public view  returns (uint256){
        ERC20Token token = ERC20Token(tokens[partition]);
        return token.balanceOf(walletAddress);
    }


    function mintToken(string memory partition, address walletAddress, uint256 mintSupply) public isOwner{
        ERC20Token token = ERC20Token(tokens[partition]);
        token.mint(walletAddress, mintSupply);
    }

    function burnToken(string memory partition, address walletAddress, uint256 mintSupply) public  isOwner{
        ERC20Token token = ERC20Token(tokens[partition]);
        token.burn(walletAddress, mintSupply);
    }

    function transferWithReason(string memory partition, address to, uint256 value,  string calldata reason) public{
        ERC20Token token = ERC20Token(tokens[partition]);
        token.transferWithReason(to, value, reason);
    } 

    function transferFromWithReason(string memory partition, address from, address to, uint256 value, string calldata reason) public{
        ERC20Token token = ERC20Token(tokens[partition]);
        token.transferFromWithReason(from, to, value, reason);
    }

    // MultipleToken Handler

    function balanceByUser() public  view returns (uint256){
        uint256 balance = 0;
        for (uint i = 0; i < partitions.length; i++){
            balance = balance + balanceOf(partitions[i], msg.sender);
        }
        return balance;
    }

    function convertToken(string memory fromPartition, string memory toPartition, uint256 amount) public
    partitionExists(fromPartition)
    partitionExists(toPartition)
    balanceIsSufficent(fromPartition, msg.sender, amount)
    {
        ERC20Token fromToken = ERC20Token(tokens[fromPartition]);
        ERC20Token toToken = ERC20Token(tokens[toPartition]);
        fromToken.burn(msg.sender, amount);
        toToken.mint(msg.sender, amount);
        emit TokenConversion(fromPartition, toPartition, msg.sender, amount);
    }
    
}