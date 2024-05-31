//SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

// .slot .offset
contract StorageBasics {
    uint256 x;
    uint256 y = 13;
    uint256 z = 54;
    uint256 p;
    uint128 a = 1; // variables are packed, a and b are in the same slot
    uint128 b = 2;

    function getVarYulinBytes(uint256 slot) external view returns (bytes32 ret) {
        assembly {
            ret := sload(slot)
        }
    }

    function getSlot() external pure returns (uint256 slota, uint256 slotb) {
        assembly {
            slota := a.slot // slot is known at compile time, function can be pure
            slotb := b.slot
        }
    }

    function getP() external view returns (uint256) {
        return p;
    }

    function getVarYul(uint256 slot) external view returns (uint256 ret) {
        assembly {
            ret := sload(slot)
        }
    }

    function setVarYul(uint256 slot, uint256 newVal) external {
        assembly {
            sstore(slot, newVal)
        }
    }

    function getYYul() external view returns (uint256 ret) {
        assembly {
            ret := sload(1)
        }
    }

    function getXYul() external view returns (uint256 ret) {
        assembly {
            ret := sload(x.slot)
        }
    }

    function setX(uint256 newVal) external {
        x = newVal;
    }

    function getX() external view returns (uint256) {
        return x;
    }
}
