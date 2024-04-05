// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;

import {IERC1155} from "@openzeppelin/contracts/interfaces/IERC1155.sol";

pragma solidity ^0.8.4;

interface IWarriorAssetsEvents {
    event MetadataUpdate(uint256 tokenId);
}

interface IWarriorAssetsErrors {
    error ErrorTokenSupplyNotModifiable(uint256 tokenId);
    error ErrorTokenMintPriceNotModifiable(uint256 tokenId);
    error ErrorTokenMintRoleNotModifiable(uint256 tokenId);
    error ErrorNotEnoughFundsSent();
    error ErrorNotEnoughSupply(uint256 tokenId);
    error ErrorNotAllowedToMint(uint256 tokenId);
    error ErrorInvalidInputs();
    error ErrorMissingApprovalForAll(address operator, address account);
}

interface IWarriorAssets is IERC1155 {
    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) external;

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) external payable;
}
