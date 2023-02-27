import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai"
import { ethers } from "hardhat";
import hre from "hardhat";
import { WorldCup } from "../typechain-types";

describe("WorldCup", function () {
    async function deployWorldcupFixture() {

        const [owner, otherAccount] = await ethers.getSigners();

        const WorldCup = await ethers.getContractFactory("WorldCup");
        const deadline = (await time.latest()) + TWO_WEEKS_IN_SECS;

        const worldcup = await WorldCup.deploy(deadline);
        return { worldcup, deadline, owner, otherAccount };
    }

    this.beforeEach(async () => {
        const { worldcup, owner, otherAccount, deadline } = await loadFixture(deployWorldcupFixture);
        worldcupIns = worldcup
        ownerAddr = owner.address
        otherAccountAddr = otherAccount.address
        deadline1 = deadline

    })
})

describe("Deployment", function () {
    it("Should set the right owner", async function () {
        const { worldcup, owner } = await loadFixture(deployWorldcupFixture);
        expect(await worldcupIns.admin()).to.equal(ownerAddr);
    });

    it("Should fail if the deadline is not in the future", async function (){
        const latestTime = await time.latest();
        const WorldCup = await ethers.getContractFactory("WorldCup");
        await expect(WorldCup.deploy(latestTime)).to.be.revertedWith(
            "WorldCupLotery: invalid deadline!"
        );
    });
})