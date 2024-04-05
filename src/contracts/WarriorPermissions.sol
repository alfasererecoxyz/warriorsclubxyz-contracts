// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

import {IWarriorPermissions} from "interfaces/IWarriorPermissions.sol";

contract WarriorPermissions is Context, AccessControl, IWarriorPermissions {
    bytes32 public constant roleAssetsManager =
        keccak256("INTERNAL_ASSETS_MANAGER");
    bytes32 public constant roleEscrowManager =
        keccak256("INTERNAL_ESCROW_MANAGER");
    bytes32 public constant roleEscrowAgent =
        keccak256("INTERNAL_ESCROW_AGENT");
    bytes32 public constant roleAdminExternalManager =
        keccak256("ADMIN_EXTERNAL_MANAGER");

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(roleAdminExternalManager, _msgSender());
    }

    function createExternalRole(
        bytes32 role
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setRoleAdmin(role, roleAdminExternalManager);
    }
}
