const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();

  const balance = await deployer.provider.getBalance(deployer.address);

  console.log("🚀 Deploying with account:", deployer.address);
  console.log("💰 Balance:", ethers.formatEther(balance), "ETH");

  const PixelBrainerCollection = await ethers.getContractFactory(
    "PixelBrainerNFTCollection"
  );

  // 🔧 Parámetros del contrato
  const maxSupply = 50;
  const mintPrice = ethers.parseEther("0.001"); // 0.001 ETH

  // 🔧 URI base (¡terminar en /!)
  const baseURI =
    "https://braineronbase.com/ipfs/QmbdtLbzVDjc8gqy6UjxCmBK2niTTW7FGs2RLiXxZYDmMM/";

  // 🚀 Crear array de URIs
  const uris = Array.from(
    { length: maxSupply },
    (_, i) => `${baseURI}${i}.json`
  );

  const pixelBrainer = await PixelBrainerCollection.deploy(
    maxSupply,
    mintPrice,
    uris
  );

  await pixelBrainer.waitForDeployment();

  console.log("✅ Contract deployed at:", pixelBrainer.target);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  });
