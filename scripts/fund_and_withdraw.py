from brownie import FundMe
from scripts.helpful_scripts import get_account


def fund():
    fund_me = FundMe[-1]
    account = get_account()
    entranceFee = fund_me.getEntranceFeeInWei()
    print(f"The current entrance fee in Ether is: {entranceFee / 10**18}")

    # Fund the contract
    fund_me.fund({"from": account, "value": entranceFee})


def withdraw():
    fund_me = FundMe[-1]
    account = get_account()

    # Withdraw the value from the contract
    fund_me.withDraw({"from": account})


def main():
    fund()
    withdraw()
