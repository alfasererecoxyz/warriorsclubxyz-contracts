// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;


enum EscrowStatusValue {
    Invalid,
    Deposited,
    Confirmed,
    Withdrawn,
    Cancelled,
    Fulfilled
}

interface IEscrowStatus {

    function statusDepositedAt(bytes32 escrowId) external view returns (uint); 

    function statusIsDeposited(bytes32 escrowId) external view returns (bool);

    function statusConfirmedAt(bytes32 escrowId) external view returns (uint);

    function statusIsConfirmed(bytes32 escrowId) external view returns (bool);

    function statusWithdrawnAt(bytes32 escrowId) external view returns (uint);

    function statusIsWithdrawn(bytes32 escrowId) external view returns (bool);

    function statusCancelledAt(bytes32 escrowId) external view returns (uint);

    function statusIsCancelled(bytes32 escrowId) external view returns (bool);

    function statusFulfilledAt(bytes32 escrowId) external view returns (uint);

    function statusIsFulfilled(bytes32 escrowId) external view returns (bool);
}