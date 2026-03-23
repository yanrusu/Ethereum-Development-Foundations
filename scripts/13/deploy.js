const { ethers } = require("hardhat");

async function main() {
    const Token = await ethers.getContractFactory("MyERC721");
    const token = await Token.deploy();
    console.log(`Token deployed at: ${token.target}`);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
