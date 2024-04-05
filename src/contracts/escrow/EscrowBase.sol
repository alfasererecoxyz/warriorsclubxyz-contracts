// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.20;
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";
import {EscrowDuration} from "contracts/escrow/extensions/EscrowDuration.sol";
import {EscrowAuth} from "contracts/escrow/extensions/EscrowAuth.sol";
import {EscrowStatus, EscrowStatusValue} from "contracts/escrow/extensions/EscrowStatus.sol";
import {IEscrowEvents} from "contracts/escrow/interfaces/IEscrowEvents.sol";
import {IEscrowErrors} from "contracts/escrow/interfaces/IEscrowErrors.sol";


contract EscrowBase is Context, EscrowDuration, EscrowStatus, EscrowAuth, IEscrowEvents {

    constructor(
        uint defaultDuration
    ) EscrowDuration(defaultDuration) {}

    function _depositEscrow(bytes32 escrowId) internal virtual {
        setStatusDeposited(escrowId);
        emit EscrowDeposited(escrowId);
    }

    function _confirmEscrow(bytes32 escrowId) isAuthorized(escrowId) internal virtual {
        if (!statusIsDeposited(escrowId)) {
            revert EscrowInvalid_StatusMustBeDeposited();
        }
        setStatusConfirmed(escrowId);
        emit EscrowConfirmed(escrowId);
    }

    function _withdrawEscrow(bytes32 escrowId) isAuthorized(escrowId) internal virtual {
        if (!(statusIsDeposited(escrowId) || statusIsConfirmed(escrowId))) {
            revert EscrowInvalid_StatusMustBeDepositedOrConfirmed();
        }
        if (statusIsConfirmed(escrowId) && escrowIsLocked(escrowId)) {
            revert EscrowLockedUntil(escrowId, statusConfirmedAt(escrowId) + escrowDuration(escrowId));
        }
        setStatusWithdrawn(escrowId);
        emit EscrowWithdrawn(escrowId);
    }

    function _cancelEscrow(bytes32 escrowId) isAuthorized(escrowId) internal virtual {
        if (!statusIsConfirmed(escrowId)) {
            revert EscrowInvalid_StatusMustBeConfirmed();
        }
        setStatusCancelled(escrowId);
        emit EscrowCancelled(escrowId);
    }

    function _fufillEscrow(bytes32 escrowId) internal virtual {
        if (!statusIsConfirmed(escrowId)) {
            revert EscrowInvalid_StatusMustBeConfirmed();
        }
        setStatusFulfilled(escrowId);
        emit EscrowFulfilled(escrowId);
    }
}