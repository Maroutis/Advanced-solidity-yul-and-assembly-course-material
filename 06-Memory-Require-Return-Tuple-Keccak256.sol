// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;



contract UsingMemory {
    function return2and4() external pure returns (uint256, uint256) {
        assembly {
            mstore(0x00, 2)
            mstore(0x20, 4)
            return(0x00, 0x40) // Yul allows to return an area larger than 32 bytes which would not be possible in solidity with
            // one variable
            // The return operation takes two parameters:
            // The starting location in memory of the data to return.
            // The size (in bytes) of the data to return.
        }
    }

    function requireV1() external view {
        require(msg.sender == 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2);
    }

    function requireV2() external view {
        assembly {
            if iszero(
                eq(caller(), 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2)
            ) {
                revert(0, 0)
            }
        }
    }
    function hashV1() external pure returns (bytes32) {
        bytes memory toBeHashed = abi.encode(1, 2, 3);
        return keccak256(toBeHashed);
    }

    function hashV2() external pure returns (bytes32) {
        assembly {
            let freeMemoryPointer := mload(0x40)

            // store 1, 2, 3 in memory
            mstore(freeMemoryPointer, 1)
            mstore(add(freeMemoryPointer, 0x20), 2)
            mstore(add(freeMemoryPointer, 0x40), 3)
            // this operations do not update the value of the freeMemoryPointer itself.
            // but only the value pointed to by the free memory pointer
            // write to scratch space in this example is not a good idea because the line
            // mstore(add(freeMemoryPointer, 0x40), 3) would crash into free memory pointer
            // that's we first load it to tell us where we should start writing to avoid collision

            // update memory pointer
            mstore(0x40, add(freeMemoryPointer, 0x60)) // increase memory pointer by 96 bytes
            // however the variable freeMemoryPointer is not updated
            mstore(0x00, keccak256(freeMemoryPointer, 0x60)) // hash 96 bytes of data starting at 0x80
            // and write into 32 bytes
            return(0x00, 0x20)
        }
    }

}


