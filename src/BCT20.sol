// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.27;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Blocklist} from "@openzeppelin/community-contracts/token/ERC20/extensions/ERC20Blocklist.sol";
import {ERC20Custodian} from "@openzeppelin/community-contracts/token/ERC20/extensions/ERC20Custodian.sol";
import {ERC20Pausable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";

// BCT (BlockControlToken) is a ERC20 token with additional features:
// - Pausable: User with role PAUSER can pause the contract.
// - Mintable: User with role MINTER can mint new tokens.
// - Burnable: User with role BURNER can burn tokens.
// - Custodian: User with role CUSTODIAN can freeze custom amount of token on behalf of other users.
// - Blocklist: User with role LIMITER can block and unblock users from transferring tokens.
contract BCT20 is ERC20, ERC20Pausable, AccessControl, ERC20Custodian, ERC20Blocklist {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant CUSTODIAN_ROLE = keccak256("CUSTODIAN_ROLE");
    bytes32 public constant LIMITER_ROLE = keccak256("LIMITER_ROLE");

    constructor(
        string memory name,
        string memory symbol,
        address defaultAdmin,
        address pauser,
        address minter,
        address burner,
        address custodian,
        address limiter
    ) ERC20(name, symbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(PAUSER_ROLE, pauser);
        _grantRole(MINTER_ROLE, minter);
        _grantRole(BURNER_ROLE, burner);
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

    function burn(uint256 amount) public onlyRole(BURNER_ROLE) {
        _burn(_msgSender(), amount);
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
