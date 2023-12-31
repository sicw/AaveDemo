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

        const usdtToken = await ethers.getContractFactory("UsdtToken");
        const usdt = await usdcToken.connect(otherAccount).deploy("USDT", "USDT");

        const assetReserveFactory = await ethers.getContractFactory("AssetReserve");
        const assetReserve = await assetReserveFactory.deploy();


        console.log("owner: " + await owner.getAddress());
        console.log("other: " + await otherAccount.getAddress());
        console.log("usdc: " + await usdc.getAddress());
        console.log("usdt: " + await usdt.getAddress());
        console.log("assetReserve: " + await assetReserve.getAddress());
        return {usdc, usdt, assetReserve};
    }

    describe("Deployment", function () {
        it.skip("supply & withdraw", async function () {
            const {usdc, usdt, assetReserve} = await loadFixture(deployOneYearLockFixture);
            const usdcAddress = await usdc.getAddress();
            const usdtAddress = await usdt.getAddress();
            const assetReserveAddress = await assetReserve.getAddress();

            // 授权给transferFrom中的to地址
            await usdc.approve(assetReserveAddress, 20);
            // 存钱
            assetReserve.supply(usdcAddress, 10);
            assetReserve.supply(usdcAddress, 10);

            // 取钱
            assetReserve.withdraw(usdcAddress, 10);
            assetReserve.withdraw(usdcAddress, 10);
        });

        it.skip("borrow", async function () {
            const {usdc, usdt, assetReserve} = await loadFixture(deployOneYearLockFixture);
            const [owner, otherAccount] = await ethers.getSigners();
            const usdcAddress = await usdc.getAddress();
            const usdtAddress = await usdt.getAddress();
            const assetReserveAddress = await assetReserve.getAddress();

            // 授权给transferFrom中的to地址
            await usdc.approve(assetReserveAddress, 20);
            await usdt.connect(otherAccount).approve(assetReserveAddress, 20);

            // 存钱
            assetReserve.supply(usdcAddress, 20);
            assetReserve.connect(otherAccount).supply(usdtAddress, 20);

            // 借钱
            assetReserve.borrow(usdtAddress, usdcAddress, 5);
        });

    });
});
