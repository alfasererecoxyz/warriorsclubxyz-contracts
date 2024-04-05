// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.20;

import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IEscrowAuth} from "contracts/escrow/interfaces/IEscrowAuth.sol";
import {IEscrowErrors} from "contracts/escrow/interfaces/IEscrowErrors.sol";

contract EscrowAuth is Context, IEscrowAuth, IEscrowErrors {
    mapping(bytes32 escrowId => address accountHolder) private _escrowAccountHolder;

    modifier isAuthorized(bytes32 escrowId) {
        if (!_isAuthorized(escrowId, _msgSender())) {
            revert Unauthorized(escrowId, _msgSender());
        }
        _;
    }

    function setEscrowAccountHolder(bytes32 escrowId, address account) internal {
        _escrowAccountHolder[escrowId] = account; 
    }

    function escrowAccountHolder(bytes32 escrowId) public view returns (address) {
        return _escrowAccountHolder[escrowId];
    }

    function _isAuthorized(bytes32 escrowId, address operator) internal virtual view returns (bool) {
        return (operator == _escrowAccountHolder[escrowId]);
    }
}