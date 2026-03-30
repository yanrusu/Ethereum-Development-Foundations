const { ethers } = require("hardhat");

async function main() {
    const ERC_721_Token = await ethers.getContractFactory("ERC721_14");
    const ERC721_token = await ERC_721_Token.deploy();
    console.log(`ERC_721_Token deployed at: ${ERC721_token.target}`);
    const ERC_721A_Token = await ethers.getContractFactory("ERC721A_14");
    const ERC721A_token = await ERC_721A_Token.deploy();
    console.log(`ERC_721A_Token deployed at: ${ERC721A_token.target}`);
    
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
