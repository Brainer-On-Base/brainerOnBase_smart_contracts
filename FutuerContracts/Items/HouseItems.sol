// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HouseItems is ERC721, Ownable {
    uint256 public itemCounter;

    enum ItemType {
        Head,
        Armor,
        Potion
    }

    struct Item {
        ItemType itemType;
        address owner;
    }

    mapping(uint256 => Item) public items;

    constructor()
        Ownable(msg.sender)
        ERC721("BrainerCharacterItems", "BRAINERITEMS")
    {
        itemCounter = 0;
    }

    function mintItem(
        address recipient,
        ItemType itemType
    ) public onlyOwner returns (uint256) {
        uint256 newItemId = itemCounter;
        _safeMint(recipient, newItemId);

        // Registrar el nuevo item
        items[newItemId] = Item({itemType: itemType, owner: recipient});

        itemCounter += 1;
        return newItemId;
    }

    function transferItem(uint256 itemId, address newOwner) public {
        require(
            msg.sender == items[itemId].owner,
            "Only the owner can transfer the item."
        );

        // Actualizar la propiedad del item
        items[itemId].owner = newOwner;

        // Transferir el NFT
        _transfer(msg.sender, newOwner, itemId);
    }

    function getItem(uint256 itemId) public view returns (ItemType, address) {
        return (items[itemId].itemType, items[itemId].owner);
    }
}
