// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IWarriorNft, IWarriorNftErrors} from "interfaces/IWarriorNft.sol";
import {WarriorPermissionsExtern} from "contracts/WarriorPermissionsExtern.sol";

contract WarriorNft is ERC721, WarriorPermissionsExtern, IWarriorNft, IWarriorNftErrors {
    
    uint256 public totalTokens = 0;

    constructor(
        address permissions,
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) WarriorPermissionsExtern(permissions) {
    } 

    function mint(address to, uint256 tokenId) public onlyRole(_permissions.roleEscrowAgent()) {
        if (exists(tokenId)) {
            revert ErrorTokenIdAlreadyExists(tokenId);
        }
        _safeMint(to, tokenId);
        totalTokens += 1;
    }

    function burn(uint256 tokenId) public {
        if (!exists(tokenId)) {
            revert ErrorTokenIdDoesNotExist(tokenId);
        }
        if (!_isAuthorized(_ownerOf(tokenId), _msgSender(), tokenId)) {
            revert ErrorOperatorNotAuthorized(_ownerOf(tokenId), _msgSender(), tokenId);
        }
        _burn(tokenId);
    }

    function exists(uint256 tokenId) public view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
}
