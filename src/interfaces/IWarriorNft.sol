// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.20;

import {IERC721} from "@openzeppelin/contracts/interfaces/IERC721.sol";

interface IWarriorNftErrors {
    error ErrorTokenIdAlreadyExists(uint256 tokenId);
    error ErrorTokenIdDoesNotExist(uint256 tokenId);
    error ErrorOperatorNotAuthorized(address owner, address operator, uint256 tokenId);
}

interface IWarriorNft is IERC721 {
    function mint(address to, uint256 tokenId) external;

    function burn(uint256 tokenId) external;

    function exists(uint256 tokenId) external view returns (bool);
}