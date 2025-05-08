const { ethers } = require("hardhat");
const {
  BRAINER_TOKEN_ADDRESS,
  PIXEL_BRAINER_COLLECCTION_ADDRESS,
} = require("../CONSTANTS");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);

  // Usamos el nombre calificado completo para evitar el error HH701
  const brnrToken = await ethers.getContractAt(
    "@openzeppelin/contracts/token/ERC20/IERC20.sol:IERC20",
    BRAINER_TOKEN_ADDRESS
  );

  const preSaleFactory = await ethers.getContractFactory("BrainerPreSale");

  const preSale = await preSaleFactory.deploy(
    BRAINER_TOKEN_ADDRESS,
    PIXEL_BRAINER_COLLECCTION_ADDRESS
  );
  await preSale.waitForDeployment();

  const preSaleAddress = await preSale.getAddress();
  console.log("BrainerPreSale deployed at:", preSaleAddress);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
