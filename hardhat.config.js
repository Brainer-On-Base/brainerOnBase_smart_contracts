require("dotenv").config();
require("@nomicfoundation/hardhat-ethers");
require("hardhat-deploy");

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.20",
      },
      {
        version: "0.8.0", // Incluye esta línea solo si necesitas compilar contratos con esta versión específica
      },
    ],
  },
  networks: {
    ethTestnet: {
      url: "https://rpc.ankr.com/eth_sepolia",
      accounts: [`0x${process.env.PRIVATE_KEY}`],
    },
    baseTestnet: {
      url: "https://sepolia.base.org",
      accounts: [`0x${process.env.PRIVATE_KEY}`],
    },
    baseMainnet: {
      url: "https://mainnet.base.org",
      accounts: [`0x${process.env.PRIVATE_KEY}`],
    },
  },
};
