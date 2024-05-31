// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

contract Log {
    event SomeLog(uint256 indexed a, uint256 indexed b);
    event SomeLogV2(uint256 indexed a, bool);

    function emitLog() external {
        // First topic (in etherscan) is the keccak256 of the event signature
        emit SomeLog(5, 6);
    }

    function yulEmitLog() external {
        assembly {
            // keccak256("SomeLog(uint256,uint256)") = signature
            let
                signature
            := 0xc200138117cf199dd335a2c6079a6e1be01e6592b6a76d4b5fc31b169df819cc
            log3(0, 0, signature, 5, 6) // doesn't reference memory cause all arguments are indexed
        }
    }

    function v2EmitLog() external {
        emit SomeLogV2(5, true);
    }

    function v2YulEmitLog() external {
        assembly {
            // keccak256("SomeLogV2(uint256,bool)")
            let
                signature
            := 0x113cea0e4d6903d772af04edb841b17a164bff0f0d88609aedd1c4ac9b0c15c2
            mstore(0x00, 1) // 1 corresponds to true loaded into the first slot in memory
            log2(0, 0x20, signature, 5) // references the first slot for the second argument
        }
    }

    function boom() external {
        assembly {
            selfdestruct(caller())
        }
    }
}