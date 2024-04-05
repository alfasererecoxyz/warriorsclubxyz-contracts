// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.20;
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IWarriorPermissions} from "interfaces/IWarriorPermissions.sol";


abstract contract WarriorPermissionsExtern is Context {

    error ErrorLackingRole();

    IWarriorPermissions internal _permissions;

    constructor(address permissions) {
        _permissions = IWarriorPermissions(permissions);
    }

    modifier onlyRole(bytes32 role) {
        if (!_permissions.hasRole(role, _msgSender())) {
            revert ErrorLackingRole();
        }
        _;
    }
}