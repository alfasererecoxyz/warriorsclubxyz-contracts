// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.20;

interface IEscrowErrors {
    error Unauthorized(bytes32 escrowId, address account);
    error EscrowLockedUntil(bytes32 escrowId, uint timestamp);

    error EscrowInvalid_StatusMustBeDeposited();
    error EscrowInvalid_StatusMustBeConfirmed();
    error EscrowInvalid_StatusMustBeDepositedOrConfirmed();
}