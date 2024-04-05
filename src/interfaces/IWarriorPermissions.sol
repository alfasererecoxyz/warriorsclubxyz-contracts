// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;

import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

interface IWarriorPermissions is IAccessControl {
    function roleAssetsManager() external view returns (bytes32);

    function roleEscrowManager() external view returns (bytes32);

    function roleEscrowAgent() external view returns (bytes32);

    function roleAdminExternalManager() external view returns (bytes32);
}
