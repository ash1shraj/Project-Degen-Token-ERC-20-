// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GameToken is ERC20, Ownable {
    struct GameItem {
        string itemName; // New field for item name
        uint256 price;
        uint256 stock;
    }

    mapping(uint256 => GameItem) public gameItems;
    uint256 public itemCount;

    constructor(address initialOwner) ERC20("GameToken", "GAME") Ownable(initialOwner) {
        _mint(initialOwner, 1000); // Initial supply: 1,000
    }

    function mintTokens(address recipient, uint256 amount) public onlyOwner {
        _mint(recipient, amount);
    }

    function transferTokens(address to, uint256 amount) public {
        require(to != address(0), "Invalid recipient address");
        _transfer(msg.sender, to, amount);
    }

    function redeemTokens(uint256 amount) public {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _burn(msg.sender, amount);
    }

    function checkTokenBalance(address account) public view returns (uint256) {
        return balanceOf(account);
    }

    function burnTokens(uint256 amount) public {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        _burn(msg.sender, amount);
    }

    function addItemToStore(string memory itemName, uint256 price, uint256 stock) public onlyOwner {
        require(price > 0, "Price must be greater than 0");
        require(stock > 0, "Stock must be greater than 0");
        itemCount++;
        gameItems[itemCount] = GameItem(itemName, price, stock);
    }

    function getStoreItems() public view returns (GameItem[] memory) {
        GameItem[] memory items = new GameItem[](itemCount);
        for (uint256 i = 1; i <= itemCount; i++) {
            items[i - 1] = gameItems[i];
        }
        return items;
    }

    function redeemItem(uint256 itemId) public {
        require(itemId > 0 && itemId <= itemCount, "Invalid item ID");
        GameItem storage item = gameItems[itemId];
        require(item.stock > 0, "Item out of stock");
        require(balanceOf(msg.sender) >= item.price, "Insufficient balance");

        _transfer(msg.sender, owner(), item.price); // Transfer tokens to owner
        _burn(msg.sender, item.price); // Burn tokens from user
        item.stock--;
    }
}
