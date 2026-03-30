const { ethers } = require("hardhat");
require('dotenv').config();

async function main() {
    const provider = new ethers.JsonRpcProvider(`https://arb-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`);

    const privateKey = process.env.ARBITRUM_SEPOLIA_PRIVATE_KEY;
    const wallet = new ethers.Wallet(privateKey, provider);

    const ERC721_14_contractAddress = "0x6E875aD17d9932adb957242F491363C9e8Af64fc";
    const ERC721_14_nft = await ethers.getContractAt("ERC721_14", ERC721_14_contractAddress, wallet);

    const tx = await ERC721_14_nft.mint({
      value: ethers.parseEther("0.001"),
    });
  
    console.log("ERC721_14_nft_Mint tx:", tx.hash);
    await tx.wait();

    const balance = await ERC721_14_nft.balanceOf(wallet.address);
    const supply = await ERC721_14_nft.totalSupply();
    console.log("My NFT balance:", balance.toString());
    console.log("Total supply:", supply.toString());

    const ERC721A_14_contractAddress = "0x60Dc299a446B5cf8CE2cDe46060B7f34FB32E8F6";
    const ERC721A_14_nft = await ethers.getContractAt("ERC721A_14", ERC721A_14_contractAddress, wallet);

    const tx1 = await ERC721A_14_nft.mint(10,{
      value: ethers.parseEther("0.001"),
    });

    console.log("ERC721A_14_nft_Mint tx:", tx1.hash);
    await tx1.wait();

    const balance1 = await ERC721A_14_nft.balanceOf(wallet.address);
    const supply1 = await ERC721A_14_nft.totalSupply();
    console.log("My NFT balance:", balance1.toString());
    console.log("Total supply:", supply1.toString());
}

main().catch((err) => {
    console.error(err);
    process.exitCode = 1;
});