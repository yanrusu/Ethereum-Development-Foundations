const { ethers } = require("hardhat");

async function main() {
    const msg = "Hello world";
    const msg_bytes = ethers.toUtf8Bytes(msg);
    const wallet = ethers.Wallet.createRandom();
    const walletadderss = wallet.address;
    
    // const sign = await wallet.signMessage(msg_bytes); // 內建hash加EIP-191前綴辨識簽名
    // const addr = await ethers.verifyMessage(msg_bytes, sign);

    const hash_msg = ethers.keccak256(msg_bytes);
    const signature = wallet.signingKey.sign(hash_msg);  // 直接簽 hash 回傳物件
    const addr = ethers.recoverAddress(hash_msg, signature.serialized); //signature.serialized組合簽名
    
    console.log("recovered:", addr);
    console.log("wallet:", walletadderss);
    console.log("match:", addr === walletadderss);
}

main().catch(console.error);