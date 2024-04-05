// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {WarriorAssets} from "contracts/WarriorAssets.sol";
import {WarriorPermissions} from "contracts/WarriorPermissions.sol";
import {IWarriorAssetsErrors,IWarriorAssetsEvents} from "interfaces/IWarriorAssets.sol";

contract WarriorAssetsTest is Test, IWarriorAssetsErrors, IWarriorAssetsEvents {
    address deployer = address(1);
    address assetManager = address(2);
    address customer = address(3);

    WarriorPermissions public permissions;
    WarriorAssets public assets;

    function setUp() public {
        vm.startPrank(deployer);
        {
            permissions = new WarriorPermissions();
            permissions.grantRole(
                permissions.roleAssetsManager(),
                assetManager
            );
        }
        vm.stopPrank();

        vm.startPrank(assetManager);
        {
            assets = new WarriorAssets(address(permissions), "");
        }
        vm.stopPrank();
    }

    function testConstructor() public {
        assertEq(assets.uri(0), "");
    }

    function test_setBaseUri() public {
        vm.prank(assetManager);
        assets.setBaseURI("abc");
    }

    function test_metadataUpdate() public {
        vm.startPrank(assetManager);
        {
            assets.addToken(0, 10, 1 ether, 0);
        }
        vm.stopPrank();
        vm.startPrank(customer);
        {
            uint256[] memory ids = new uint256[](1);
            uint256[] memory values = new uint256[](1);
            bytes memory data = "";
            ids[0] = 0;
            values[0] = 1;
            uint256 totalMintPrice = assets.getTotalMintPrice(ids, values);
            vm.deal(customer, totalMintPrice);
            assets.mintBatch{value: totalMintPrice}(
                customer,
                ids,
                values,
                data
            );
        }
        vm.stopPrank();

        vm.startPrank(assetManager);
        {
            vm.expectEmit();
            emit MetadataUpdate(0);
            assets.metadataUpdate(0);
        }
        vm.stopPrank();
    }

    function test_addToken_Happy() public {
        uint256 tokenId = 0;
        vm.startPrank(assetManager);
        {
            assets.addToken(0, 10, 1 ether, 0);
            assertEq(assets.maxSupply(tokenId), 10);
            assertEq(assets.mintRole(tokenId), 0);
            assertEq(assets.mintPrice(tokenId), 1 ether);
        }
        vm.stopPrank();
    }

    function test_addToken_ErrorTokenSupplyNotModifiable() public {
        uint256 tokenId = 0;
        vm.startPrank(assetManager);
        {
            assets.addToken(0, 10, 1 ether, 0);
            vm.expectRevert(abi.encodeWithSelector(ErrorTokenSupplyNotModifiable.selector, tokenId));
            assets.addToken(0, 11, 1 ether, 0);
        }
    }

    function test_addToken_ErrorTokenMintPriceNotModifiable() public {
        uint256 tokenId = 0;
        vm.startPrank(assetManager);
        {
            assets.addToken(0, 0, 1 ether, 0);
            vm.expectRevert(abi.encodeWithSelector(ErrorTokenMintPriceNotModifiable.selector, tokenId));
            assets.addToken(0, 0, 2 ether, 0);
        }
    }

    function test_addToken_ErrorTokenMintRoleNotModifiable() public {
        uint256 tokenId = 0;
        vm.startPrank(assetManager);
        {
            assets.addToken(0, 0, 0, keccak256(abi.encodePacked("1")));
            vm.expectRevert(abi.encodeWithSelector(ErrorTokenMintRoleNotModifiable.selector, tokenId));
            assets.addToken(0, 0, 0, keccak256(abi.encodePacked("2")));
        }
    }

    function test_getTotalMintPrice() public {
        vm.startPrank(assetManager);
        {
            assets.addToken(0, 10, 1 ether, 0);
        }
        vm.stopPrank();
        vm.startPrank(customer);
        {
            uint256[] memory ids = new uint256[](1);
            uint256[] memory values = new uint256[](1);
            ids[0] = 0;
            values[0] = 11;
            uint256 totalMintPrice = assets.getTotalMintPrice(ids, values);
            assertEq(totalMintPrice, 11 ether);
        }
        vm.stopPrank();
    }

    function test_mintBatch_Happy() public {
        vm.startPrank(assetManager);
        {
            assets.addToken(0, 10, 1 ether, 0);
        }
        vm.stopPrank();
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        bytes memory data = "";
        ids[0] = 0;
        values[0] = 1;
        uint256 eth = assets.getTotalMintPrice(ids, values);
        vm.deal(customer, eth);
        vm.startPrank(customer);
        {
            assets.mintBatch{value: eth}(customer, ids, values, data);
        }
        vm.stopPrank();

        assertTrue(assets.exists(ids[0]));
        assertEq(assets.totalSupply(0), values[0]);
        assertEq(assets.maxSupply(0), 10);
        assertEq(
            assets.remainingSupply(ids[0]),
            assets.maxSupply(0) - values[0]
        );

        assertEq(assets.balanceOf(customer, ids[0]), values[0]);
    }

    function test_mintBatch_ErrorInvalidInputs() public {
        vm.startPrank(assetManager);
        {
            assets.addToken(0, 10, 1 ether, 0);
        }
        vm.stopPrank();
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](2);
        bytes memory data = "";
        ids[0] = 0;
        values[0] = 1;
        vm.expectRevert(ErrorInvalidInputs.selector);
        uint256 eth = assets.getTotalMintPrice(ids, values);
        vm.deal(customer, eth);
        vm.startPrank(customer);
        {
            vm.expectRevert(ErrorInvalidInputs.selector);
            assets.mintBatch{value: eth}(customer, ids, values, data);
        }
        vm.stopPrank();
    }

    function test_mintBatch_ErrorNotAllowedToMint() public {
        vm.startPrank(assetManager);
        {
            assets.addToken(1, 1, 1 ether, permissions.roleEscrowManager());
        }
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        bytes memory data = "";
        ids[0] = 1;
        values[0] = 1;
        uint256 eth = assets.getTotalMintPrice(ids, values);
        vm.deal(customer, eth);
        vm.startPrank(customer);
        {
            vm.expectRevert(abi.encodeWithSelector(ErrorNotAllowedToMint.selector, 1));
            assets.mintBatch{value: eth}(customer, ids, values, data);
        }
        vm.stopPrank();
    }

    function test_mintBatch_ErrorNotEnoughFundsSent() public {
        vm.startPrank(assetManager);
        {
            assets.addToken(1, 1, 1 ether, 0);
        }
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        bytes memory data = "";
        ids[0] = 1;
        values[0] = 1;
        uint256 eth = assets.getTotalMintPrice(ids, values);
        vm.deal(customer, eth);
        vm.startPrank(customer);
        {
            vm.expectRevert(ErrorNotEnoughFundsSent.selector);
            assets.mintBatch{value: eth - 1}(customer, ids, values, data);
        }
        vm.stopPrank();
    }

    function test_mintBatch_ErrorNotEnoughSupply() public {
        vm.startPrank(assetManager);
        {
            assets.addToken(1, 1, 1 ether, permissions.roleAssetsManager());
        }
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        bytes memory data = "";
        ids[0] = 1;
        values[0] = 2;
        uint256 eth = assets.getTotalMintPrice(ids, values);
        vm.deal(customer, eth);
        vm.startPrank(customer);
        {
            vm.expectRevert(abi.encodeWithSelector(ErrorNotEnoughSupply.selector, 1));
            assets.mintBatch{value: eth}(customer, ids, values, data);
        }
        vm.stopPrank();
    }

    function test_mintBatch_MintWithRole() public {
        vm.startPrank(deployer);
        {
            permissions.grantRole(permissions.roleAssetsManager(), customer);
        }
        vm.stopPrank();

        vm.startPrank(assetManager);
        {
            assets.addToken(1, 1, 1 ether, permissions.roleAssetsManager());
        }
        vm.stopPrank();
        uint256[] memory ids = new uint256[](1); ids[0] = 1;
        uint256[] memory values = new uint256[](1); values[0] = 1;
        bytes memory data = "";
        
        uint256 eth = assets.getTotalMintPrice(ids, values);
        vm.deal(customer, eth);
        vm.startPrank(customer);
        {
            assets.mintBatch{value: eth}(customer, ids, values, data);
        }
        vm.stopPrank();

        assertEq(assets.totalSupply(ids[0]), values[0]);
        assertEq(
            assets.remainingSupply(ids[0]),
            assets.maxSupply(ids[0]) - values[0]
        );

        assertEq(assets.balanceOf(customer, ids[0]), values[0]);
    }

    function test_burnBatch_Happy() public {
        vm.startPrank(assetManager);
        {
            assets.addToken(0, 10, 1 ether, 0);
        }
        vm.stopPrank();
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        bytes memory data = "";
        ids[0] = 0;
        values[0] = 1;
        uint256 eth = assets.getTotalMintPrice(ids, values);
        vm.deal(customer, eth);
        vm.startPrank(customer);
        {
            assets.mintBatch{value: eth}(customer, ids, values, data);
            assets.burnBatch(customer, ids, values);
        }
        vm.stopPrank();

        assertEq(assets.balanceOf(customer, ids[0]), 0);
    }

    function test_burnBatch_ErrorMissingApprovalForAll() public {
        vm.startPrank(assetManager);
        {
            assets.addToken(0, 10, 1 ether, 0);
        }
        vm.stopPrank();
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        bytes memory data = "";
        ids[0] = 0;
        values[0] = 1;
        uint256 eth = assets.getTotalMintPrice(ids, values);
        vm.deal(customer, eth);
        vm.startPrank(customer);
        {
            assets.mintBatch{value: eth}(customer, ids, values, data);
        }
        vm.stopPrank();

        vm.startPrank(assetManager);
        {
            vm.expectRevert(
                abi.encodeWithSelector(ErrorMissingApprovalForAll.selector, assetManager, customer)
            );
            assets.burnBatch(customer, ids, values);
        }
        vm.stopPrank();
    }
}
