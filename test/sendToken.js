const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ERC20 Transfer Test", function () {
  it("should transfer tokens and print balance changes + receipt logs", async function () {
    const [owner, addr1, addr2] = await ethers.getSigners();

    const ERC20 = await ethers.getContractFactory("ERC20");
    const token = await ERC20.deploy(1000);
    await token.waitForDeployment();
    const tokenAddress = await token.getAddress();

    console.log("初始狀態");
    const ownerBalance = await token.balanceOf(owner.address);
    const addr1Balance = await token.balanceOf(addr1.address);
    console.log("Owner 餘額:", ownerBalance.toString());
    console.log("Addr1 餘額:", addr1Balance.toString());

    console.log("執行轉帳");
    console.log(`Owner 向 Addr1 轉帳 500 代幣`);

    // 執行轉帳並獲取 Receipt
    const tx = await token.transfer(addr1.address, 500n);
    const receipt = await tx.wait();

    console.log("轉帳後餘額");
    const ownerBalanceAfter = await token.balanceOf(owner.address);
    const addr1BalanceAfter = await token.balanceOf(addr1.address);
    console.log("Owner 餘額:", ownerBalanceAfter.toString());
    console.log("Addr1 餘額:", addr1BalanceAfter.toString());

    console.log("\n交易 Receipt");
    console.log(receipt)

    console.log("\nEvent Logs");
    receipt.logs.forEach((log, index) => {
      console.log(`Log ${index}:`, log.data);
    });

    console.log("\n解析 Transfer Event");
    
    const iface = token.interface;
    for (const log of receipt.logs) {
      const parsed = iface.parseLog(log);
      if (parsed.name === "Transfer") {
      console.log("from :", parsed.args[0]);
      console.log("to   :", parsed.args[1]);
      console.log("value:", parsed.args[2].toString());
    }
  }
    console.log(owner.address)
    console.log(addr1.address)
    console.log("驗證結果");
    expect(ownerBalanceAfter).to.equal(500n);
    expect(addr1BalanceAfter).to.equal(500n);
    console.log("驗證成功");
  });
});