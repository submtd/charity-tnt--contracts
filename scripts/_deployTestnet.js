const hre = require("hardhat");
const Contract = require("./utils/Contract");
require("dotenv").config();
const router = process.env.ROUTER || '';
const factory = process.env.FACTORY || '';
const safe = process.env.SAFE || '';

const main = async () => {
    console.log("ROUTER_ADDRESS=", router);
    console.log("FACTORY_ADDRESS=", factory);
    console.log("SAFE_ADDRESS=", safe);
    let contract = new Contract();
    // Deploy AddressBook
    const addressbook = await contract.deploy("AddressBook");
    console.log("ADDRESSBOOK_ADDRESS=" + addressbook.address);
    // Set addresses
    let tx = await addressbook.set("router", router);
    await tx.wait();
    tx = await addressbook.set("factory", factory);
    await tx.wait();
    tx = await addressbook.set("safe", safe);
    await tx.wait();
    // Re instantiate contract with new addressbook
    contract = new Contract(addressbook.address);
    // Deploy TNT
    const tnt = await contract.deploy("TNT", "tnt");
    console.log("TNT_ADDRESS=" + tnt.address);
    // Deploy USDC
    const usdc = await contract.deploy("FakeUSDC", "usdc");
    console.log("USDC_ADDRESS=" + usdc.address);
    // Deploy Pool
    const pool = await contract.deploy("Pool", "pool");
    console.log("POOL_ADDRESS=" + pool.address);
    // Deploy Swap
    const swap = await contract.deploy("TNTSwap", "swap");
    console.log("SWAP_ADDRESS=" + swap.address);
    // Deploy Tax Handler
    const taxhandler = await contract.deploy("TaxHandler", "taxHandler");
    console.log("TAX_HANDLER_ADDRESS=" + taxhandler.address);
    console.log("setting up TNT");
    tx = await tnt.setup();
    await tx.wait();
    console.log("setting up USDC");
    tx = await usdc.setup();
    await tx.wait();
    console.log("setting up Pool");
    tx = await pool.setup();
    await tx.wait();
    console.log("setting up Swap");
    tx = await swap.setup();
    await tx.wait();
    console.log("minting TNT to Pool");
    tx = await tnt.mint(pool.address, "612500000000000000000000000");
    await tx.wait();
    console.log("minting usdc to Pool");
    tx = await usdc.mint(pool.address, "30625000000000000000000000");
    await tx.wait();
    console.log("creating liquidity pool");
    tx = await pool.createLiquidity();
    await tx.wait();
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
