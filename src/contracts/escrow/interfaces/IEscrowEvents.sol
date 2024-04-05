// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.20;

interface IEscrowEvents {
    event EscrowDeposited(bytes32 escrowId);
    event EscrowConfirmed(bytes32 escrowId);
    event EscrowWithdrawn(bytes32 escrowId);
    event EscrowCancelled(bytes32 escrowId);
    event EscrowFulfilled(bytes32 escrowId);
}