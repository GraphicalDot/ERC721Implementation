

import pytest

from brownie import TokenERC721, ValidTokenReceiver, InvalidTokenReceiver, accounts, reverts



ACCOUNT_ONE_TOKEN_IDS = [random.randint(99999, 999999) for e in '_'*2]


@pytest.fixture(scope="module", autouse=True)
def token():
    return accounts[0].deploy(TokenERC721)



@pytest.fixture(scope="module", autouse=True)
def valid_token_receiver():
    return accounts[0].deploy(ValidTokenReceiver)


@pytest.fixture(scope="module", autouse=True)
def invalid_token_receiver():
    return accounts[0].deploy(InvalidTokenReceiver)


@pytest.mark.parametrize('token_id', ACCOUNT_ONE_TOKEN_IDS)
def test_mint_token_account_one(token, token_id):
    token.mint(accounts[1], token_id, {'from': accounts[0]})
    assert token.ownerOf(token_id) == accounts[1]


def test_transfer_to_contract(token, valid_token_receiver):
    """
    Checking Implementation of safeTransferFrom function from TokenERC721 contract
    The other contract ValidTokenReceiver implements an interface ERC721TokenReceiver which 
    enables this contract to receive ERC721 tokens.
    The function onERC721Received in ValidTokenReceiver  must returns bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))
    for successful implementation of ERC721TokenReceiver interface

    The safeTransferFrom function after doing transferFrom(_from, _to, _tokenId) checks if the 
    _to address is a contract address, if yes, It checks whether the onERC721Received function of 
    this contracts returns relevant four bytes

    """
    _from = accounts[1]
    _to = valid_token_receiver.address
    _token_id = ACCOUNT_ONE_TOKEN_IDS[0]    
    token.safeTransferFrom(_from, _to, _token_id)
    assert token.balanceOf(valid_token_receiver.address) == 1
    assert valid_token_receiver.totalSupply == 1


