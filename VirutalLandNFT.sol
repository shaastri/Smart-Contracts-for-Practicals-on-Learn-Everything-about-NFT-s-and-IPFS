// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract VirtualLandNFT is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    uint MAX_SUPPLY;

    struct VirtualLand {
        string name;
        address owner;
        uint price;
        string imageURL;
        bool forSale;
    }

    mapping(uint => VirtualLand) virtualLands;

    constructor() ERC721("VirtualLandNFT", "VLNFT") {
        MAX_SUPPLY = 100;
    }

    function mintLand(string memory _name, uint _price, string memory _imageURL) public {
        
        _tokenIdCounter.increment();        
        uint256 tokenId = _tokenIdCounter.current();

        require(tokenId <= MAX_SUPPLY, "We Sold Out!!!");

        virtualLands[tokenId] = VirtualLand(_name, msg.sender, _price, _imageURL, false);
        _safeMint(msg.sender, tokenId);
    }

    function setVirtualLandforSale(uint tokenId) external {
        require(_exists(tokenId), "NFT does not exist");
        require(ownerOf(tokenId) == msg.sender, "Only Owner can call this function");
        virtualLands[tokenId].forSale = true;
    }

    function purchaseVirtualLand(uint tokenId) external payable {
        VirtualLand storage virtualLand = virtualLands[tokenId];

        require(virtualLand.forSale, "Not for Sale");
        require(msg.value >= virtualLand.price, "Insufficient Balance");

        address previousOwner = virtualLand.owner;
        virtualLand.owner = msg.sender;
        virtualLand.forSale = false;

        payable(previousOwner).transfer(virtualLand.price);
        _transfer(previousOwner, msg.sender, tokenId);
    }

    function getVirtualLandDetails(uint tokenId) external view returns(VirtualLand memory) {
        return virtualLands[tokenId];
    }
}

