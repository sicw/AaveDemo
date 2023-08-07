import {
    time,
    loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import {anyValue} from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import {expect} from "chai";
import {ethers} from "hardhat";

describe("Reserve", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    // and reset Hardhat Network to that snapshot in every test.
    async function deployOneYearLockFixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, otherAccount] = await ethers.getSigners();

        const usdcToken = await ethers.getContractFactory("UsdcToken");
        const usdc = await usdcToken.deploy("USDC", "USDC");

        return {usdc};
    }

    describe("Deployment", function () {
        it("Should set the right unlockTime", async function () {
            const {usdc} = await loadFixture(deployOneYearLockFixture);
            console.log(usdc.getAddress);
        });
    });
});
