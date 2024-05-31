//SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

contract StorageComplex {
    uint256[3] fixedArray;
    uint256 a;
    uint256 b;
    uint256 c;
    uint256 d;
    uint256[] bigArray; // for dynamic arrays, the EVM does not store the values sequentially by risk of crashing at an already existing value
        // it hashes the slot unto an enormous 256 bits number
    uint8[] smallArray;

    mapping(uint256 => uint256) public myMapping;
    mapping(uint256 => mapping(uint256 => uint256)) public nestedMapping;
    mapping(address => uint256[]) public addressToList;

    constructor() {
        fixedArray = [99, 999, 9999];
        bigArray = [10, 20, 30, 40];
        smallArray = [1, 2, 3];

        myMapping[10] = 5;
        myMapping[11] = 6;
        nestedMapping[2][4] = 7;

        addressToList[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4] = [42, 1337, 777];
    }

    function fixedArrayView(uint256 index) external view returns (uint256 ret) {
        assembly {
            ret := sload(add(fixedArray.slot, index))
        }
    }

    function bigArrayLength() external view returns (uint256 ret) {
        assembly {
            ret := sload(bigArray.slot)
        }
    }

    function readBigArrayLocation(uint256 index) external view returns (uint256 ret) {
        uint256 slot;
        assembly {
            slot := bigArray.slot
        }
        bytes32 location = keccak256(abi.encode(slot)); // chances are by hashing the number, the evm will never run at an already existing value

        assembly {
            ret := sload(add(location, index))
        }
    }

    function readSmallArray() external view returns (uint256 ret) {
        assembly {
            ret := sload(smallArray.slot)
        }
    }

    // For less than 32 bytes variable, the values are packed
    function readSmallArrayLocation(uint256 index) external view returns (uint256 e) {
        uint256 slot;
        assembly {
            slot := smallArray.slot
        }
        bytes32 location = keccak256(abi.encode(slot));

        assembly {
            let ret := sload(location)
            let shifted := shr(mul(index, 8), ret)

            e := and(0xff, shifted)
        }
    }

    function getMapping(uint256 key) external view returns (uint256 ret) {
        uint256 slot;
        assembly {
            slot := myMapping.slot
        }

        bytes32 location = keccak256(abi.encode(key, uint256(slot)));

        assembly {
            ret := sload(location)
        }
    }

    function getNestedMapping(uint256 firstMappingKey, uint256 secondMappingKey) external view returns (uint256 ret) {
        uint256 slot;
        assembly {
            slot := nestedMapping.slot
        }
        // firstMappingKey = 2
        // secondMappingKey = 4
        bytes32 location = keccak256(
            abi.encode(uint256(secondMappingKey), keccak256(abi.encode(uint256(firstMappingKey), uint256(slot))))
        );
        assembly {
            ret := sload(location)
        }
    }
    // Treated like a mapping and result as an array

    function lengthOfNestedList() external view returns (uint256 ret) {
        uint256 addressToListSlot;
        assembly {
            addressToListSlot := addressToList.slot
        }

        bytes32 location =
            keccak256(abi.encode(address(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4), uint256(addressToListSlot)));
        assembly {
            ret := sload(location)
        }
    }

    function getAddressToList(uint256 index) external view returns (uint256 ret) {
        uint256 slot;
        assembly {
            slot := addressToList.slot
        }

        bytes32 location = keccak256(
            abi.encode(keccak256(abi.encode(address(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4), uint256(slot))))
        );
        assembly {
            ret := sload(add(location, index))
        }
    }
}
