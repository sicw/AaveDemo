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

        const usdcTokenReserveToken = await ethers.getContractFactory("UsdcTokenReserve");
        const usdcTokenReserve = await usdcTokenReserveToken.deploy();

        return {usdc, usdcTokenReserve};
    }

    describe("Deployment", function () {
        it("Should set the right unlockTime", async function () {
            const {usdc, usdcTokenReserve} = await loadFixture(deployOneYearLockFixture);
            await usdcTokenReserve.setUsdcAddress(await  usdc.getAddress());
            usdcTokenReserve.supply(10);
        });
    });
});
