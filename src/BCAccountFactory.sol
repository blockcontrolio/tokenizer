// SPDX-License-Identifier: MIT

pragma solidity ^0.8.27;

import {BCAccount} from "./BCAccount.sol";
import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";

contract BCAccountFactory {
    function createAccount(address owner, uint256 salt) public returns (address) {
        address addr = getAddress(owner, salt);
        if (addr.code.length > 0) {
            return addr;
        }
        return Create2.deploy(0, bytes32(salt), abi.encodePacked(type(BCAccount).creationCode, abi.encode(owner)));
    }

    function getAddress(address owner, uint256 salt) public view returns (address) {
        return Create2.computeAddress(
            bytes32(salt), keccak256(abi.encodePacked(type(BCAccount).creationCode, abi.encode(owner)))
        );
    }
}
