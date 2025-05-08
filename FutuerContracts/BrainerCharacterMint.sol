// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PixelBrainerCollection is ERC721, Ownable {
    uint256 public currentTokenId;
    uint256 public maxSupply;
    uint256 public mintPrice = 0.02 ether;

    // Map to store metadata URI for each token
    mapping(uint256 => string) private _tokenURIs;

    // Evento para registrar cuando se mintea un NFT
    event NFTMinted(
        address indexed recipient,
        uint256 tokenId,
        string tokenURI,
        string message
    );

    // Constructor que llama correctamente al constructor de ERC721 con el nombre y símbolo del token
    constructor(
        uint256 _maxSupply
    ) ERC721("PixelBrainerCollection", "PBC1") Ownable(msg.sender) {
        maxSupply = _maxSupply;
    }

    function mintNFT(
        address recipient,
        string memory tokenURI
    ) external payable {
        require(currentTokenId < maxSupply, "Max supply reached");
        require(msg.value >= mintPrice, "Insufficient funds");

        currentTokenId++;
        _safeMint(recipient, currentTokenId);
        _setTokenURI(currentTokenId, tokenURI);

        // Emitir el evento NFTMinted con los detalles del NFT minteado
        emit NFTMinted(
            recipient,
            currentTokenId,
            tokenURI,
            "New Pixel Brainer 1st Collection Minted"
        );
    }

    // Function to set the token URI for a given token ID
    function _setTokenURI(uint256 tokenId, string memory tokenURI) internal {
        require(
            _tokenExists(tokenId),
            "ERC721Metadata: URI set of nonexistent token"
        );
        _tokenURIs[tokenId] = tokenURI;
    }

    // Custom function to check token existence using ownerOf
    function _tokenExists(uint256 tokenId) internal view returns (bool) {
        try this.ownerOf(tokenId) returns (address) {
            return true;
        } catch {
            return false;
        }
    }

    // Override tokenURI function to return the token-specific URI
    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(
            _tokenExists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return _tokenURIs[tokenId];
    }
}
