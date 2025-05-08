const { Wallet } = require("ethers");
const fs = require("fs");

const walletLabels = [
  "playToEarn",
  "stakingGov",
  "marketing",
  "development",
  "liquidity", // esta podés ignorarla si usás el deployer
];

const wallets = {};

walletLabels.forEach((label) => {
  const wallet = Wallet.createRandom();
  wallets[label] = {
    address: wallet.address,
    privateKey: wallet.privateKey,
  };
});

fs.writeFileSync("testWallets.json", JSON.stringify(wallets, null, 2));

console.log("✅ Wallets generadas:");
console.table(wallets);
