// SPDX-License-Identifier: MIT

pragma solidity ^0.8.27;

import {BCT20} from "./BCT20.sol";
import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";

contract BCT20Factory {
    function createToken(
        string memory name,
        string memory symbol,
        address defaultAdmin,
        address pauser,
        address minter,
        address burner,
        address custodian,
        address limiter,
        uint256 salt
    ) public returns (address) {
        address addr = getAddress(name, symbol, defaultAdmin, pauser, minter, burner, custodian, limiter, salt);
        if (addr.code.length > 0) {
            return addr;
        }
        return Create2.deploy(
            0,
            bytes32(salt),
            abi.encodePacked(
                type(BCT20).creationCode,
                abi.encode(name, symbol, defaultAdmin, pauser, minter, burner, custodian, limiter)
            )
        );
    }

    function getAddress(
        string memory name,
        string memory symbol,
        address defaultAdmin,
        address pauser,
        address minter,
        address burner,
        address custodian,
        address limiter,
        uint256 salt
    ) public view returns (address) {
        return Create2.computeAddress(
            bytes32(salt),
            keccak256(
                abi.encodePacked(
                    type(BCT20).creationCode,
                    abi.encode(name, symbol, defaultAdmin, pauser, minter, burner, custodian, limiter)
                )
            )
        );
    }
}
