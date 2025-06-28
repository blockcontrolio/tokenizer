// SPDX-License-Identifier: MIT

pragma solidity ^0.8.27;

import {EntryPoint} from "account-abstraction/core/EntryPoint.sol";
import {BasePaymaster} from "account-abstraction/core/BasePaymaster.sol";
import {PackedUserOperation} from "account-abstraction/interfaces/PackedUserOperation.sol";

contract SimplePaymaster is BasePaymaster {
    constructor(EntryPoint entryPoint) BasePaymaster(entryPoint) {}

    function _validatePaymasterUserOp(PackedUserOperation calldata, bytes32, uint256)
        internal
        view
        override
        returns (bytes memory, uint256)
    {
        require(tx.origin == owner(), "SimplePaymaster: Only owner can call this function");
        return ("", 0); // Bypassing validation logic for simplicity
    }

    function _postOp(PostOpMode, bytes calldata, uint256, uint256) internal override {
        // NO-OP: This is a simple paymaster that does not require any post-operation logic.
    }
}
