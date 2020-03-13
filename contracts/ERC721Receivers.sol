


pragma solidity ^0.6.2;

import '../interfaces/IERCTokenReceiver.sol';
import '../interfaces/SafeMath.sol';



contract ValidTokenReceiver is ERC721TokenReceiver{
    
    using SafeMath for  uint256;    
    uint256 public totalSupply;

    uint256[] private tokens;
    mapping(uint256 => address) private tokenToOwners;
    
    
    constructor() public {}

    function ownerOf(uint256 _tokenId) external view returns(address){
        return tokenToOwners[_tokenId];
    }

    /**
     * @notice Handle the receipt of an NFT
     * @dev The ERC721 smart contract calls this function on the recipient
     * after a {IERC721-safeTransferFrom}. This function MUST return the function selector,
     * otherwise the caller will revert the transaction. The selector to be
     * returned can be obtained as `this.onERC721Received.selector`. This
     * function MAY throw to revert and reject the transfer.
     * Note: the ERC721 contract address is always the message sender.
     * @param _operator The address which called `safeTransferFrom` function
     * @param _from The address which previously owned the token
     * @param _tokenId The NFT identifier which is being transferred
     * @param _data Additional data with no specified format
     * @return bytes4 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */

    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external override returns(bytes4){
        totalSupply = totalSupply.add(1);
        tokenToOwners[_tokenId] = _from;
        tokens.push(_tokenId);
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

}

contract InvalidReceiver is ERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external override returns(bytes4){
        return bytes4(keccak256("some invalid return data"));
    } 
}