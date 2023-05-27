// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Verifier.sol";



contract MyToken is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Groth16Verifier verifier = new Groth16Verifier();
    constructor() ERC721("MyToken", "MTK") {}

    function safeMint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }
    function mint(address to, uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[1] calldata _pubSignals) public returns (uint256){
        
        require(verifier.verifyProof(_pA, _pB, _pC, _pubSignals),"Invalid ZK proof");
        uint256 newTokenId = _tokenIds.current();
        _mint(to,newTokenId);
        _tokenIds.increment();
        return newTokenId;
    }
}
