// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;


interface IEscrowAuth {
    function escrowAccountHolder(bytes32 escrowId) external view returns (address);
}