// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";


interface IERC721 /* is ERC165 */ {
    /// @dev This emits when ownership of any NFT changes by any mechanism.
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to none.
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /// @dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address _owner) external view returns (uint256);

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) external view returns (address);

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external payable;

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to "".
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) external payable;

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external;

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) external view returns (address);

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

interface IERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}



contract ERC721Token is IERC721 {
 // Token name
    string private _name;

    // Token symbol
    string private _symbol;
    address public admin;
    string private _tokenBaseURI;

  using Address for address;

  bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;

  mapping(address => uint256) private _balances;
  mapping(uint256 => address) private _owners;
  mapping(uint256 => address) private _tokenApprovals;
  
  //first address is the owner of tokens, second is the operator
  mapping(address => mapping(address => bool)) private __operatorApprovals;


  constructor(string memory name_, string memory symbol_, string memory tokenBaseURI_) {
    _name = name_;
    _symbol = symbol_;
    _tokenBaseURI = tokenBaseURI_;
    admin = msg.sender;
  }

  function name() external view returns (string memory) {
      return _name;
  }

  /**
    * @dev See {IERC721Metadata-symbol}.
    */
  function symbol() external view returns (string memory) {
      return _symbol;
  }

  function baseURI() public view returns(string memory)  {
      return _tokenBaseURI;
  }

  function tokenURI(uint _tokenId) external view returns(string memory){
    require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
    string memory _baseURI = baseURI();
    return (bytes(_baseURI).length> 0) ? string(abi.encodePacked(_baseURI,"/",_tokenId)) : "" ;
  }

  function _mint(uint256 _tokenId, address _owner) internal {
    require(_owner != address(0), "Zero address minting not allowed");
    require(!_exists(_tokenId), "ERC721: token already minted");

    _balances[_owner] ++;
    _owners[_tokenId] = _owner;
    emit Transfer(address(0), _owner, _tokenId);
  }

  function balanceOf(address _owner) external view override returns (uint256){
    require(_owner != address(0), "ERC721: balance query for the zero address");
    return _balances[_owner];
  }

  function ownerOf(uint256 _tokenId) public view override returns  (address){    
    address owner = _owners[_tokenId];
    require(owner != address(0),"ERC721: owner query for nonexistent token");
    return owner;
  }

  function approve(address _approved, uint256 _tokenId) external payable override {
    address owner = _owners[_tokenId];
    require(msg.sender == owner, "only owner of this token can approve");
    _tokenApprovals[_tokenId] = _approved;
    emit Approval(msg.sender, _approved, _tokenId);
  }

  function setApprovalForAll(address _operator, bool _approved) external override {
    require(msg.sender != _operator, "Can not set own address as operator");
    __operatorApprovals[msg.sender][_operator] = _approved;
    emit ApprovalForAll(msg.sender, _operator, _approved);
  }

  function isApprovedForAll(address _owner, address _operator) external view override returns (bool) {
    return __operatorApprovals[_owner][_operator];
  }

  function getApproved(uint256 _tokenId) external view override returns(address) {
   return _tokenApprovals[_tokenId];
  }

  function transferFrom(address _from, address _to, uint256 _tokenId) external payable override {
    _transfer(_from, _to, _tokenId);
  }

  function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable override {
    _safeTransferFrom(_from, _to, _tokenId,"");
  }

 function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable override {
   _safeTransferFrom(_from, _to, _tokenId, data);
 }

 function _safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) internal {
    _transfer(_from, _to, _tokenId);

    //check if _to is a smart contract address
    if(_to.isContract()){
      bytes4 retVal = IERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, data);
      require(retVal == MAGIC_ON_ERC721_RECEIVED,'Recipient Contract can not handle ERC721 Tokens');
    }
 }

  function _transfer(address _from, address _to, uint256 _tokenId) internal canTransfer(_tokenId) {
      
      require(_to != address(0), "ERC721: transfer to the zero address");
      _balances[_from] -=1;
      _balances[_to] += 1;
      _owners[_tokenId] = _to;
      emit Transfer(_from, _to, _tokenId);
  }

  modifier canTransfer(uint256 _tokenId) {
    address owner = _owners[_tokenId];
    require(owner == msg.sender 
              || _tokenApprovals[_tokenId]== msg.sender
              || __operatorApprovals[owner][msg.sender] == true,
              "Not authorized to transfer Token");
    _;
  }

  function _exists(uint256 tokenId) internal view returns (bool) {
      return _owners[tokenId] != address(0);
  }
}