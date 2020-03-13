import pytest

from brownie import TokenERC721, accounts, reverts
import random

ACCOUNT_ONE_TOKEN_IDS = [random.randint(99999, 999999) for e in '_'*4]

ACCOUNT_TWO_TOKEN_IDS = [random.randint(99999, 999999) for e in '_'*4]




@pytest.fixture(scope="module", autouse=True)
def token():
    return accounts[0].deploy(TokenERC721)




@pytest.mark.parametrize('token_id', ACCOUNT_ONE_TOKEN_IDS)
def test_mint_token_account_one(token, token_id):
    token.mint(accounts[1], token_id, {'from': accounts[0]})
    #assert token.balanceOf(accounts[1]) == len(ACCOUNT_ONE_TOKEN_IDS)
    assert token.ownerOf(token_id) == accounts[1]




def test_balance_of_account_one(token):
    #assert token.balanceOf(accounts[1]) == len(ACCOUNT_ONE_TOKEN_IDS)
    assert token.balanceOf(accounts[1]) == len(ACCOUNT_ONE_TOKEN_IDS)


@pytest.mark.parametrize('token_id', ACCOUNT_TWO_TOKEN_IDS)
def test_mint_token_account_two(token, token_id):
    token.mint(accounts[2], token_id, {'from': accounts[0]})
    #assert token.balanceOf(accounts[1]) == len(ACCOUNT_ONE_TOKEN_IDS)
    assert token.ownerOf(token_id) == accounts[2]



def test_balance_of_account_two(token):
    assert token.balanceOf(accounts[2]) == len(ACCOUNT_TWO_TOKEN_IDS)





def test_give_approval(token):
    """
    Give approval to account[1] for a tokenid ACCOUNT_TWO_TOKEN_IDS[0] by the rightful owner of 
    this tokne which is account[2]
    """

    token.approve(accounts[1], ACCOUNT_TWO_TOKEN_IDS[0], {'from': accounts[2]})
    assert(token.getApproved(ACCOUNT_TWO_TOKEN_IDS[0]) == accounts[1])




def test_give_approval_all(token):
    """
    If account[1] has given approval for all to accounts[2]
    """

    token.setApprovalForAll(accounts[2], True, {'from': accounts[1]})
    assert(token.isApprovedForAll(accounts[1], accounts[2]) == True)








