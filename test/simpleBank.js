const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Bank test", function () {
  it("deposit & withdraw with correct mapping update", async function () {

    const [owner] = await ethers.getSigners();
    const token = await ethers.getContractFactory("ERC20");
    const Token = await token.deploy(1000)
    await Token.waitForDeployment();

    const bank = await ethers.getContractFactory("SimpleBank");
    const Bank = await bank.deploy(await Token.getAddress())
    await Bank.waitForDeployment();

    await Token.connect(owner).approve(await Bank.getAddress(), 100);
    console.log("DEPOSIT 100");
    await Bank.connect(owner).deposit(100);
    console.log(await Bank.deposits(owner.address));

    expect(await Bank.deposits(owner.address)).to.equal(100);
    console.log("WITHDRAW 50");
    await Bank.connect(owner).withdraw(50);
    console.log(await Bank.deposits(owner.address));
    expect(await Bank.deposits(owner.address)).to.equal(50);
    await Bank.connect(owner).withdraw(60);
    // await expect(
    //   Bank.connect(owner).withdraw(60)
    // ).to.be.revertedWith("insufficient deposit");
  });
});