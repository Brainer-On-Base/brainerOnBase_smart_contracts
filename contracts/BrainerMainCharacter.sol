// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

/// @title Brainer Main Character NFT
/// @notice Represents the main playable character in the Brainer Society game.
///         Only one per wallet. Users can mint by owning a Pixel Brainer NFT,
///         holding at least 0.02 ETH worth of $BRNR, or paying 0.02 ETH directly.
contract BrainerMainCharacter is ERC721, Ownable, ReentrancyGuard {
    uint256 public constant MINT_PRICE = 0.02 ether;
    uint256 public tokenIdCounter;

    IERC20 public brnrToken;
    IERC721 public pixelBrainerNFT;

    mapping(address => bool) public hasMinted;

    string private baseTokenURI;
    bool public mintingPaused = true; // Minting is paused by default

    event CharacterMinted(address indexed user, uint256 indexed tokenId);
    event MintingPaused();
    event MintingResumed();

    constructor(
        address _brnrToken,
        address _pixelBrainerNFT,
        string memory _baseURI
    ) ERC721("Brainer Main Character", "BMC") Ownable(msg.sender) {
        require(_brnrToken != address(0), "Invalid BRNR token address");
        require(
            _pixelBrainerNFT != address(0),
            "Invalid Pixel Brainer NFT address"
        );
        brnrToken = IERC20(_brnrToken);
        pixelBrainerNFT = IERC721(_pixelBrainerNFT);
        baseTokenURI = _baseURI;
    }

    /// @notice Pauses the minting functionality (owner only)
    function pauseMinting() external onlyOwner {
        mintingPaused = true;
        emit MintingPaused();
    }

    /// @notice Resumes the minting functionality (owner only)
    function resumeMinting() external onlyOwner {
        mintingPaused = false;
        emit MintingResumed();
    }

    /// @notice Allows a user to mint their Main Character NFT under one of 3 conditions
    function mintCharacter() external payable nonReentrant {
        require(!mintingPaused, "Minting is currently paused");
        require(tx.origin == msg.sender, "Contracts not allowed");
        require(!hasMinted[msg.sender], "You already minted your character");

        bool ownsPixelNFT = pixelBrainerNFT.balanceOf(msg.sender) > 0;
        bool holdsBRNR = brnrToken.balanceOf(msg.sender) >= MINT_PRICE;

        // Require at least one condition to mint
        require(
            ownsPixelNFT || holdsBRNR || msg.value >= MINT_PRICE,
            "You must own a Pixel Brainer, hold 0.02 ETH in BRNR or pay 0.02 ETH"
        );

        tokenIdCounter++;
        _safeMint(msg.sender, tokenIdCounter);
        hasMinted[msg.sender] = true;

        emit CharacterMinted(msg.sender, tokenIdCounter);
    }

    /// @notice Sets the base URI for token metadata
    /// @param _newBaseURI The new base URI
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseTokenURI = _newBaseURI;
    }

    /// @notice Returns the full token URI for a given token
    /// @param tokenId ID of the NFT
    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(ownerOf(tokenId) != address(0), "Nonexistent token");
        return
            string(abi.encodePacked(baseTokenURI, _toString(tokenId), ".json"));
    }

    /// @notice Withdraws all ETH from the contract to the owner
    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    /// @notice Utility to convert uint to string
    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /// @notice Prevents accidental ETH deposits
    receive() external payable {
        revert("ETH not accepted directly");
    }

    fallback() external payable {
        revert("Invalid function");
    }
}
