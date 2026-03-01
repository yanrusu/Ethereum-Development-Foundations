const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Approve and TransferFrom", function () {
  it("User approve -> Vault to pull token", async function () {
    const [owner, Addr1] = await ethers.getSigners();

    const ERC20 = await ethers.getContractFactory("ERC20");
    const token = await ERC20.deploy(1000);
    await token.waitForDeployment();

    const Vault = await ethers.getContractFactory("Vault");
    const vault = await Vault.connect(Addr1).deploy();
    await vault.waitForDeployment();

    const amount = 100;

    console.log("initial");
    console.log("Owner balance : ", await token.balanceOf(owner.address));
    console.log("Vault balance : ", await token.balanceOf(vault.getAddress()));
    console.log("Allowance owner -> Vault",await token.allowance(owner.address, vault.getAddress()));

    await token.connect(owner).approve(await vault.getAddress(), amount);
    console.log("\nApprove 100")
    console.log("Allowance owner -> Vault", await token.allowance(owner.address, vault.getAddress()));
    console.log("\nPull Token");
    await vault.connect(Addr1).pullToken(await token.getAddress(), owner.address, amount);

    console.log("Owner balance:", await token.balanceOf(owner.address));
    console.log("Vault balance:", await token.balanceOf(vault.getAddress()));
    console.log("Allowance Owner -> Vault:", await token.allowance(owner.address, vault.getAddress()));
  });
});
