// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

contract Memory {
    struct Point {
        uint256 x;
        uint256 y;
    }

    event MemoryPointer(bytes32);
    event MemoryPointerMsize(bytes32, bytes32);

    // This function runs out of gas, memory are not expected to store extremely high number or deep arrays
    // The farther you try to access a value in memory the more you are charged gas
    // It is quadratic in nature
    function highAccess() external pure {
        assembly {
            // pop just throws away the return value
            // mstore(0,0xffffffffffffffff)
            pop(mload(0xffffffffffffffff))
        }
    }

    function mstore8() external pure {
        assembly {
            mstore8(0x00, 7)
            mstore(0x00, 7)
        }
    }

    function memPointer() external {
        bytes32 x40;
        assembly {
            // In Ethereum's Solidity, the memory slot at [0x40-0x60] holds the current "free memory pointer."
            // This pointer indicates the start of the next free memory slot where data can be stored without
            // overwriting existing memory data.
            // When you allocate memory dynamically (for example, by creating a new variable in memory or using
            // the new keyword for dynamic arrays), the Solidity compiler refers to this slot to determine where
            // to place the new data. Once the data is stored, the free memory pointer is incremented accordingly
            // to point to the next free slot.
            x40 := mload(0x40) // 0x80
        }
        emit MemoryPointer(x40); // 0x0000000000000000000000000000000000000000000000000000000000000080 // active memory
        Point memory p = Point({x: 1, y: 2});

        // THe free memory pointer should be advanced by 64 bytes after adding this variable. This operations is only done by solidity
        // In assembly mode there is no bookeeping of the free memory pointer so it is not updated

        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40); // give 0xc0 // 0xc0 - 0x80 = 64 (the 2 uint256 x and y created)
    }

    function memPointerV2() external {
        bytes32 x40;
        bytes32 _msize;
        assembly {
            x40 := mload(0x40)
            _msize := msize() // Get the size of active memory in bytes. Everything is empty at first except [0x60-0x80] where the free
                // memory pointer is stored. So this gives us 0x0000000...0060
        }
        // [0x00-0x20] - Scratch space for things like intermediate values.
        // [0x20-0x40] - Also scratch space.
        // [0x40-0x60] - This slot stores the free memory pointer.
        // [0x60-0x80] - Empty (as per EVM convention)
        // The initial value of this pointer is set to 0x80 (as per your output), indicating that the next
        // available memory starts from this position. So, when the execution begins, at least 96 bytes
        // (or 0x60 in hex) are considered "actively allocated" because they are used by default for the above purposes.
        emit MemoryPointerMsize(x40, _msize);

        Point memory p = Point({x: 1, y: 2});
        assembly {
            x40 := mload(0x40) //0xc0
            _msize := msize() //0xc0 no gap between both
        }
        emit MemoryPointerMsize(x40, _msize); // Both point now at the same slot because a new data has been added to memory

        assembly {
            // Stack:
            //     Short-term storage.
            //     Data is stored in a Last-In-First-Out (LIFO) manner.
            //     Used for immediate operations and computations.
            //     Has a limited size (1024 depth).
            //     Most EVM operations take their inputs from and return their outputs to the stack.
            //     Both mload and sload are used to load data onto the stack

            // Memory:
            //     Ephemeral, wiped clean between transaction calls.
            //     Expandable, but its size adjusts during transaction execution and once expanded, it doesn't contract.
            //     Can be thought of as the "RAM" of the EVM.

            // Storage:
            //     Persistent and is associated with a contract's state.
            //     Stays between function calls and transactions.
            //     Gas-expensive to modify, so changes should be deliberate.

            //  A typical flow might look like:
            //     Load data from storage or memory onto the stack.
            //     Perform operations using the stack.
            //     Store the result back into memory or storage, as needed.

            // Tyîcally, when you store data, you either store it to memory or storage. But if you want to use it,
            // you need to load it into the stack for quick manipulation then maby re store it.

            pop(mload(0xff)) // Remove item from stack
            x40 := mload(0x40) // 0xc0
            _msize := msize() // 0x120 // since we have read from 0xff it expects the size to be 256+32 = 288
        }
        emit MemoryPointerMsize(x40, _msize); // _msize points further since we are reading from the futur
    }

    function fixedArray() external {
        bytes32 x40;
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
        uint256[2] memory arr = [uint256(5), uint256(6)];
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40); // behave the same as structs
    }

    function abiEncode() external {
        bytes32 x40;
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
        abi.encode(uint256(5), uint256(19)); // abi encode stores 3 values in memory : 5, 19 and the length (in 32 bytes)
        // (how many bytes to encode)
        assembly {
            x40 := mload(0x40) // gives 0xe0 (+ 96 bytes instead of + 0x40)
        }
        emit MemoryPointer(x40);
    }

    function abiEncode2() external {
        bytes32 x40;
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
        abi.encode(uint256(5), uint128(19)); // same as before it will pad the values to be 32 bytes
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
    }

    function abiEncodePacked() external {
        bytes32 x40;
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
        abi.encodePacked(uint256(5), uint128(19)); // only alocates 16 bytes for the second value = 0x10
        assembly {
            x40 := mload(0x40)
        }
        emit MemoryPointer(x40);
    }

    // When calling abi.encode or abi.encodePacked memory is allocated

    // Dynamic array
    event Debug(bytes32, bytes32, bytes32, bytes32);

    function args(uint256[] memory arr) external {
        bytes32 location;
        bytes32 len;
        bytes32 valueAtIndex0;
        bytes32 valueAtIndex1;
        assembly {
            location := arr
            len := mload(arr)
            valueAtIndex0 := mload(add(arr, 0x20))
            valueAtIndex1 := mload(add(arr, 0x40))
            // ...
        }
        // VERY important!! you cannot declare dynamic arrays in memory or add new element by pushing into it
        // SImply because when allocating the data in memory one after the other there is no space between them to add new element
        // to the array
        // For more info check roqs comment https://forum.soliditylang.org/t/add-the-ability-to-make-dynamic-arrays-in-memory/1867/15
        emit Debug(location, len, valueAtIndex0, valueAtIndex1);
    }

    function breakFreeMemoryPointer(uint256[1] memory foo) external pure returns (uint256) {
        // foo is written to 0x80 and the free memory pointer advances to 0xa0
        assembly {
            mstore(0x40, 0x80) // rewriting the free memory pointer which is always stored in 0x40
        }
        uint256[1] memory bar = [uint256(6)]; // bar is writtent to 0x80 and overwrites foo
        return foo[0];
    }

    uint8[] foo = [1, 2, 3, 4, 5, 6]; // In storage the values are packed

    function unpacked() external view {
        uint8[] memory bar = foo; // In memory they are unpacked
    }
}
