// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;

import {IEscrowStatus, EscrowStatusValue} from 'contracts/escrow/interfaces/IEscrowStatus.sol';

contract EscrowStatus is IEscrowStatus {
    mapping(bytes32 escrowId => EscrowStatusValue status) private _escrowStatus;
    mapping(bytes32 escrowId => uint depositedAt) private _escrowDepositedAt;
    mapping(bytes32 escrowId => uint confirmedAt) private _escrowConfirmedAt;
    mapping(bytes32 escrowId => uint withdrawnAt) private _escrowWithdrawnAt;
    mapping(bytes32 escrowId => uint cancelledAt) private _escrowCancelledAt;
    mapping(bytes32 escrowId => uint fulfilledAt) private _escrowFulfilledAt;

    function setStatusDeposited(bytes32 escrowId) internal {
        _escrowStatus[escrowId] = EscrowStatusValue.Deposited;
        _escrowDepositedAt[escrowId] = block.timestamp;
    }
    function setStatusConfirmed(bytes32 escrowId) internal {
        _escrowStatus[escrowId] = EscrowStatusValue.Confirmed;
        _escrowConfirmedAt[escrowId] = block.timestamp;
    }
    function setStatusWithdrawn(bytes32 escrowId) internal {
        _escrowStatus[escrowId] = EscrowStatusValue.Withdrawn;
        _escrowWithdrawnAt[escrowId] = block.timestamp;
    }
    function setStatusCancelled(bytes32 escrowId) internal {
        _escrowStatus[escrowId] = EscrowStatusValue.Cancelled;
        _escrowCancelledAt[escrowId] = block.timestamp;
    }
    function setStatusFulfilled(bytes32 escrowId) internal {
        _escrowStatus[escrowId] = EscrowStatusValue.Fulfilled;
        _escrowFulfilledAt[escrowId] = block.timestamp;
    }

    function statusDepositedAt(bytes32 escrowId) public view returns (uint) {
        return _escrowDepositedAt[escrowId];
    }
    function statusConfirmedAt(bytes32 escrowId) public view returns (uint) {
        return _escrowConfirmedAt[escrowId];
    }
    function statusWithdrawnAt(bytes32 escrowId) public view returns (uint) {
        return _escrowWithdrawnAt[escrowId];
    }
    function statusCancelledAt(bytes32 escrowId) public view returns (uint) {
        return _escrowCancelledAt[escrowId];
    }
    function statusFulfilledAt(bytes32 escrowId) public view returns (uint) {
        return _escrowFulfilledAt[escrowId];
    }

    function status(bytes32 escrowId) public view returns (EscrowStatusValue) {
        return _escrowStatus[escrowId];
    }
    function statusIsDeposited(bytes32 escrowId) public view returns (bool) {
        return _escrowStatus[escrowId] == EscrowStatusValue.Deposited;
    }
    function statusIsConfirmed(bytes32 escrowId) public view returns (bool) {
        return _escrowStatus[escrowId] == EscrowStatusValue.Confirmed;
    }
    function statusIsWithdrawn(bytes32 escrowId) public view returns (bool) {
        return _escrowStatus[escrowId] == EscrowStatusValue.Withdrawn;
    }
    function statusIsCancelled(bytes32 escrowId) public view returns (bool) {
        return _escrowStatus[escrowId] == EscrowStatusValue.Cancelled;
    }
    function statusIsFulfilled(bytes32 escrowId) public view returns (bool) {
        return _escrowStatus[escrowId] == EscrowStatusValue.Fulfilled;
    }
    
}