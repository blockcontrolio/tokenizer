// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import "account-abstraction/interfaces/ISenderCreator.sol";
import "account-abstraction/accounts/SimpleAccount.sol";

contract SimpleAccountFactory {
    SimpleAccount public immutable accountImplementation;
    ISenderCreator public immutable senderCreator;

    constructor(IEntryPoint _entryPoint) {
        accountImplementation = new SimpleAccount(_entryPoint);
        senderCreator = _entryPoint.senderCreator();
    }

    function createAccount(address owner, uint256 salt) public returns (SimpleAccount ret) {
        require(msg.sender == address(senderCreator), "only callable from SenderCreator");
        address addr = getAddress(owner, salt);
        uint256 codeSize = addr.code.length;
        if (codeSize > 0) {
            return SimpleAccount(payable(addr));
        }
        ret = SimpleAccount(
            payable(
                new ERC1967Proxy{salt: bytes32(salt)}(
                    address(accountImplementation), abi.encodeCall(SimpleAccount.initialize, (owner))
                )
            )
        );
    }

    function getAddress(address owner, uint256 salt) public view returns (address) {
        return Create2.computeAddress(
            bytes32(salt),
            keccak256(
                abi.encodePacked(
                    type(ERC1967Proxy).creationCode,
                    abi.encode(address(accountImplementation), abi.encodeCall(SimpleAccount.initialize, (owner)))
                )
            )
        );
    }
}
