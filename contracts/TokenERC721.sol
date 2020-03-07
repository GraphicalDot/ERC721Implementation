
pragma solidity ^0.6.0;

import "../interfaces/IERC721.sol";
import "./CheckerERC165.sol";
import "../interfaces/SafeMath.sol";

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
    

    
    function balanceOf(address owner) public view override returns (uint256){
        return balances[owner];
        
    }

    /**
     * @dev Returns the owner of the NFT specified by `tokenId`.
     */
    function ownerOf(uint256 tokenId) public view override returns (address owner){
        
    }

    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     *
     *
     * Requirements:
     * - `from`, `to` cannot be zero.
     * - `tokenId` must be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this
     * NFT by either {approve} or {setApprovalForAll}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public override{
        
    }
    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     * Requirements:
     * - If the caller is not `from`, it must be approved to move this NFT by
     * either {approve} or {setApprovalForAll}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public override {
        
    }
    
    function approve(address to, uint256 tokenId) public override {
        
    }
    function getApproved(uint256 tokenId) public view override returns (address operator){
        
    }

    function setApprovalForAll(address operator, bool _approved) public override {
        
    }
    
    function isApprovedForAll(address owner, address operator) public view override returns (bool){
        
    }


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
        
    }
}