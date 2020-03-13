

import pytest
from brownie import TokenERC721, accounts, reverts



@pytest.fixture(scope="module", autouse=True)
def token():
    return accounts[0].deploy(TokenERC721)


def test_valid_interface(token):
    """
    Check if the contracts implements the valid interface 0x80ac58cd 
    """
    assert(token.supportsInterface(0x80ac58cd) == True)



def test_invalid_interface(token):
    """
    Check if the contracts implements the invalid interface 0x80fe67ui 
    """
    assert(token.supportsInterface(0x80fe67fa) == False)
