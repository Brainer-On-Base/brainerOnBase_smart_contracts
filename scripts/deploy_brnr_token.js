const { ethers } = require("hardhat");

async function main() {
  const BrainerToken = await ethers.getContractFactory("BrainerToken");

  const wallets = {
    playToEarn: "0x70b803984f24b342C79a3E1F453eC43EA25f42ed",
    stakingGov: "0x68b95A90b6954Fb263170dB15717217cD0f2a685",
    marketing: "0x31D847b151e0b3aD4951F29d57dE204ABc28Dec3",
    development: "0x1084A9BdA7aBd0b9a2bC46341C6b27735CAbC659",
  };

  const [deployer] = await ethers.getSigners();
  const balance = await deployer.provider.getBalance(deployer.address);

  console.log("Deploying with:", deployer.address);
  console.log("Balance:", ethers.formatEther(balance), "ETH");

  const token = await BrainerToken.deploy(
    wallets.playToEarn,
    wallets.stakingGov,
    wallets.marketing,
    wallets.development
  );

  await token.waitForDeployment();
  console.log("✅ BrainerToken deployed at:", token.target);
}

main().catch((error) => {
  console.error("❌ Error deploying BrainerToken:", error);
  process.exit(1);
});
