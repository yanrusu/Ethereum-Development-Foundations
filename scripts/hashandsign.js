const { ethers } = require("hardhat");

async function main() {
    const msg = "Hello world";
    const msg_bytes = ethers.toUtf8Bytes(msg);
    const hash_msg = ethers.keccak256(msg_bytes);
    const wallet = ethers.Wallet.createRandom();
    const walletadderss = wallet.address;
    
    const sign = await wallet.signMessage(hash_msg);
    const addr = await ethers.verifyMessage(hash_msg, sign);
    
    console.log("recovered:", addr);
    console.log("wallet:", walletadderss);
    console.log("match:", addr === walletadderss);
}

main().catch(console.error);