// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract CompleteNFT is ERC721, ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;

    uint MAX_SUPPLY = 1;
    bool private allowListOpen;
    bool private publicOpen;

    mapping(address => bool) public allowList;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("CompleteNFT", "CNFT") {

    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://bafkreicwiegvfr77f4kufgitp4yb2t4xivsdgylj6wnmyx6mb3kq3smt7q.ipfs.nftstorage.link/";
    }

    function allowListMint() public payable {
        require(allowListOpen, "Mint is not Open");
        require(allowList[msg.sender], "You are not on the allow list");
        require(msg.value == 0.001 ether, "Insufficient Funds");

        internalMint();
    }

    function publicMint() internal {
        require(publicOpen, "Mint is not Open");
        require(msg.value == 0.01 ether, "Insufficient Funds");

        internalMint();
    }

    function internalMint() internal {
        require(totalSupply() < MAX_SUPPLY, "We Sold Out");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
    }

    function editMintWindows(bool _allowListOpen, bool _publicMintOpen) external onlyOwner {
        publicOpen = _publicMintOpen;
        allowListOpen = _allowListOpen;
    }

    function setAllowList(address[] memory addresses) external onlyOwner {
        for(uint i = 0; i < addresses.length; i++) {
            allowList[addresses[i]] = true;
        }
    }

    function withdraw() external onlyOwner {
        uint bal = address(this).balance;
        payable(msg.sender).transfer(bal);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) 
    internal override (ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId) 
    public view override (ERC721, ERC721Enumerable) 
    returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}

