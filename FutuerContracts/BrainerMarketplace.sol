// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BrainerNFTMarketplace is ReentrancyGuard, Ownable {
    struct Listing {
        address seller;
        uint256 price;
    }

    // Mappings para las listas de los NFTs
    mapping(address => mapping(uint256 => Listing)) public listings;
    mapping(address => bool) public allowedNFTContracts;

    // Array para almacenar los listings
    address[] public listedNFTContracts;
    mapping(address => uint256[]) public listedTokenIds;

    event NFTListed(
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        uint256 price
    );
    event NFTSold(
        address indexed nftContract,
        uint256 indexed tokenId,
        address buyer,
        uint256 price
    );
    event ListingRemoved(
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller
    );
    event NFTContractAllowed(address indexed nftContract, bool allowed);

    // Constructor para permitir contratos de NFT
    constructor() Ownable(msg.sender) {}

    // Función para permitir contratos de NFT
    function allowNFTContract(
        address nftContract,
        bool allowed
    ) external onlyOwner {
        allowedNFTContracts[nftContract] = allowed;
        emit NFTContractAllowed(nftContract, allowed);
    }

    // Función para listar un NFT
    function listNFT(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) external {
        require(
            allowedNFTContracts[nftContract],
            unicode"Este NFT no está permitido en el marketplace"
        );
        require(price > 0, unicode"El precio debe ser mayor a 0");

        IERC721 token = IERC721(nftContract);
        require(
            token.ownerOf(tokenId) == msg.sender,
            unicode"No eres el dueño del NFT"
        );
        require(
            token.getApproved(tokenId) == address(this),
            unicode"El contrato no está aprobado"
        );

        listings[nftContract][tokenId] = Listing(msg.sender, price);

        // Agregar al array listado
        listedTokenIds[nftContract].push(tokenId);
        if (listedTokenIds[nftContract].length == 1) {
            listedNFTContracts.push(nftContract);
        }

        emit NFTListed(nftContract, tokenId, msg.sender, price);
    }

    // Función para comprar un NFT
    function buyNFT(
        address nftContract,
        uint256 tokenId
    ) external payable nonReentrant {
        require(
            allowedNFTContracts[nftContract],
            unicode"Este NFT no está permitido en el marketplace"
        );

        Listing memory listing = listings[nftContract][tokenId];
        require(listing.price > 0, unicode"El NFT no está en venta");
        require(msg.value >= listing.price, unicode"Fondos insuficientes");

        // Transferir fondos al vendedor
        payable(listing.seller).transfer(msg.value);

        // Transferir NFT al comprador
        IERC721(nftContract).safeTransferFrom(
            listing.seller,
            msg.sender,
            tokenId
        );

        // Eliminar el listing
        delete listings[nftContract][tokenId];

        // Eliminar el token de la lista
        removeTokenFromListing(nftContract, tokenId);

        emit NFTSold(nftContract, tokenId, msg.sender, listing.price);
    }

    // Función para remover un NFT de la lista
    function removeListing(address nftContract, uint256 tokenId) external {
        require(
            allowedNFTContracts[nftContract],
            unicode"Este NFT no está permitido en el marketplace"
        );

        Listing memory listing = listings[nftContract][tokenId];
        require(
            listing.seller == msg.sender,
            unicode"No eres el dueño del listing"
        );

        delete listings[nftContract][tokenId];

        // Eliminar el token de la lista
        removeTokenFromListing(nftContract, tokenId);

        emit ListingRemoved(nftContract, tokenId, msg.sender);
    }

    // Función interna para eliminar un token de la lista
    function removeTokenFromListing(
        address nftContract,
        uint256 tokenId
    ) internal {
        uint256 length = listedTokenIds[nftContract].length;
        for (uint256 i = 0; i < length; i++) {
            if (listedTokenIds[nftContract][i] == tokenId) {
                // Mover el último elemento a la posición actual
                listedTokenIds[nftContract][i] = listedTokenIds[nftContract][
                    length - 1
                ];
                listedTokenIds[nftContract].pop();
                break;
            }
        }
        // Si no hay más tokens en este contrato, eliminar el contrato de la lista
        if (listedTokenIds[nftContract].length == 0) {
            for (uint256 i = 0; i < listedNFTContracts.length; i++) {
                if (listedNFTContracts[i] == nftContract) {
                    listedNFTContracts[i] = listedNFTContracts[
                        listedNFTContracts.length - 1
                    ];
                    listedNFTContracts.pop();
                    break;
                }
            }
        }
    }

    // Función para obtener todos los NFTs listados
    function getAllListedNFTs()
        external
        view
        returns (address[] memory, uint256[] memory)
    {
        uint256 totalListed = 0;
        for (uint256 i = 0; i < listedNFTContracts.length; i++) {
            totalListed += listedTokenIds[listedNFTContracts[i]].length;
        }

        address[] memory contracts = new address[](totalListed);
        uint256[] memory tokenIds = new uint256[](totalListed);

        uint256 index = 0;
        for (uint256 i = 0; i < listedNFTContracts.length; i++) {
            address nftContract = listedNFTContracts[i];
            uint256[] memory tokenIdsInContract = listedTokenIds[nftContract];
            for (uint256 j = 0; j < tokenIdsInContract.length; j++) {
                contracts[index] = nftContract;
                tokenIds[index] = tokenIdsInContract[j];
                index++;
            }
        }

        return (contracts, tokenIds);
    }
}
