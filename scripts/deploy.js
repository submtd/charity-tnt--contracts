const Contract = require("./utils/Contract");
require("dotenv").config();
const factory = process.env.FACTORY || '';
const router = process.env.ROUTER || '';

const main = async () => {
    // Deploy AddressBook
    const addressbookContract = new Contract();
    const addressbook = await addressbookContract.deploy("AddressBook");
    console.log("Address book deployed to", addressbook.address);
    // Set Factory and Router addresses in AddressBook
    let tx = await addressbook.set("Factory", factory);
    await tx.wait();
    tx = await addressbook.set("Router", router);
    await tx.wait();
    const contract = new Contract(addressbook.address);
    // Deploy USDC
    const usdc = await contract.deploy("FakeToken", ["USD Coin", "USDC"]);
    console.log("USDC deployed to", usdc.address);
    // Deploy TNT
    const tnt  = await contract.deploy("TNT");
    console.log("TNT deployed to", tnt.address);
    // Deploy Presale
    const presale = await contract.deploy("Presale");
    console.log("Presale deployed to", presale.address);
    // Add presale to TNT minters
    // Allow presale to mint 1,375,000,000 TNT tokens max
    tx = await tnt.addMinter(presale.address, "2500000000000000000000000000");
    await tx.wait();
    console.log("Presale added to TNT minters");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
