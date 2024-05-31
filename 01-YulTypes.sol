//SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

contract YulTypes {
    function getNumber() external pure returns (uint256) {
        uint256 x;

        assembly {
            x := 42
        }

        return x;
    }

    function getHex() external pure returns (uint256) {
        uint256 x;

        assembly {
            x := 0xa
        }

        return x;
    }

    function demoString() external pure returns (string memory) {
        // string memory myString = ""; // the string is being stored on memory not stack
        bytes32 myString = ""; // bytes32 is always stored on stack
        // assumes string has less than 32 bytes

        assembly {
            myString := "Hello World" // if myString was of type string memory then we assign a memory value to a pointer to the stack == nonesense
        }

        return string(abi.encode(myString)); // first encode to type bytes memory then typecast to string
    }

    // bytes32 is the only type that is used inside of Yul, slidity is enforcing a representation when using another type
    function representation() external pure returns (bool) {
        bool x;

        assembly {
            x := 1
        }
        return x;
    }
}

contract IsPrime {
    function isPrime(uint256 x) public pure returns (bool p) {
        p = true;
        assembly {
            let halfX := add(div(x, 2), 1)
            for { let i := 2 } lt(i, halfX) { i := add(i, 1) } {
                if iszero(mod(x, i)) {
                    p := 0
                    break
                }
            }
        }
    }

    function testPrime() external pure {
        require(isPrime(2));
        require(isPrime(3));
        require(!isPrime(4));
        require(!isPrime(15));
        require(isPrime(17));
        require(isPrime(101));
    }
}

// Yul does not have bool types
contract IfComparison {
    function isTruthy() external pure returns (uint256 result) {
        result = 2;
        assembly {
            if 2 { result := 1 }
        }
        return result; // returns 1
    }

    // Falsy values are were all the bits inside the bytes32 are 0
    function isFalsy() external pure returns (uint256 result) {
        result = 1;
        assembly {
            if 0 { result := 2 }
        }
        return result; // returns 1
    }

    function negation() external pure returns (uint256 result) {
        result = 1;
        assembly {
            if iszero(0) {
                // returns truty value
                result := 2
            }
        }
        return result; // returns 2
    }

    function unsafe1Negation() external pure returns (uint256 result) {
        result = 1;
        assembly {
            if not(0) {
                // returns truty value
                result := 2
            }
        }
        return result; // returns 2
    }

    function bitFlip() external pure returns (bytes32 result) {
        assembly {
            result := not(2)
        }
    }

    function unsafe2Negation() external pure returns (uint256 result) {
        result = 1;
        assembly {
            if not(2) {
                // returns truty value
                result := 2
            }
        }
        return result; // returns 2
    }

    function SafeNegation() external pure returns (uint256 result) {
        result = 1;
        assembly {
            if iszero(2) {
                // returns truty value
                result := 2
            }
        }
        return result; // returns 2
    }

    function max(uint256 x, uint256 y) external pure returns (uint256 maximum) {
        assembly {
            if lt(x, y) { maximum := y }
            if iszero(lt(x, y)) {
                // there are no else statements
                maximum := x
            }
        }
    }

    // The rest:
    /*
        | solidity | YUL       |
        +----------+-----------+
        | a && b   | and(a, b) |
        +----------+-----------+
        | a || b   | or(a, b)  |
        +----------+-----------+
        | a ^ b    | xor(a, b) |
        +----------+-----------+
        | a + b    | add(a, b) |
        +----------+-----------+
        | a - b    | sub(a, b) |
        +----------+-----------+
        | a * b    | mul(a, b) |
        +----------+-----------+
        | a / b    | div(a, b) |
        +----------+-----------+
        | a % b    | mod(a, b) |
        +----------+-----------+
        | a >> b   | shr(b, a) |
        +----------+-----------+
        | a << b   | shl(b, a) |
        +----------------------+

    */
}
