// SPDX-License-Identifier: MIT

pragma solidity ^0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Exec} from "account-abstraction/utils/Exec.sol";

contract BCAccount is Ownable {
    struct Call {
        address target;
        uint256 value;
        bytes data;
    }

    error ExecuteError(uint256 index, bytes error);

    constructor(address initialOwner) Ownable(initialOwner) {}

    receive() external payable {}

    function execute(address target, uint256 value, bytes calldata data) external onlyOwner {
        bool ok = Exec.call(target, value, data, gasleft());
        if (!ok) {
            Exec.revertWithReturnData();
        }
    }

    function executeBatch(Call[] calldata calls) external onlyOwner {
        uint256 callsLength = calls.length;
        for (uint256 i = 0; i < callsLength; i++) {
            Call calldata call = calls[i];
            bool ok = Exec.call(call.target, call.value, call.data, gasleft());
            if (!ok) {
                if (callsLength == 1) {
                    Exec.revertWithReturnData();
                } else {
                    revert ExecuteError(i, Exec.getReturnData(0));
                }
            }
        }
    }
}
