// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.27;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Blocklist} from "@openzeppelin/community-contracts/token/ERC20/extensions/ERC20Blocklist.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Custodian} from "@openzeppelin/community-contracts/token/ERC20/extensions/ERC20Custodian.sol";
import {ERC20Pausable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract ElectrocinMoneyToken is
    ERC20,
    ERC20Burnable,
    ERC20Pausable,
    AccessControl,
    ERC20Permit,
    ERC20Custodian,
    ERC20Blocklist
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant CUSTODIAN_ROLE = keccak256("CUSTODIAN_ROLE");
    bytes32 public constant LIMITER_ROLE = keccak256("LIMITER_ROLE");

    constructor(address defaultAdmin, address pauser, address minter, address custodian, address limiter)
        ERC20("ElectrocinMoneyToken", "EMT")
        ERC20Permit("ElectrocinMoneyToken")
    {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(PAUSER_ROLE, pauser);
        _grantRole(MINTER_ROLE, minter);
        _grantRole(CUSTODIAN_ROLE, custodian);
        _grantRole(LIMITER_ROLE, limiter);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function _isCustodian(address user) internal view override returns (bool) {
        return hasRole(CUSTODIAN_ROLE, user);
    }

    function blockUser(address user) public onlyRole(LIMITER_ROLE) {
        _blockUser(user);
    }

    function unblockUser(address user) public onlyRole(LIMITER_ROLE) {
        _unblockUser(user);
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable, ERC20Custodian, ERC20Blocklist)
    {
        super._update(from, to, value);
    }

    function _approve(address owner, address spender, uint256 value, bool emitEvent)
        internal
        override(ERC20, ERC20Blocklist)
    {
        super._approve(owner, spender, value, emitEvent);
    }
}
