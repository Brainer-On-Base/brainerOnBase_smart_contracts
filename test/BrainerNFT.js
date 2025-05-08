const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PixelBrainerCollection", function () {
    let PixelBrainerCollection, pixelBrainerCollection;
    let owner, addr1, addr2;

    const MAX_SUPPLY = 5;
    const TOKEN_URI = "https://example.com/metadata/";

    before(async function () {
        [owner, addr1, addr2] = await ethers.getSigners();
        PixelBrainerCollection = await ethers.getContractFactory("PixelBrainerCollection");
        pixelBrainerCollection = await PixelBrainerCollection.deploy(MAX_SUPPLY);
        await pixelBrainerCollection.deployed();
    });

    it("Should set the correct max supply", async function () {
        expect(await pixelBrainerCollection.maxSupply()).to.equal(MAX_SUPPLY);
    });

    it("Should mint an NFT and set correct token URI", async function () {
        await pixelBrainerCollection.mintNFT(addr1.address, `${TOKEN_URI}1`);
        expect(await pixelBrainerCollection.currentTokenId()).to.equal(1);
        expect(await pixelBrainerCollection.tokenURI(1)).to.equal(`${TOKEN_URI}1`);
    });

    it("Should only allow owner to mint NFTs", async function () {
        await expect(
            pixelBrainerCollection.connect(addr1).mintNFT(addr1.address, `${TOKEN_URI}2`)
        ).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("Should not mint more NFTs than max supply", async function () {
        for (let i = 2; i <= MAX_SUPPLY; i++) {
            await pixelBrainerCollection.mintNFT(addr1.address, `${TOKEN_URI}${i}`);
        }
        await expect(
            pixelBrainerCollection.mintNFT(addr1.address, `${TOKEN_URI}${MAX_SUPPLY + 1}`)
        ).to.be.revertedWith("Max supply reached");
    });

    it("Should return the correct token URI for each minted NFT", async function () {
        for (let i = 1; i <= MAX_SUPPLY; i++) {
            expect(await pixelBrainerCollection.tokenURI(i)).to.equal(`${TOKEN_URI}${i}`);
        }
    });

    it("Should fail when querying token URI for nonexistent token", async function () {
        await expect(pixelBrainerCollection.tokenURI(MAX_SUPPLY + 1)).to.be.revertedWith(
            "ERC721Metadata: URI query for nonexistent token"
        );
    });
});
