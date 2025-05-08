## 🧠 BrainerPreSale – Smart Contract

A smart contract for managing the presale of the $BRNR token and token claims via NFT ownership.

---

### 📎 Overview

- 🧱 **Type**: Presale + NFT-based airdrop claim
- ✨ **Token**: $BRNR (ERC20)
- 💼 **NFT Collection**: Interface to validate ownership and claims
- 💵 **Presale Supply**: 1,000,000,000 $BRNR
- 🎁 **Claim Supply**: 500,000,000 $BRNR (100,000 per NFT)
- 🔢 **Rate**: 1 ETH = 4,000,000 $BRNR
- 💸 **Contribution**: Min 0.02 ETH, Max 5 ETH per wallet

---

### 🔧 Deployment Constructor

```solidity
constructor(address _tokenAddress, address _nftAddress)
```

- `_tokenAddress`: Address of the $BRNR ERC20 token
- `_nftAddress`: Address of the NFT collection used for claiming

---

### 💻 Public Functions

| Function                | Description                                            |
| ----------------------- | ------------------------------------------------------ |
| `buyTokens()`           | Allows users to buy $BRNR with ETH (based on rate)     |
| `claimForNFT(tokenId)`  | Allows NFT holder to claim 100k $BRNR per token (once) |
| `withdrawETH(amount)`   | Owner can withdraw collected ETH                       |
| `depositTokens(amount)` | Owner deposits $BRNR into contract (emits event)       |

### 📅 ETH Handling

- `receive()` triggers `buyTokens()` if ETH sent directly
- `fallback()` reverts any unexpected function calls

---

### 🔒 Security & Validations

- `onlyOwner` modifier to restrict admin actions
- Prevents over-contribution per wallet
- Prevents NFT double-claiming
- Ensures presale supply isn't exceeded
- Validates all `ERC20.transfer()` and `transferFrom()` return values
- Emits events for all relevant actions

---

### 🎁 Events

- `TokensPurchased(buyer, ethAmount, tokenAmount)`
- `WithdrawETH(admin, amount)`
- `WithdrawTokens(admin, amount)`
- `NFTClaimed(user, tokenId, amount)`
- `TokensDeposited(from, amount)`

---

### ⚡ Recommended Practices

- Deposit enough tokens before activating presale
- Monitor `tokensSold` and `nftClaimedTotal` to track distribution
- No function to recover unsold tokens: assumes full sellout
- Transparent ETH handling via `withdrawETH()`

---

### 🚀 Deployment (Hardhat Example)

```js
const factory = await ethers.getContractFactory("BrainerPreSale");
const contract = await factory.deploy(
  "0xTokenAddress",
  "0xNFTCollectionAddress"
);
```

---

### 🏆 Audited by: MasterBrainer & ChatGPT v4 🚀

_Built for brainer believers. Sold out or nothing._
