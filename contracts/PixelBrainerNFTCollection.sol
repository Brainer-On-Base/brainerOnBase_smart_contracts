// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title Pixel Brainer NFT Collection
/// @notice NFT contract that assigns a unique metadata URI to each token at mint time, randomly, without a reveal phase.
/// @dev Uses swap-and-pop to avoid duplicated URIs, each token is unique from the start.
contract PixelBrainerNFTCollection is ERC721, Ownable, ReentrancyGuard {
    // Current minted token counter
    uint256 public currentTokenId;

    // Max NFTs that can be minted
    uint256 public immutable maxSupply;

    // Mint price in wei
    uint256 public immutable mintPrice;

    // Mapping from token ID to its assigned metadata URI
    mapping(uint256 => string) private _tokenURIs;

    // Count of NFTs minted per wallet (max 2)
    mapping(address => uint256) public mintedTokensCount;

    // Pool of available URIs for random assignment
    mapping(uint256 => string) private _availableURIs;

    /// @notice Contract constructor
    /// @param _maxSupply Maximum number of NFTs allowed to mint
    /// @param _mintPrice Mint price per NFT in wei
    /// @param uris Array of metadata URIs to randomly assign, must match maxSupply
    constructor(
        uint256 _maxSupply,
        uint256 _mintPrice,
        string[] memory uris
    ) ERC721("PixelBrainerCollection", "PBC1") Ownable(msg.sender) {
        require(uris.length == _maxSupply, "URIs must match supply");

        maxSupply = _maxSupply;
        mintPrice = _mintPrice;

        for (uint256 i = 0; i < uris.length; i++) {
            _availableURIs[i] = uris[i];
        }
    }

    /// @notice Mints a new NFT with a randomly selected and unique metadata URI
    /// @dev Each wallet can mint up to 2 NFTs
    /// @param recipient Address that will receive the NFT
    function mintNFT(address recipient) public payable {
        require(currentTokenId < maxSupply, "Sold out");
        require(tx.origin == msg.sender, "Contracts not allowed");
        // require(mintedTokensCount[recipient] < 2, "Max 2 per wallet");
        require(msg.value >= mintPrice, "Insufficient founds");

        // Pseudo-random index based on timestamp, block randomness and counter
        uint256 randomIndex = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.prevrandao,
                    currentTokenId
                )
            )
        ) % (maxSupply - currentTokenId);

        string memory selectedURI = _availableURIs[randomIndex];

        // Swap-and-pop to remove used URI
        _availableURIs[randomIndex] = _availableURIs[
            maxSupply - currentTokenId - 1
        ];
        delete _availableURIs[maxSupply - currentTokenId - 1];

        // Mint the NFT
        currentTokenId++;
        _safeMint(recipient, currentTokenId);
        _tokenURIs[currentTokenId] = selectedURI;
        mintedTokensCount[recipient]++;
    }

    /// @notice Returns the metadata URI assigned to a token
    /// @param tokenId The ID of the NFT
    /// @return The token's metadata URI
    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(ownerOf(tokenId) != address(0), "Nonexistent token");
        return _tokenURIs[tokenId];
    }

    /// @notice Withdraws contract balance to a recipient
    /// @dev Only callable by the contract owner
    /// @param recipient Address to receive the contract's balance
    function withdrawFunds(
        address payable recipient
    ) public onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        recipient.transfer(balance);
    }

    /// @dev Prevents receiving ETH without calling mintNFT
    receive() external payable {
        revert("Direct ETH not accepted");
    }

    /// @dev Prevents fallback function calls
    fallback() external payable {
        revert("Invalid function");
    }
}
