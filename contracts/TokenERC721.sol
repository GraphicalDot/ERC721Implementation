
pragma solidity ^0.6.0;

import '../interfaces/IERC721.sol';
import '../interfaces/IERCTokenReceiver.sol';
import './CheckerERC165.sol';
import '../interfaces/SafeMath.sol';

contract TokenERC721 is IERC721, CheckERC165{
    using SafeMath for uint256;
    

    //Tokens with owners of 0x0 revert to contract creator, makes the contract scalable.
    address internal creator;
    //maxId is used to check if a tokenId is valid.
    uint256 internal maxId;
    mapping(address => uint256) internal balances;
    mapping(uint256 => bool) internal burned;
    mapping(uint256 => address) internal owners;
    mapping (uint256 => address) internal allowance;
    mapping (address => mapping (address => bool)) internal authorised;


    /// @notice Contract constructor
    /// @param _initialSupply The number of tokens to mint initially
    constructor(uint _initialSupply) public override CheckERC165(){
        creator = msg.sender;
        balances[msg.sender] = _initialSupply;
        maxId = _initialSupply;

        //Add to ERC165 Interface Check
        supportedInterfaces[

            bytes4(keccak256("balanceOf(address)")) ^
            bytes4(keccak256("ownerOf(uint256)")) ^
            bytes4(keccak256("safeTransferFrom(address,address,uint256)"))^
            bytes4(keccak256("safeTransferFrom(address,address,uint256,bytes)"))^
            bytes4(keccak256("transferFrom(address,address,uint256)"))^
            bytes4(keccak256("approve(address,uint256)"))^
            bytes4(keccak256("getApproved(uint256)"))^
            bytes4(keccak256("setApprovalForAll(address,bool)"))^
            bytes4(keccak256("isApprovedForAll(address,address)"))
        ] = true;
    }
    
    /*
    @notice Query if a contract implements an interface
    @param _tokenId tokenid which needs to be check for validity
    @return `true` if _tokenId is a valid tokenId
    */
    function isValidToken(uint256 _tokenId) internal view returns(bool){
        return _tokenId != 0 && _tokenId <= maxId && !burned[_tokenId];
        
    }

    function balanceOf(address owner) public view override returns (uint256){
        return balances[owner];
        
    }
        function issueTokens(uint256 _newTokens) external {
        require(msg.sender == creator, "Only owner of the smart contract can issue new tokens");
        balances[msg.sender] = balances[msg.sender].add(_newTokens); 
        //We have to emit an event for each token that gets created
        for(uint i = maxId.add(1); i <= maxId.add(_newTokens); i++){
               emit Transfer(address(0), creator, i);
        }
        maxId += _newTokens; 
    } 

    function burnTokens(uint256 _tokenId) external {
        //NO need to check validity of the token as it will be checked in ownerOf
        address owner = ownerOf(_tokenId);

        require(allowance[_tokenId]== msg.sender || owner==msg.sender || authorised[owner][msg.sender]);
        burned[_tokenId] = true;
        balances[owner]--;
        emit Transfer(owner, address(0), _tokenId);

        
    }


    /**
     * @dev Returns the owner of the NFT specified by `tokenId`.
     */
    function ownerOf(uint256 _tokenId) public view override returns (address owner){
        require(isValidToken(_tokenId));
        
        if (owners[_tokenId] != address(0)){
            return owners[_tokenId];
        }
        return creator;
        
    }
    
    function setApprovalForAll(address _operator, bool _approved) public override {
        emit ApprovalForAll(msg.sender, _operator, _approved);
        authorised[msg.sender][_operator] = _approved;
        
    }
    
    function isApprovedForAll(address _owner, address _operator) public view override returns (bool){
        return authorised[_owner][_operator];
        
    }

 
    function transferFrom(address _from, address _to, uint256 _tokenId) public override {
        require(isValidToken(_tokenId));
        address  owner = ownerOf(_tokenId); 
        require ( owner == msg.sender
        || allowance[_tokenId] == msg.sender
        || authorised[owner][msg.sender]);
        
        require(owner == _from);
        require(_to != address(0));
        emit Transfer(_from, _to, _tokenId);
        owners[_tokenId] = _to;
        balances[_from]--;
        balances[_to]++;

        if(allowance[_tokenId] != address(0)){
           delete allowance[_tokenId];
        }

    }
    
    function approve(address _to, uint256 _tokenId) public override{
        require(isValidToken(_tokenId));
        address  owner = ownerOf(_tokenId);
        require(msg.sender == owner || authorised[owner][msg.sender], "Message sender should be the owner of tokenId or owner has authorised msg.sender as the guardian of his/her tokens");
        emit Approval(owner, _to, _tokenId);
        allowance[_tokenId] = _to;

        
    }
    function getApproved(uint256 _tokenId) public view override returns (address operator){
        require(isValidToken(_tokenId));
        return allowance[_tokenId];
        
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
            require(receiver.onERC721Received(_to, _from,_tokenId, _data)== bytes4(keccak256("onERC721Received(address, address, uint256, bytes)")) );
        
            
        }
    }
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public override{
        safeTransferFrom(_from,_to,_tokenId,"");

    }
}