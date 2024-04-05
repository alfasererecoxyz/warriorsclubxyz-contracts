// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.20;
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {IERC1155Receiver} from "@openzeppelin/contracts/interfaces/IERC1155Receiver.sol";
import {EscrowBase} from "contracts/escrow/EscrowBase.sol";
import {IEscrowTokenErrors} from "contracts/escrow/token/IEscrowTokenErrors.sol";


contract EscrowERC1155 is Context, ERC1155Holder, EscrowBase, IEscrowTokenErrors {

    IERC1155 public erc1155;

    mapping(bytes32 escrowId => mapping(uint256 index => uint256 id)) private _indexedEscrowTokens;
    mapping(bytes32 escrowId => mapping(uint256 index => uint256 id)) private _indexedEscrowValues;
    mapping(bytes32 escrowId => uint256 count) _indexCount;
    mapping(address account => EnumerableSet.Bytes32Set escrowIds) private _accountEscrowIds;
    
    constructor(
        address _erc1155,
        uint defaultDuration
    ) EscrowBase(defaultDuration) {
        erc1155 = IERC1155(_erc1155); 
    }

    function onERC1155BatchReceived(address operator, address from, uint256[] memory ids, uint256[] memory values, bytes memory data) public override returns (bytes4) {
        if (_msgSender() != address(erc1155)) {
            revert UnknownSender(_msgSender());
        }

        if (ids.length != values.length) {
            revert UnknownSender(_msgSender());
        }

        _depositBatch(operator, from, ids, values);
        return this.onERC1155BatchReceived.selector;
    }

    function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes memory data) public override returns (bytes4) {
        if (_msgSender() != address(erc1155)) {
            revert UnknownSender(_msgSender());
        }

        _deposit(operator, from, id, value);
        return this.onERC1155Received.selector;
    }

    function _isAuthorized(bytes32 escrowId, address operator) internal view virtual override returns (bool) {
        return super._isAuthorized(escrowId, operator) || erc1155.isApprovedForAll(escrowAccountHolder(escrowId), operator);
    }

    function _makeEscrowId(address account, uint256[] memory ids, uint256[] memory values) internal virtual returns (bytes32) {
        return keccak256(abi.encodePacked(account, ids, values, block.timestamp));
    }

    function _deposit(address operator, address account, uint256 id, uint256 value) internal virtual {
        uint256[] memory ids;
        uint256[] memory values;
        ids[0] = id;
        values[0] = value;
        bytes32 escrowId = _makeEscrowId(account, ids, values);
        setEscrowAccountHolder(escrowId, account);
        EnumerableSet.add(_accountEscrowIds[account], escrowId);
        _indexCount[escrowId] = 1;
        _indexedEscrowTokens[escrowId][0] = id;
        _indexedEscrowValues[escrowId][0] = value;
        _depositEscrow(escrowId);
    }

    function _depositBatch(address operator, address account, uint256[] memory ids, uint256[] memory values) internal virtual {
        bytes32 escrowId = _makeEscrowId(account, ids, values);
        setEscrowAccountHolder(escrowId, account);
        EnumerableSet.add(_accountEscrowIds[account], escrowId);
        _indexCount[escrowId] = ids.length;
        for (uint256 index = 0; index < ids.length; index++) {
            _indexedEscrowTokens[escrowId][index] = ids[index];
            _indexedEscrowValues[escrowId][index] = values[index];
        }
        _depositEscrow(escrowId);
    }

    function confirm(bytes32 escrowId) public virtual {
        _confirmEscrow(escrowId);
    }

    function withdraw(bytes32 escrowId) public virtual {
        _withdrawEscrow(escrowId);
        //erc1155.safeTransferFrom(address(this), escrowOwner(escrowId), escrowToken(escrowId), abi.encodePacked(escrowId));
    }

    function cancel(bytes32 escrowId) public virtual {
        _cancelEscrow(escrowId);
        //erc1155.safeTransferFrom(address(this), escrowOwner(escrowId), escrowToken(escrowId), abi.encodePacked(escrowId));
    }

    function fufill(bytes32 escrowId) public virtual {
        _fufillEscrow(escrowId);
    }
}