// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20Capped} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {OneToken} from "../src/OneToken.sol";

contract OneTokenTest is Test {
    uint256 constant INITIAL_SUPPLY = 1_000_000 ether;
    uint256 constant CAP = 10_000_000 ether;

    OneToken token;
    address owner = makeAddr("owner");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        token = new OneToken(owner, INITIAL_SUPPLY, CAP);
    }

    function test_InitialState() public view {
        assertEq(token.name(), "One Token");
        assertEq(token.symbol(), "ONE");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY);
        assertEq(token.cap(), CAP);
        assertEq(token.owner(), owner);
    }

    function test_RevertWhen_InitialSupplyExceedsCap() public {
        vm.expectRevert(abi.encodeWithSelector(ERC20Capped.ERC20ExceededCap.selector, CAP + 1, CAP));
        new OneToken(owner, CAP + 1, CAP);
    }

    function test_OwnerCanMint() public {
        vm.prank(owner);
        token.mint(alice, 100 ether);

        assertEq(token.balanceOf(alice), 100 ether);
        assertEq(token.totalSupply(), INITIAL_SUPPLY + 100 ether);
    }

    function test_RevertWhen_NonOwnerMints() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice));
        token.mint(alice, 1);
    }

    function test_MintUpToExactCap() public {
        vm.prank(owner);
        token.mint(alice, CAP - INITIAL_SUPPLY);

        assertEq(token.totalSupply(), CAP);
    }

    function test_RevertWhen_MintExceedsCap() public {
        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSelector(ERC20Capped.ERC20ExceededCap.selector, CAP + 1, CAP));
        token.mint(alice, CAP - INITIAL_SUPPLY + 1);
    }

    function test_BurnFreesRoomUnderCap() public {
        vm.startPrank(owner);
        token.mint(owner, CAP - INITIAL_SUPPLY);
        token.burn(50 ether);
        token.mint(alice, 50 ether);
        vm.stopPrank();

        assertEq(token.totalSupply(), CAP);
        assertEq(token.balanceOf(alice), 50 ether);
    }

    function test_RevertWhen_BurnFromWithoutAllowance() public {
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, bob, 0, 1 ether));
        token.burnFrom(owner, 1 ether);
    }

    function test_BurnFromSpendsAllowance() public {
        vm.prank(owner);
        token.approve(bob, 10 ether);

        vm.prank(bob);
        token.burnFrom(owner, 4 ether);

        assertEq(token.allowance(owner, bob), 6 ether);
        assertEq(token.totalSupply(), INITIAL_SUPPLY - 4 ether);
    }

    function testFuzz_TransferConservesBalances(uint256 amount) public {
        amount = bound(amount, 0, INITIAL_SUPPLY);

        vm.prank(owner);
        token.transfer(alice, amount);

        assertEq(token.balanceOf(owner) + token.balanceOf(alice), INITIAL_SUPPLY);
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
    }

    function testFuzz_MintNeverExceedsCap(uint256 amount) public {
        amount = bound(amount, 0, type(uint256).max - INITIAL_SUPPLY);

        vm.prank(owner);
        if (INITIAL_SUPPLY + amount > CAP) {
            vm.expectRevert(
                abi.encodeWithSelector(ERC20Capped.ERC20ExceededCap.selector, INITIAL_SUPPLY + amount, CAP)
            );
        }
        token.mint(alice, amount);

        assertLe(token.totalSupply(), CAP);
    }
}
