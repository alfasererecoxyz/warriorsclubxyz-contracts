// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.20;


import {IEscrowStatus} from "contracts/escrow/interfaces/IEscrowStatus.sol";
import {IEscrowDuration} from "contracts/escrow/interfaces/IEscrowDuration.sol";


abstract contract EscrowDuration is IEscrowDuration, IEscrowStatus {

    uint public defaultDuration;
    mapping(bytes32 _escrowId => uint _duration) private _escrowIdDuration;

    constructor(uint _defaultDuration) {
        defaultDuration = _defaultDuration;
    }

    function escrowDuration(bytes32 escrowId) public virtual view returns (uint) {
        if (_escrowIdDuration[escrowId] > 0) {
            return _escrowIdDuration[escrowId];
        } else {
            return defaultDuration;
        }
    }

    function escrowHasLapsed(bytes32 escrowId) public view returns (bool) {
        return (block.timestamp - escrowDuration(escrowId)) >= IEscrowStatus(this).statusConfirmedAt(escrowId); 
    }

    function escrowIsLocked(bytes32 escrowId) public view returns (bool) {
        return !escrowHasLapsed(escrowId);
    }
}