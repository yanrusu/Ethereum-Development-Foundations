require('dotenv').config();
const { ethers } = require("hardhat");

const contractaddr = "0xdAC17F958D2ee523a2206206994597C13D831ec7";
const contractABI = ["event Transfer(address indexed from, address indexed to, uint256 value)"];
const fromblock = 24230331
const toblock = 24230332

async function main(){
    const provider = new ethers.JsonRpcProvider(`https://eth-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`);
    const contract = new ethers.Contract(contractaddr,contractABI,provider);
    const log = await contract.queryFilter(contract.filters.Transfer(null, null),fromblock,toblock);
    // const log = await contract.queryFilter("Transfer",fromblock,toblock)
    console.log("From:", log[0].args[0], "To:", log[0].args[1], "Value:", Number(log[0].args[2]/1000000n));
    console.log(log.length);

    // const iface = new ethers.Interface(contractABI);
    // const from = "0x3C02290922a3618A4646E3BbCa65853eA45FE7C6";
    // const to = "0xFAdEf4c677C2f31F43f09e239b34D0F6905a3085"
    // const filter = {
    // address: contractaddr,
    // topics: [
    //     iface.getEvent("Transfer").topicHash, 
    //     ethers.zeroPadValue(from, 32),
    //     ethers.zeroPadValue(to, 32),
    // ],
    //     fromBlock: fromblock,
    //     toBlock: toblock
    // };

    // const log = await provider.getLogs(filter);
    // console.log(log[0]);
    // console.log(Number(log[0].data) / 1e6);

    


}
// main().catch(console.error);   

async function listen() {
    const provider = new ethers.WebSocketProvider(`https://eth-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`);
    const contract = new ethers.Contract(contractaddr,contractABI,provider);
    contract.on('Transfer', (from, to, value, event) => {
    console.log({
      from,
      to,
      value: ethers.formatUnits(value, 6), 
      blockNumber: event.log.blockNumber,
      txHash: event.log.transactionHash
    });
  });

}
listen().catch(console.error)