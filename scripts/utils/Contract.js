const hre = require("hardhat");

class Contract {

    constructor(addressbookAddress = '') {
        this.addressbookAddress = addressbookAddress;
    }

    async deploy(name, args = []) {
        const ContractFactory = await hre.ethers.getContractFactory(name);
        const contract = await hre.upgrades.deployProxy(ContractFactory, args, { initializer: "initialize" });
        await contract.deployed();
        if(this.addressbookAddress != '') {
            const AddressBook = await hre.ethers.getContractFactory("AddressBook");
            const addressbook = AddressBook.attach(this.addressbookAddress);
            const tx1 = await addressbook.set(name, contract.address);
            await tx1.wait();
            const tx2 = await contract.setAddressBook(this.addressbookAddress);
            await tx2.wait();
        }
        return contract;
    }
}

module.exports = Contract;
