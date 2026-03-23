const { ethers } = require("hardhat");
require('dotenv').config();

async function main() {
    const provider = new ethers.JsonRpcProvider(`https://arb-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`);

    const privateKey = process.env.ARBITRUM_SEPOLIA_PRIVATE_KEY;
    const wallet = new ethers.Wallet(privateKey, provider);

  const contractAddress = "0xb02D924D83a177936c5131f6121299300224554f";
  const nft = await ethers.getContractAt("MyERC721", contractAddress, wallet);

  const tx = await nft.mint({
    value: ethers.parseEther("0.001"),
  });

  console.log("Mint tx:", tx.hash);
  await tx.wait();

  const balance = await nft.balanceOf(wallet.address);
  const supply = await nft.totalSupply();
  console.log("My NFT balance:", balance.toString());
  console.log("Total supply:", supply.toString());
}

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});