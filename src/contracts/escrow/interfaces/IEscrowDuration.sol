// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;


interface IEscrowDuration {

    function escrowDuration(bytes32 escrowId) external view returns (uint);

    function escrowHasLapsed(bytes32 escrowId) external view returns (bool);

    function escrowIsLocked(bytes32 escrowId) external view returns (bool);
}