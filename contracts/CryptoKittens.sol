// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {ERC721Token} from './ERC721Token.sol';

contract CryptoKittens is ERC721Token {

  address public _admin;
  uint public nextId;
  string public tokenBaseURI;

  struct Kitty {
    uint id;
    uint generation;
    uint geneA;
    uint geneB;
  }

  mapping(uint => Kitty) public _kitties;

  
  constructor(string memory _name, string memory _symbol, string memory _tokenBaseURI) 
        ERC721Token(_name, _symbol, _tokenBaseURI){
    _admin = msg.sender;
    tokenBaseURI = _tokenBaseURI;
  }

  function mint() external {
    require(msg.sender == _admin, "only admin can mint");
    require(msg.sender != address(0), "Zero address minting not allowed");

    _kitties[nextId] = Kitty(nextId,1,_random(10),_random(10));
    _mint(nextId, msg.sender);
    nextId++;
  }

  function breed(uint kittyId1, uint kittyId2) external {
    require(kittyId1 < nextId && kittyId2 < nextId, "both the kitties must exist");
    Kitty storage kitty1 = _kitties[kittyId1];
    Kitty storage kitty2 = _kitties[kittyId2];

    require(ownerOf(kittyId1) == msg.sender && ownerOf(kittyId2) == msg.sender, "msg sender should own both kitties");
    uint maxGen = (kitty1.generation > kitty2.generation) ? kitty1.generation : kitty2.generation;
    //we want to give a 50% chance that child gene takes 50% of each parent
    uint _geneA = _random(4) > 1 ? kitty1.geneA : kitty2.geneA;
    uint _geneB = _random(4) > 1 ? kitty1.geneB : kitty2.geneB;
    _kitties[nextId] = Kitty(nextId,maxGen+1,_geneA,_geneB);
    _mint(nextId,msg.sender);
    nextId++;
  }

  function _random(uint _max) private view returns(uint){
    return uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % _max ;
  }
 
  function getAllKittiesOf(address owner) external view returns(Kitty[] memory) {
      uint length;
      for(uint i = 0; i < nextId; i++) {
        if(ownerOf(i) == owner) {
          length++;
        }
      }
      Kitty[] memory kitties = new Kitty[](length);
      for(uint i = 0; i < kitties.length; i++) {
        if(ownerOf(i) == owner) {
          kitties[i] = _kitties[i];
        }
      }
      return kitties;
  }

  function getAllKitties() external view returns(Kitty[] memory) {
      Kitty[] memory kitties = new Kitty[](nextId);
      for(uint i = 0; i < kitties.length; i++) {
        kitties[i] = _kitties[i];
      }
      return kitties;
    }

}
