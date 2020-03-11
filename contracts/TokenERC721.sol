
pragma solidity ^0.6.2;

import '../interfaces/IERC721.sol';
import '../interfaces/IERCTokenReceiver.sol';
import './CheckerERC165.sol';
import '../interfaces/SafeMath.sol';



contract TokenERC721 is IERC721, CheckERC165{
    using SafeMath for uint256;


    string constant ZERO_ADDRESS = "003001";
    string constant NOT_VALID_NFT = "003002";
    string constant NOT_OWNER_OR_OPERATOR = "003003";
    string constant NOT_OWNER_APPROVED_OR_OPERATOR = "003004";
    string constant NOT_ABLE_TO_RECEIVE_NFT = "003005";
    string constant NFT_ALREADY_EXISTS = "003006";
    string constant NOT_OWNER = "003007";
    string constant IS_OWNER = "003008";
    string constant IS_CREATOR = "003009";

    bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;

    uint256 totalSupply;

    address internal creator;
    //maxId is used to check if a tokenId is valid.

    uint256[] internal allTokens; //All the tokens that have been issued till now
    
    mapping(uint256 => bool) internal burned; //All the tokens that have been burned till now



    // Mapping from token ID to index of the owner tokens list 
    mapping(uint256 => uint256) internal ownedTokensIndex; 
    //Mapping from token id to position in the allTokens array 
    mapping(uint256 => uint256) internal allTokensIndex;

    mapping (address => uint256) internal ownedTokensCount;
    mapping(address => uint256[]) internal balances; //keep the number of ERC721 tokens associated with an address
    mapping(uint256 => address) internal owners; //which token is owned by which address



    mapping (uint256 => address) internal idToApproval; 
    mapping (address => mapping (address => bool)) internal ownerToOperators;

    event Received(address, uint);

    modifier isCreator(address _address){
        require(_address == creator, IS_CREATOR);
        _;
    }
    
    modifier validNFToken(
        uint256 _tokenId
      )
      {
        require(_tokenId != 0 || !burned[_tokenId]|| owners[_tokenId]==address(0), NOT_VALID_NFT);
        _;
    }
    
        modifier canOperate(uint256 _tokenId){
        address tokenOwner = ownerOf(_tokenId);
        require(tokenOwner == msg.sender || ownerToOperators[tokenOwner][msg.sender], NOT_OWNER_OR_OPERATOR);
        _;
    }
    
    
    /// @notice Contract constructor
    constructor() public override CheckERC165(){
        creator = msg.sender;

        //Add to ERC165 Interface Check
        supportedInterfaces[

            bytes4(keccak256("balanceOf(address)")) ^
            bytes4(keccak256("ownerOf(uint256)")) ^
            //this.safeTransferFrom.selector ^
            //Have to manually do the two transferFroms because overloading confuse selector
            bytes4(keccak256("safeTransferFrom(address,address,uint256)"))^
            bytes4(keccak256("safeTransferFrom(address,address,uint256,bytes)"))^
            bytes4(keccak256("transferFrom(address,address,uint256)"))^

            bytes4(keccak256("approve(address,uint256)"))^


            bytes4(keccak256("getApproved(uint256)"))^



            bytes4(keccak256("setApprovalForAll(address,bool)"))^


            bytes4(keccak256("isApprovedForAll(address,address)"))
        ] = true;
    }
    
    
    function contractBalance() external view returns (uint256 balance) {
        address payable self = address(this);
        balance = self.balance;
    
    }
    
    function _addNFToken(address _to, uint256 _tokenId) internal validNFToken(_tokenId){
        require(owners[_tokenId] == address(0), NFT_ALREADY_EXISTS); 
        totalSupply = totalSupply.add(1); //Add 1 to the totalsupply of tokens

        owners[_tokenId] = _to; //Mark this _to as an array of _tokenId
        
        
        ownedTokensCount[_to] = ownedTokensCount[_to].add(1); //Adding 1 to the total number of tokens for this owner _to
        
        uint256 _index = allTokens.length; //New index at which the _tokenId will be added to the allTokens
        allTokensIndex[_tokenId] = _index;
        allTokens.push(_tokenId); //Add to alltokens array

        uint256 _ownerIndex = balances[_to].length;
        ownedTokensIndex[_tokenId] = _ownerIndex;
        balances[_to].push(_tokenId); //Add this new token to the balances array of the _to address


        
        emit Transfer(creator, _to, _tokenId);
    }
    
    function _removeNFToken(address _from, uint256 _tokenId) internal validNFToken(_tokenId)  haveOwnership(_tokenId){


        totalSupply = totalSupply.sub(1); //subtract 1 to the totalsupply of tokens

        delete owners[_tokenId]; //Delete the ownership of this _tokenId
        
        ownedTokensCount[_from] = ownedTokensCount[_from].sub(1); //subtract 1 to the total number of tokens for this owner _to
        
        uint256 _index = allTokensIndex[_tokenId];
        delete allTokens[_index]; //Delete the _tokenid from the allTokens
        
        uint256 _ownerIndex = ownedTokensIndex[_tokenId];
        delete balances[_from][_ownerIndex]; //Delete the _tokenid from the balances array for _from address
        
        burned[_tokenId]= true; //All the tokens that have been burned till now

        emit Transfer(_from, address(0), _tokenId);
    }
    
    
    function mint(address _to, uint256  _tokenId) external  isCreator(msg.sender) {
        require(_to != address(0), ZERO_ADDRESS);
        //We have to emit an event for each token that gets created
        _addNFToken(_to, _tokenId);            
            
    }

    function burn(uint256 _tokenId) external {
        //NO need to check validity of the token as it will be checked in ownerOf
        address owner = ownerOf(_tokenId);
        _removeNFToken(owner, _tokenId);
         _clearApproval(_tokenId);
        emit Transfer(owner, address(0), _tokenId);

    }


    function ownerOf(uint256 _tokenId) public view override validNFToken(_tokenId) returns (address _owner){
        _owner =  owners[_tokenId];
        require(_owner != address(0), NOT_VALID_NFT);

    }

    

    function balanceOf(address _owner) public view override returns (uint256){
            require(_owner != address(0), ZERO_ADDRESS);
            return ownedTokensCount[_owner];

    }


    function toUint256(bytes memory _bytes, uint256 _start) internal pure returns (uint256) {
        require(_bytes.length >= (_start + 32), "Read out of bounds");
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }
    

    
    





    modifier haveOwnership(uint256 _tokenId){
        address tokenOwner = owners[_tokenId];
        require(
          tokenOwner == msg.sender
          || idToApproval[_tokenId] == msg.sender
          || ownerToOperators[tokenOwner][msg.sender],
          NOT_OWNER_APPROVED_OR_OPERATOR
        );
        _;
      }


    function transferFrom(address _from, address _to, uint256 _tokenId) public override haveOwnership(_tokenId) validNFToken(_tokenId){
        address  owner = ownerOf(_tokenId); 
        require(owner == _from, NOT_OWNER);
        require(_to != address(0), ZERO_ADDRESS);

        _transfer(_to, _tokenId);


    }
    
    
    function _transfer(address _to, uint256 _tokenId) internal {
        address from = ownerOf(_tokenId);
        _clearApproval(_tokenId);

        _removeNFToken(from, _tokenId);
        _addNFToken(_to, _tokenId);

        emit Transfer(from, _to, _tokenId);

    }
    
    
    
    
    function setApprovalForAll(address _operator, bool _approved) public override {
        ownerToOperators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
        
    }
    
    function isApprovedForAll(address _owner, address _operator) public view override returns (bool){
        return ownerToOperators[_owner][_operator];
        
    }
    

    function approve(address _to, uint256 _tokenId) public override canOperate(_tokenId) validNFToken(_tokenId) {
        address  owner = ownerOf(_tokenId);
        require(_to != owner, IS_OWNER);

        idToApproval[_tokenId] = _to;
        emit Approval(owner, _to, _tokenId);

        
    }
    
    function getApproved(uint256 _tokenId) public view  override validNFToken(_tokenId) returns (address){

        return idToApproval[_tokenId];
        
    }




    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) public override {
        
        transferFrom(_from,_to, _tokenId);
        //Get size of "_to" address, if 0 it's a wallet
        uint32 size;
        assembly {
            size := extcodesize(_to)
        }
        
        if (size> 0){
            ERC721TokenReceiver receiver = ERC721TokenReceiver(_to);
            require(receiver.onERC721Received(_to, _from, uint256(_tokenId), _data)== bytes4(keccak256("onERC721Received(address, address, uint256, bytes)")), NOT_ABLE_TO_RECEIVE_NFT);
        
            
        }
    }
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public override{
        safeTransferFrom(_from,_to,_tokenId,"");

    }


    /**
       * @dev Clears the current approval of a given NFT ID.
       * @param _tokenId ID of the NFT to be transferred.
    */
    function _clearApproval(uint256 _tokenId) private{
    if (idToApproval[_tokenId] != address(0)){
      delete idToApproval[_tokenId];
    }
    }

    
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}
