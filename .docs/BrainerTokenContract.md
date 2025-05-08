## 🧠 BrainerToken – Smart Contract

An ERC20 token designed for the Brainer ecosystem, supporting play-to-earn, governance, marketing, and controlled supply mechanics.

---

### 📈 Overview

- 🤝 **Name**: Brainer Token
- ⚫ **Symbol**: BRNR
- 🔄 **Standard**: ERC20 + Burnable + Ownable (OpenZeppelin)
- ⚡ **Max Supply**: 10,000,000,000 BRNR
- ⚖️ **Governance ready**: Supports future DAO voting via staking
- 🌟 **Burnable**: Supports deflationary mechanics (burn from game)

---

### 🔧 Initial Distribution (at deployment)

| Destination          | Allocation | Description              |
| -------------------- | ---------- | ------------------------ |
| Deployer             | 55%        | Liquidity + markets      |
| Play to Earn / Burn  | 20%        | Incentives, rewards      |
| Staking & Governance | 10%        | Voting and staking pools |
| Developer Wallet     | 10%        | Core team                |
| Marketing Wallet     | 5%         | Promotions & awareness   |

All tokens are minted at deployment and distributed automatically.

---

### 📆 Constructor

```solidity
constructor(
  address _playToEarn,
  address _stakingGov,
  address _marketing,
  address _dev
)
```

- Validates all addresses
- Mints to each according to the distribution plan

---

### 💻 Public Functions

| Function                        | Access    | Description                        |
| ------------------------------- | --------- | ---------------------------------- |
| `mint(to, amount)`              | onlyOwner | Mints tokens up to `MAX_SUPPLY`    |
| `burnFromGame(account, amount)` | onlyOwner | Burns tokens from an address       |
| `transfer()`                    | public    | Standard ERC20 transfer            |
| `burn()` / `burnFrom()`         | public    | Token holders can burn voluntarily |

---

### ⛔ Supply Controls

- `MAX_SUPPLY` hard cap enforced in `mint()`
- All supply pre-allocated at launch
- Only owner can mint (with cap check)
- Anyone can burn their own tokens

---

### 🚀 Deployment (Hardhat Example)

```js
const factory = await ethers.getContractFactory("BrainerToken");
const token = await factory.deploy(
  "0xPlayToEarn",
  "0xStakingGov",
  "0xMarketing",
  "0xDeveloper"
);
```

---

### 📆 Future Ideas (optional)

- Add event `TokensBurnedFromGame`
- Integrate snapshot for DAO governance
- Add pausability for emergency cases

---

### 🏆 Audited by: Fede & ChatGPT v4

_Designed to fuel the Brainer economy. Mint, earn, burn, repeat._
