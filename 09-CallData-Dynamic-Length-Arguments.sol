// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

contract VariableLength {
    struct Example {
        uint256 a;
        uint256 b;
        uint256 c;
    }

    function threeArgs(uint256 a, uint256[] calldata b, uint256 c) external {}

    // Layouts for the calldata : a = 7, b = [1,2,3] and c = 9
    // 0x0000000000000000000000000000000000000000000000000000000000000007  // 0x00 first value
    // 0x0000000000000000000000000000000000000000000000000000000000000060  // 0x20 this stores the memory location for the dynamic array
    // 0x0000000000000000000000000000000000000000000000000000000000000009  // 0x40 third value
    // 0x0000000000000000000000000000000000000000000000000000000000000003  // 0x60 length of the dynamic array
    // 0x0000000000000000000000000000000000000000000000000000000000000001  // 0x80
    // 0x0000000000000000000000000000000000000000000000000000000000000002  // 0xa0
    // 0x0000000000000000000000000000000000000000000000000000000000000003  // 0xc0

    function threeArgsStruct(uint256 a, Example calldata b, uint256 c) external {}

    // 0x01e58fb4
    // Layouts for the calldata : a = 7, b = [1,2,3] and c = 9. The length of the struct Example is already know in advance so the
    // calldata does not need to store a length of allocate a specific space in calldata
    // 0x0000000000000000000000000000000000000000000000000000000000000007
    // 0x0000000000000000000000000000000000000000000000000000000000000001
    // 0x0000000000000000000000000000000000000000000000000000000000000002
    // 0x0000000000000000000000000000000000000000000000000000000000000003
    // 0x0000000000000000000000000000000000000000000000000000000000000009

    function fiveArgs(uint256 a, uint256[] calldata b, uint256 c, uint256[] calldata d, uint256 e) external {}

    // 0x37701841
    // Layouts for the calldata : a = 5, b = [2,4], c = 7, d = [10,11,12], e = 9
    // 0x0000000000000000000000000000000000000000000000000000000000000005 00
    // 0x00000000000000000000000000000000000000000000000000000000000000a0 20
    // 0x0000000000000000000000000000000000000000000000000000000000000007 40
    // 0x0000000000000000000000000000000000000000000000000000000000000100 60
    // 0x0000000000000000000000000000000000000000000000000000000000000009 80
    // 0x0000000000000000000000000000000000000000000000000000000000000002 a0
    // 0x0000000000000000000000000000000000000000000000000000000000000002 c0
    // 0x0000000000000000000000000000000000000000000000000000000000000004 e0
    // 0x0000000000000000000000000000000000000000000000000000000000000003 100
    // 0x000000000000000000000000000000000000000000000000000000000000000a 120
    // 0x000000000000000000000000000000000000000000000000000000000000000b 140
    // 0x000000000000000000000000000000000000000000000000000000000000000c 160

    function oneArg(uint256[] calldata a) external {}

    function allVariable(uint256[] calldata a, uint256[] calldata b, uint256[] calldata c) external {}
}
