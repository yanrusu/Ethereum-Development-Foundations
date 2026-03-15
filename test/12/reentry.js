const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("attack test", function () {
  it("success attack", async function () {
    const [owner, victim] = await ethers.getSigners();

    const bank = await ethers.getContractFactory("Reentryattack_bank");
    const Bank = await bank.deploy();
    await Bank.waitForDeployment();

    const attack = await ethers.getContractFactory("Reentryattack");
    const Attack = await attack.deploy(await Bank.getAddress());
    await Attack.waitForDeployment();

    // 先讓 bank 有錢
    await Bank.connect(victim).deposit({ value: ethers.parseEther("5") });

    // 發動重入
    await Attack.connect(owner).attack({ value: ethers.parseEther("1") });

    const bankBal = await ethers.provider.getBalance(await Bank.getAddress());
    const attackBal = await ethers.provider.getBalance(await Attack.getAddress());

    console.log("bank balance (ETH):", ethers.formatEther(bankBal));
    console.log("attack balance (ETH):", ethers.formatEther(attackBal));

  });
});