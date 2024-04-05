// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {WarriorAssets} from "contracts/WarriorAssets.sol";
import {WarriorPermissions} from "contracts/WarriorPermissions.sol";

contract WarriorPermissionsTest is Test {
    address deployer = address(1);
    address randy = address(2);

    WarriorPermissions public permissions;

    function setUp() public {
        vm.startPrank(deployer);
        {
            permissions = new WarriorPermissions();
        }
        vm.stopPrank();
    }

    function test_constructor() public {
        assertTrue(
            permissions.hasRole(permissions.DEFAULT_ADMIN_ROLE(), deployer)
        );

        assertTrue(
            permissions.hasRole(
                permissions.roleAdminExternalManager(),
                deployer
            )
        );
    }

    function test_createExternalRole_Happy() public {
        bytes32 roleScrub = keccak256("EXTERNAL_RANK_SCRUB");
        vm.startPrank(deployer);
        {
            permissions.createExternalRole(roleScrub);
        }
        vm.stopPrank();

        assertEq(
            permissions.getRoleAdmin(roleScrub),
            permissions.roleAdminExternalManager()
        );
    }
}
