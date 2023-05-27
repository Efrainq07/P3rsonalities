// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Verifier.sol";



contract ZKQuestionnaireBadge is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Groth16Verifier verifier = new Groth16Verifier();
    mapping (uint256 => string) private _tokenURIs;
    string private _baseURIextended;

        
    function setBaseURI(string memory baseURI_) external onlyOwner() {
        _baseURIextended = baseURI_;
    }

    function _baseURI() internal view virtual override returns (string memory) {
            return _baseURIextended;
        }   


    constructor() ERC721("P3rsonalities", "P3R") {}
     function _beforeTokenTransfer(address from, address, uint256 , uint256) internal virtual override{
        require(from == address(0), "This a Soulbound token. It cannot be transferred.");
    }

    function _setTokenURI(uint256 tokenId, uint _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = Strings.toString(_tokenURI);
    }

     function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
            require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

            string memory _tokenURI = _tokenURIs[tokenId];
            string memory base = _baseURI();
            
            // If there is no base URI, return the token URI.
            if (bytes(base).length == 0) {
                return _tokenURI;
            }
            // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
            if (bytes(_tokenURI).length > 0) {
                return string(abi.encodePacked(base, _tokenURI));
            }
            // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
            return string(abi.encodePacked(base, Strings.toString(tokenId)));
        }

    function mint(address to, uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[1] calldata _pubSignals) public returns (uint256){
        require(verifier.verifyProof(_pA, _pB, _pC, _pubSignals),"Invalid ZK proof");
        uint256 newTokenId = _tokenIds.current();
        _mint(to,newTokenId);
        _setTokenURI(newTokenId, _pubSignals[0]);
        _tokenIds.increment();
        return newTokenId;
    }
}
