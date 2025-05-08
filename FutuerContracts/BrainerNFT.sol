// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BrainerNFT is ERC721, Ownable {
    uint256 public tokenCounter;

    constructor() Ownable(msg.sender) ERC721("BrainerNFT", "BRAINER") {
        tokenCounter = 0;
    }

    function mintNFT(address recipient) public onlyOwner returns (uint256) {
        uint256 newItemId = tokenCounter;
        _safeMint(recipient, newItemId);
        tokenCounter += 1;
        return newItemId;
    }
}
