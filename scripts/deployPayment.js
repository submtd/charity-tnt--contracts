const { ethers } = require("hardhat");
require("dotenv").config();

const addressBook = process.env.ADDRESS_BOOK || '';

async function main() {
    const Payment = await ethers.getContractFactory("Payment");
    const payment = await Payment.deploy();
    const AddressBook = await ethers.getContractFactory("AddressBook");
    const addressbook = await AddressBook.attach(addressBook);
    await addressbook.set('payment', payment.address);
    console.log("Payment deployed to:", payment.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
