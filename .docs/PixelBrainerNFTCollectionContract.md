# 🧠 PixelBrainerNFTCollection – Smart Contract

ERC-721 NFT collection con minteo limitado, URIs únicas desde el deploy, sin fase de reveal y con protección antibots.  
Contrato simple, sólido y listo para producción.

---

## 📌 Descripción General

- 🔗 **Nombre**: PixelBrainerCollection
- 🧠 **Símbolo**: PBC1
- 🧪 **Estándar**: ERC721 (OpenZeppelin)
- 🧱 **Supply máximo**: `maxSupply` NFTs únicos
- 🌐 **Metadata**: URIs asignadas aleatoriamente desde el constructor (sin reveal)
- 💰 **Precio de mint**: Fijo (`mintPrice`)
- ⛔ **Límite**: Máximo 2 NFTs por wallet
- 🛑 **Antibots**: No permite mintear desde contratos
- 🔐 **Owner**: Puede retirar los fondos
- 🔒 **Seguridad**: Protegido con `ReentrancyGuard`
- 🧯 **Auto-stop**: El mint se desactiva automáticamente al alcanzar el límite

---

## ⚙️ Constructor

```solidity
constructor(
  uint256 _maxSupply,
  uint256 _mintPrice,
  string[] memory uris
)
```

- `maxSupply`: Total máximo de NFTs a emitir
- `mintPrice`: Precio por NFT en wei
- `uris`: Array de URIs únicas (debe coincidir en cantidad con `maxSupply`)

---

## 💻 Funciones Públicas

| Función                  | Descripción                                                 |
| ------------------------ | ----------------------------------------------------------- |
| `mintNFT(address)`       | Minterea un NFT para la address indicada (máx 2 por wallet) |
| `tokenURI(uint256)`      | Devuelve la URI asignada al token                           |
| `withdrawFunds(address)` | Owner puede retirar el balance del contrato                 |

---

## 🔐 Restricciones y Seguridad

- ✅ **EOAs only**: Solo wallets externas pueden interactuar (`tx.origin == msg.sender`)
- ✅ **Limitado**: Cada wallet puede mintear hasta 2 NFTs
- ✅ **Fondos**: Solo el owner puede retirar el balance del contrato
- ✅ **Anti-spam**: Rechaza ETH directo y llamadas a funciones inexistentes
- ✅ **Randomización**: Swap-and-pop para asignar URIs únicas sin repetición

---

## 🛑 Recepción de ETH

- ❌ `receive()` revertido: evita que se mande ETH sin intención
- ❌ `fallback()` revertido: bloquea llamadas a funciones inválidas

---

## 🚀 Deployment (ejemplo con Hardhat)

```bash
npx hardhat run scripts/deploy.js --network base
```

```js
const factory = await ethers.getContractFactory("PixelBrainerNFTCollection");
const contract = await factory.deploy(
  5000,
  ethers.parseEther("0.02"), // 0.01 ETH
  metadataURIsArray
);
```

---

## 🧬 Futuras mejoras (opcional)

- 🔥 Función de `burn` para NFTs
- 🕹 Integración con minijuegos o avatares personalizables
- 📦 Reveal opcional (si se decide hacer una versión 2)

---

## ✅ Auditado por: Fede & ChatGPT v4 😎

> _No brain, no gain. Mint like a real Brainer._
