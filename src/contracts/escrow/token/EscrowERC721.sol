// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.20;
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";
import {EscrowBase} from "contracts/escrow/EscrowBase.sol";
import {IEscrowTokenErrors} from "contracts/escrow/token/IEscrowTokenErrors.sol";


contract EscrowERC721 is Context, ERC721Holder, EscrowBase, IEscrowTokenErrors {

    IERC721 public erc721;

    mapping(bytes32 escrowId => uint256 id) private _escrowToken;
    mapping(address account => EnumerableSet.Bytes32Set escrowIds) private _accountEscrowIds;
    
    constructor(
        address _erc721,
        uint defaultDuration
    ) EscrowBase(defaultDuration) {
        erc721 = IERC721(_erc721); 
    }

    function onERC721Received(address operator, address from, uint256 id, bytes memory) public override returns (bytes4) {
        if (_msgSender() != address(erc721)) {
            revert UnknownSender(_msgSender());
        }
        _deposit(operator, from, id);
        return this.onERC721Received.selector;
    }

    function _isAuthorized(bytes32 escrowId, address operator) internal view virtual override returns (bool) {
        return super._isAuthorized(escrowId, operator) || erc721.isApprovedForAll(escrowAccountHolder(escrowId), operator);
    }

    function _makeEscrowId(address owner, uint256 id) internal virtual returns (bytes32) {
        return keccak256(abi.encodePacked(owner, id, block.timestamp));
    }

    function escrowToken(bytes32 escrowId) public view returns (uint256) {
        return _escrowToken[escrowId];
    }

    function _deposit(address, address account, uint256 id) internal virtual {
        bytes32 escrowId = _makeEscrowId(account, id);
        setEscrowAccountHolder(escrowId, account);
        _escrowToken[escrowId] = id;
        EnumerableSet.add(_accountEscrowIds[account], escrowId);
        _depositEscrow(escrowId);
    }

    function confirm(bytes32 escrowId) public virtual {
        // uint256 id = escrowToken(escrowId);
        // if (erc721.ownerOf(id) != address(this)) {
        //     revert 
        // }

        _confirmEscrow(escrowId);
    }

    function withdraw(bytes32 escrowId) public virtual {
        _withdrawEscrow(escrowId);
        erc721.safeTransferFrom(address(this), escrowAccountHolder(escrowId), escrowToken(escrowId), abi.encodePacked(escrowId));
    }

    function cancel(bytes32 escrowId) public virtual {
        _cancelEscrow(escrowId);
        erc721.safeTransferFrom(address(this), escrowAccountHolder(escrowId), escrowToken(escrowId), abi.encodePacked(escrowId));
    }

    function fufill(bytes32 escrowId) public virtual {
        _fufillEscrow(escrowId);
    }
}