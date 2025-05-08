// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CharacterItems is ERC721, Ownable {
    uint256 public itemCounter;

    enum ItemType {
        Head,
        Armor,
        Potion
    }

    struct Item {
        ItemType itemType;
        address owner;
        uint256 price;
        bool isForSale;
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
        items[newItemId] = Item({
            itemType: itemType,
            owner: recipient,
            price: 0,
            isForSale: false
        });

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

    function putItemForSale(uint256 itemId, uint256 price) public {
        require(ownerOf(itemId) == msg.sender, "You do not own this item");
        require(price > 0, "Price must be greater than zero");

        items[itemId].price = price;
        items[itemId].isForSale = true;
    }

    function buyItem(uint256 itemId) public payable {
        require(items[itemId].isForSale, "Item is not for sale");
        require(msg.value >= items[itemId].price, "Insufficient funds");

        address seller = ownerOf(itemId);
        _transfer(seller, msg.sender, itemId);

        // Transferir el pago al vendedor
        payable(seller).transfer(msg.value);

        // Marcar el item como no disponible
        items[itemId].isForSale = false;
    }
}
