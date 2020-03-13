
import pytest
import random
from brownie import TokenERC721, accounts, reverts

ACCOUNT_ONE_TOKEN_IDS = [random.randint(99999, 999999) for e in '_'*4]

ACCOUNT_TWO_TOKEN_IDS = [random.randint(99999, 999999) for e in '_'*4]




@pytest.fixture(scope="module", autouse=True)
def token():
    return accounts[0].deploy(TokenERC721)



def test_balance_of_account_zero(token):
    """
    throws when trying to get count of NFTs owned by 0x0 address
    """
    zero_address = f"0x{'0'*40}"
    with reverts():
        token.balanceOf(zero_address)





@pytest.mark.parametrize('token_id', ACCOUNT_ONE_TOKEN_IDS)
def test_mint_token_account_one(token, token_id):
    """
    Create new tokens and issue them to account[1]
    """

    token.mint(accounts[1], token_id, {'from': accounts[0]})
    #assert token.balanceOf(accounts[1]) == len(ACCOUNT_ONE_TOKEN_IDS)
    assert token.ownerOf(token_id) == accounts[1]




def test_balance_of_account_one(token):
    #assert token.balanceOf(accounts[1]) == len(ACCOUNT_ONE_TOKEN_IDS)
    assert token.balanceOf(accounts[1]) == len(ACCOUNT_ONE_TOKEN_IDS)


@pytest.mark.parametrize('token_id', ACCOUNT_TWO_TOKEN_IDS)
def test_mint_token_account_two(token, token_id):
    """
    Create new tokens and issue them to account[2]
    """
    token.mint(accounts[2], token_id, {'from': accounts[0]})
    #assert token.balanceOf(accounts[1]) == len(ACCOUNT_ONE_TOKEN_IDS)
    assert token.ownerOf(token_id) == accounts[2]



def test_mint_token(token):
    """
    Create new tokens by accounts[1]
    This should ideally fail as only owner of this contract i.e accounts[0]
    can mint tokens
    """
    token_id = random.randint(99999, 999999)
    with reverts("003009"): ##IS_CREATOR
        token.mint(accounts[2], token_id, {'from': accounts[1]})





def test_balance_of_account_two(token):
    assert token.balanceOf(accounts[2]) == len(ACCOUNT_TWO_TOKEN_IDS)


def test_mint_existing_token(token):
    
    with reverts("003006"):
        token.mint(accounts[1], ACCOUNT_ONE_TOKEN_IDS[0], {'from': accounts[0]})


def test_valid_owner(token):
    assert token.ownerOf(ACCOUNT_ONE_TOKEN_IDS[0]) == accounts[1]



def test_invalid_owner(token):
    """
    Token ACCOUNT_ONE_TOKEN_IDS[0] == 952807 belongs to account[1]
    Thsi should be equal to account[2]
    """
    assert token.ownerOf(ACCOUNT_ONE_TOKEN_IDS[0]) != accounts[2]



def test_transfer_from(token):
    """
    Lets transfer ACCOUNT_ONE_TOKEN_IDS[0] == 952807 to account[3]
    """
    token.transferFrom(accounts[1], accounts[3], ACCOUNT_ONE_TOKEN_IDS[0], {'from': accounts[1]})

    ##check if number of tokens for account[3] == 1
    assert token.balanceOf(accounts[3]) == 1

    ##check if number of tokens for account[1] has decreased by 1
    assert token.balanceOf(accounts[1]) == len(ACCOUNT_ONE_TOKEN_IDS) -1
    
    ##check whether the new owner of ERC721 token 952807 is accounts[3]
    assert token.ownerOf(ACCOUNT_ONE_TOKEN_IDS[0]) == accounts[3]



def test_burn_invalid_owner(token):
    """
    Lets try to burn  ACCOUNT_TWO_TOKEN_IDS[0] == 870253 from account[1] who is 
    not a valid owner of this token, 
    The burn operation should fail
    """
    with reverts("003004"): #NOT_OWNER_APPROVED_OR_OPERATOR
        token.burn(ACCOUNT_TWO_TOKEN_IDS[0], {'from': accounts[1]})




def test_burn_valid_owner(token):
    """
    Lets try to burn  ACCOUNT_TWO_TOKEN_IDS[0] == 870253 from account[2] who is 
    not a valid owner of this token, 
    This shall fail
    """
    token.burn(ACCOUNT_TWO_TOKEN_IDS[0], {'from': accounts[2]})


    ##check if number of tokens for account[2] has decreased by 1
    assert token.balanceOf(accounts[2]) == len(ACCOUNT_TWO_TOKEN_IDS) -1
    
    

    with reverts(): #NOT_OWNER_APPROVED_OR_OPERATOR
        token.ownerOf(ACCOUNT_TWO_TOKEN_IDS[0]) 








# def test_check_valid_owner(token):
    
#     with reverts("003006"):
#         token.mint(accounts[1], 567, {'from': accounts[0]})
