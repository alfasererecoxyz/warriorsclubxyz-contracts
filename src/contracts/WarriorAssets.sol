// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;

import "@openzeppelin/contracts/utils/Strings.sol";

import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Supply} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import {ERC1155URIStorage} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {IWarriorAssets, IWarriorAssetsErrors, IWarriorAssetsEvents} from "interfaces/IWarriorAssets.sol";
import {WarriorPermissionsExtern} from "contracts/WarriorPermissionsExtern.sol";

contract WarriorAssets is Context, Ownable, ERC1155Supply, WarriorPermissionsExtern, IWarriorAssets, IWarriorAssetsErrors, IWarriorAssetsEvents {
    using Strings for uint256;

    string private _baseURI;
    mapping(uint256 => bytes32) private _mintRole;
    mapping(uint256 => uint256) private _mintPrice;
    mapping(uint256 => uint256) private _maxSupply;

    constructor(
        address permissions,
        string memory metadataBaseUri
    ) Ownable(_msgSender()) ERC1155(metadataBaseUri) WarriorPermissionsExtern(permissions) {
        _baseURI = metadataBaseUri;
    }

    function metadataUpdate(
        uint256 id
    ) public onlyRole(_permissions.roleAssetsManager()) {
        emit MetadataUpdate(id);
    }

    function setBaseURI(
        string memory newBaseURI
    ) public onlyRole(_permissions.roleAssetsManager()) {
        _baseURI = newBaseURI;
    }

    function getBaseURI() public view returns (string memory) {
        return _baseURI;
    }

    function maxSupply(uint256 id) public view returns (uint256) {
        return _maxSupply[id];
    }

    function mintRole(uint256 id) public view returns (bytes32) {
        return _mintRole[id];
    }

    function mintPrice(uint256 id) public view returns (uint256) {
        return _mintPrice[id];
    }

    function uri(uint256 id) public view override returns (string memory) {
        string memory baseURI = this.getBaseURI();
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, id.toString()))
                : "";
    }

    function addToken(
        uint256 tokenId,
        uint256 __maxSupply,
        uint256 __mintPrice,
        bytes32 __mintRole
    ) public onlyRole(_permissions.roleAssetsManager()) {
        if (_maxSupply[tokenId] != uint256(0)) {
            revert ErrorTokenSupplyNotModifiable(tokenId);
        }

        if (_mintPrice[tokenId] != uint256(0)) {
            revert ErrorTokenMintPriceNotModifiable(tokenId);
        }

        if (_mintRole[tokenId] != bytes32(0)) {
            revert ErrorTokenMintRoleNotModifiable(tokenId);
        }

        _maxSupply[tokenId] = __maxSupply;
        _mintPrice[tokenId] = __mintPrice;
        _mintRole[tokenId] = __mintRole;
    }

    function getTotalMintPrice(
        uint256[] memory ids,
        uint256[] memory values
    ) public view returns (uint256) {
        if (ids.length != values.length) {
            revert ErrorInvalidInputs();
        }
        uint256 totalPrice = 0;
        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 tokenId = ids[i];
            uint256 value = values[i];
            totalPrice += (_mintPrice[tokenId] * value);
        }
        return totalPrice;
    }

    function remainingSupply(uint256 id) public view returns (uint256) {
        return _maxSupply[id] - totalSupply(id);
    }

    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) public {
        if (
            account != _msgSender() && !isApprovedForAll(account, _msgSender())
        ) {
            revert ErrorMissingApprovalForAll(_msgSender(), account);
        }

        _burnBatch(account, ids, values);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public payable {
        if (ids.length != values.length) {
            revert ErrorInvalidInputs();
        }

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 tokenId = ids[i];
            uint256 value = values[i];
            if (remainingSupply(tokenId) < value) {
                revert ErrorNotEnoughSupply(tokenId);
            }
            if (
                _mintRole[tokenId] != bytes32(0) &&
                !_permissions.hasRole(_mintRole[tokenId], _msgSender())
            ) {
                revert ErrorNotAllowedToMint(tokenId);
            }
        }
        if (msg.value != getTotalMintPrice(ids, values)) {
            revert ErrorNotEnoughFundsSent();
        }

        _mintBatch(to, ids, values, data);
    }
}
