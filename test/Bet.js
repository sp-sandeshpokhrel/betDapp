const { expect } = require("chai");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { ethers } = require("hardhat");


describe("Bet", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deploy() {

    const Bet = await ethers.getContractFactory("Bet");
    const bet = await Bet.deploy();

    return { bet };
  }

  describe("createEvent function test", function () {
    it("Should push a event to array events at 0 index", async function () {
      const { bet } = await loadFixture(deploy);
      await bet.createEvent("1");
      const id = await bet.eventsId(0)

      expect(id.toString()).to.equal("1");
    });


    it("Should initialize struct value to true", async function () {
      const { bet } = await loadFixture(deploy);
      await bet.createEvent("1");
      const st = await bet.eventCheck("1");

      expect(st).to.equal(true);
    });

  });


  describe("betNow function test", function () {
    it("Should set win of default account to 1 ether", async function () {
      const { bet } = await loadFixture(deploy);
      await bet.createEvent("1");
      await bet.betNow(0, "1", { "value": ethers.utils.parseUnits("1".toString(), "ether") });
      const wins = await bet.getBetArray(0, "1");

      expect(wins[0].amount).to.equal(ethers.utils.parseUnits("1".toString(), "ether"));
    });



  });

});
