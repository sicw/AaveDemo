import {
    time,
    loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import {anyValue} from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import {expect} from "chai";
import {ethers} from "hardhat";
import {parseEther} from "ethers";

describe("Lending Pool", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.
    async function deployLendingPoolFixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, otherAccount] = await ethers.getSigners();

        const lendingPoolFactory = await ethers.getContractFactory("LendingPool");
        const lendingPool = await lendingPoolFactory.deploy();

        const coreLibraryFactory = await ethers.getContractFactory("CoreLibrary");
        const coreLibrary = await coreLibraryFactory.deploy();

        const lendingPoolCoreFactory = await ethers.getContractFactory("LendingPoolCore", {
            libraries: {
                CoreLibrary: await coreLibrary.getAddress(),
            }
        });
        const lendingPoolCore = await lendingPoolCoreFactory.deploy();

        const usdcTokenFactory = await ethers.getContractFactory("UsdcToken");
        const usdcToken = await usdcTokenFactory.deploy();

        const lendingPoolAddressesProviderFactory = await ethers.getContractFactory("LendingPoolAddressesProvider");
        const lendingPoolAddressesProvider = await lendingPoolAddressesProviderFactory.deploy();

        const lendingPoolAddressesProviderAddress = await lendingPoolAddressesProvider.getAddress();
        const usdcTokenAddress = await usdcToken.getAddress();
        const aTokenFactory = await ethers.getContractFactory("AToken");
        const aToken = await aTokenFactory.deploy(lendingPoolAddressesProviderAddress, usdcTokenAddress, 18, "AUSDC", "AUSDC");

        return {lendingPool, lendingPoolCore, usdcTokenAddress, lendingPoolAddressesProvider, aToken};
    }

    describe("logic", function () {
        it("deposit", async function () {
            const {lendingPool, lendingPoolCore, usdcTokenAddress, lendingPoolAddressesProvider, aToken} = await loadFixture(deployLendingPoolFixture);
            lendingPool.deposit(usdcTokenAddress, 10000, 0);
        });
    });
});
