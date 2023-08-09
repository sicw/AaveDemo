import {
    time,
    loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import {anyValue} from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import {expect} from "chai";
import {ethers} from "hardhat";
import {parseEther} from "ethers";

describe("Reserve", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.
    async function deployOneYearLockFixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, otherAccount] = await ethers.getSigners();

        const usdcToken = await ethers.getContractFactory("UsdcToken");
        const usdc = await usdcToken.deploy("USDC", "USDC");

        const assetReserveFactory = await ethers.getContractFactory("AssetReserve");
        const assetReserve = await assetReserveFactory.deploy();


        console.log("owner: " + await owner.getAddress());
        console.log("usdc: " + await usdc.getAddress());
        console.log("assetReserve: " + await assetReserve.getAddress());
        return {usdc, assetReserve};
    }

    describe("Deployment", function () {
        it("Should set the right unlockTime", async function () {
            const {usdc, assetReserve} = await loadFixture(deployOneYearLockFixture);
            await assetReserve.setUsdcAddress(await  usdc.getAddress());

            await usdc.approve(await assetReserve.getAddress(), 20);
            // 存钱
            assetReserve.supply(10);
            assetReserve.supply(10);

            // 取钱
            assetReserve.withdraw(10);
            assetReserve.withdraw(10);
        });
    });
});
