// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.20;

import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IWarriorAssets} from "interfaces/IWarriorAssets.sol";

contract WarriorCrate is Context {

    IWarriorAssets private assets;

    constructor(address erc1155) {
        assets = IWarriorAssets(erc1155);
    }
}