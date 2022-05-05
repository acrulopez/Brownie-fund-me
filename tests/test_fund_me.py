from os import access
from brownie import FundMe, network, accounts, exceptions
import pytest
from scripts.helpful_scripts import LOCAL_BLOCKCHAIN_ENVIRONMENTS
from scripts.helpful_scripts import get_account
from scripts.deploy import deploy_fund_me


def test_can_fund_me_and_withdraw():
    fund_me = deploy_fund_me()
    account = get_account()
    entranceFee = fund_me.getEntranceFeeInWei()
    tx = fund_me.fund({"from": account, "value": entranceFee})
    tx.wait(1)
    assert fund_me.addressToAmountFunded(account.address) == entranceFee
    tx2 = fund_me.withDraw({"from": account})
    tx2.wait(1)
    assert fund_me.addressToAmountFunded(account.address) == 0


def test_only_owner_can_withdraw():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("only for local testing")  # Only for local testing

    fund_me = deploy_fund_me()
    bad_actor = accounts.add()
    with pytest.raises(exceptions.VirtualMachineError):
        fund_me.withDraw({"from": bad_actor})
