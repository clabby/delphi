// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.10;

import "./SafeMath.sol";
import "./BancorPower.sol";

/**
 * Modified version of Band Protocol's Equation.sol
 *
 * https://github.com/bandprotocol/contracts/blob/master/contracts/utils/Equation.sol
 * Licensed under Apache License, Version 2.0.
 */
library EquationV2 {
    using SafeMath for uint256;

    /// An expression tree is encoded as a set of nodes, with root node having index zero. Each node has 3 values:
    ///  1. opcode: the expression that the node represents. See table below.
    /// +--------+----------------------------------------+------+------------+
    /// | Opcode |              Description               | i.e. | # children |
    /// +--------+----------------------------------------+------+------------+
    /// |   00   | Integer Constant                       |   c  |      0     |
    /// |   01   | Variable                               |   X  |      0     |
    /// |   02   | Arithmetic Square Root                 |   √  |      1     |
    /// |   03   | Boolean Not Condition                  |   !  |      1     |
    /// |   04   | Arithmetic Addition                    |   +  |      2     |
    /// |   05   | Arithmetic Subtraction                 |   -  |      2     |
    /// |   06   | Arithmetic Multiplication              |   *  |      2     |
    /// |   07   | Arithmetic Division                    |   /  |      2     |
    /// |   08   | Arithmetic Exponentiation              |  **  |      2     |
    /// |   09   | Arithmetic Percentage* (see below)     |   %  |      2     |
    /// |   10   | Arithmetic Equal Comparison            |  ==  |      2     |
    /// |   11   | Arithmetic Non-Equal Comparison        |  !=  |      2     |
    /// |   12   | Arithmetic Less-Than Comparison        |  <   |      2     |
    /// |   13   | Arithmetic Greater-Than Comparison     |  >   |      2     |
    /// |   14   | Arithmetic Non-Greater-Than Comparison |  <=  |      2     |
    /// |   15   | Arithmetic Non-Less-Than Comparison    |  >=  |      2     |
    /// |   16   | Boolean And Condition                  |  &&  |      2     |
    /// |   17   | Boolean Or Condition                   |  ||  |      2     |
    /// |   18   | Ternary Operation                      |  ?:  |      3     |
    /// |   19   | Bancor's log** (see below)             |      |      3     |
    /// |   20   | Bancor's power*** (see below)          |      |      4     |
    /// +--------+----------------------------------------+------+------------+
    ///  2. children: the list of node indices of this node's sub-expressions. Different opcode nodes will have different
    ///     number of children.
    ///  3. value: the value inside the node. Currently this is only relevant for Integer Constant (Opcode 00).
    ///     3.1. MODIFICATION: value is also used for Variable (Opcode 01). Here it designates the index of the
    ///          variable's value inside of the passed "variables" array.
    /// (*) Arithmetic percentage is computed by multiplying the left-hand side value with the right-hand side,
    ///     and divide the result by 10^18, rounded down to uint256 integer.
    /// (**) Using BancorFormula, the opcode computes log of fractional numbers. However, this fraction's value must
    ///     be more than 1. (baseN / baseD >= 1). The opcode takes 3 childrens(c, baseN, baseD), and computes
    ///     (c * log(baseN / baseD)) limitation is in range of 1 <= baseN / baseD <= 58774717541114375398436826861112283890
    ///     (= 1e76/FIXED_1), where FIXED_1 defined in BancorPower.sol
    /// (***) Using BancorFomula, the opcode computes exponential of fractional numbers. The opcode takes 4 children
    ///     (c,baseN,baseD,expV), and computes (c * ((baseN / baseD) ^ (expV / 1e6))). See implementation for the
    ///     limitation of the each value's domain. The end result must be in uint256 range.

    enum ExprType { Invalid, Math, Boolean }

    uint8 constant OPCODE_CONST = 0;
    uint8 constant OPCODE_VAR = 1;
    uint8 constant OPCODE_SQRT = 2;
    uint8 constant OPCODE_NOT = 3;
    uint8 constant OPCODE_ADD = 4;
    uint8 constant OPCODE_SUB = 5;
    uint8 constant OPCODE_MUL = 6;
    uint8 constant OPCODE_DIV = 7;
    uint8 constant OPCODE_EXP = 8;
    uint8 constant OPCODE_PCT = 9;
    uint8 constant OPCODE_EQ =  10;
    uint8 constant OPCODE_NE = 11;
    uint8 constant OPCODE_LT = 12;
    uint8 constant OPCODE_GT = 13;
    uint8 constant OPCODE_LE = 14;
    uint8 constant OPCODE_GE = 15;
    uint8 constant OPCODE_AND = 16;
    uint8 constant OPCODE_OR = 17;
    uint8 constant OPCODE_IF = 18;
    uint8 constant OPCODE_BANCOR_LOG = 19;
    uint8 constant OPCODE_BANCOR_POWER = 20;
    uint8 constant OPCODE_INVALID = 21;

    /// Calculate the Y position from the X position for this equation.
    function calculate(uint256[] memory self, uint256[] memory variables) public view returns (uint256) {
        return solveMath(self, 0, variables);
    }

    /// Return the number of children the given opcode node has.
    function getChildrenCount(uint8 opcode) private pure returns (uint8) {
        if (opcode <= OPCODE_VAR) {
            return 0;
        } else if (opcode <= OPCODE_NOT) {
            return 1;
        } else if (opcode <= OPCODE_OR) {
            return 2;
        } else if (opcode <= OPCODE_BANCOR_LOG) {
            return 3;
        } else if (opcode <= OPCODE_BANCOR_POWER) {
            return 4;
        }
        revert();
    }

    /// Check whether the given opcode and list of expression types match. Revert on failure.
    function checkExprType(uint8 opcode, ExprType[] memory types)
    private pure returns (ExprType)
    {
        if (opcode <= OPCODE_VAR) {
            return ExprType.Math;
        } else if (opcode == OPCODE_SQRT) {
            require(types[0] == ExprType.Math);
            return ExprType.Math;
        } else if (opcode == OPCODE_NOT) {
            require(types[0] == ExprType.Boolean);
            return ExprType.Boolean;
        } else if (opcode >= OPCODE_ADD && opcode <= OPCODE_PCT) {
            require(types[0] == ExprType.Math);
            require(types[1] == ExprType.Math);
            return ExprType.Math;
        } else if (opcode >= OPCODE_EQ && opcode <= OPCODE_GE) {
            require(types[0] == ExprType.Math);
            require(types[1] == ExprType.Math);
            return ExprType.Boolean;
        } else if (opcode >= OPCODE_AND && opcode <= OPCODE_OR) {
            require(types[0] == ExprType.Boolean);
            require(types[1] == ExprType.Boolean);
            return ExprType.Boolean;
        } else if (opcode == OPCODE_IF) {
            require(types[0] == ExprType.Boolean);
            require(types[1] != ExprType.Invalid);
            require(types[1] == types[2]);
            return types[1];
        } else if (opcode == OPCODE_BANCOR_LOG) {
            require(types[0] == ExprType.Math);
            require(types[1] == ExprType.Math);
            require(types[2] == ExprType.Math);
            return ExprType.Math;
        } else if (opcode == OPCODE_BANCOR_POWER) {
            require(types[0] == ExprType.Math);
            require(types[1] == ExprType.Math);
            require(types[2] == ExprType.Math);
            require(types[3] == ExprType.Math);
            return ExprType.Math;
        }
        revert();
    }

    /*function findOrder(
        uint256[] memory self,
        uint256[] memory order,
        uint8 currentNodeIndex
    ) private returns (uint8, ExprType) {
        require(currentNodeIndex < self.length);
        uint256 node = self[currentNodeIndex];
        uint8 opcode = node.opcode;
        uint8 childrenCount = getChildrenCount(opcode);
        ExprType[] memory childrenTypes = new ExprType[](childrenCount);
        uint8 lastNodeIdx = currentNodeIndex;
        for (uint8 idx = 0; idx < childrenCount; ++idx) {
            if (idx == 0) node.child0 = lastNodeIdx + 1;
            else if (idx == 1) node.child1 = lastNodeIdx + 1;
            else if (idx == 2) node.child2 = lastNodeIdx + 1;
            else if (idx == 3) node.child3 = lastNodeIdx + 1;
            else revert();
            (lastNodeIdx, childrenTypes[idx]) = populateTree(self, lastNodeIdx + 1);
        }
        ExprType exprType = checkExprType(opcode, childrenTypes);
        return (lastNodeIdx, exprType);
    }*/

    function solveMath(
        uint256[] memory self,
        uint8 nodeIdx,
        uint256[] memory variables
    ) private view returns (uint256) {
        uint8 opcode = uint8(self[nodeIdx]);
        if (opcode == OPCODE_CONST) {
            return self[nodeIdx + 1];
        } else if (opcode == OPCODE_VAR) {
            return variables[self[nodeIdx + 1]]; // for variables, set "value" to the index of the variable's value in uint256[] variables
        } else if (opcode == OPCODE_SQRT) {
            uint256 childValue = solveMath(self, nodeIdx + 1, variables);
            uint256 temp = childValue.add(1).div(2);
            uint256 result = childValue;
            while (temp < result) {
                result = temp;
                temp = childValue.div(temp).add(temp).div(2);
            }
            return result;
        } else if (opcode >= OPCODE_ADD && opcode <= OPCODE_PCT) {
            uint256 leftValue = solveMath(self, nodeIdx + 1, variables);
            uint256 rightValue = solveMath(self, nodeIdx + 2, variables);
            if (opcode == OPCODE_ADD) {
                return leftValue.add(rightValue);
            } else if (opcode == OPCODE_SUB) {
                return leftValue.sub(rightValue);
            } else if (opcode == OPCODE_MUL) {
                return leftValue.mul(rightValue);
            } else if (opcode == OPCODE_DIV) {
                return leftValue.div(rightValue);
            } else if (opcode == OPCODE_EXP) {
                uint256 power = rightValue;
                uint256 expResult = 1;
                for (uint256 idx; idx < power;) {
                    expResult = expResult.mul(leftValue);
                    unchecked { ++idx; }
                }
                return expResult;
            } else if (opcode == OPCODE_PCT) {
                return leftValue.mul(rightValue).div(1e18);
            }
        } else if (opcode == OPCODE_IF) {
            bool condValue = solveBool(self, nodeIdx + 1, variables);
            if (condValue) return solveMath(self, nodeIdx + 2, variables);
            else return solveMath(self, nodeIdx + 3, variables);
        } else if (opcode == OPCODE_BANCOR_LOG) {
            uint256 multiplier = solveMath(self, nodeIdx + 1, variables);
            uint256 baseN = solveMath(self, nodeIdx + 2, variables);
            uint256 baseD = solveMath(self, nodeIdx + 3, variables);
            return BancorPower.log(multiplier, baseN, baseD);
        } else if (opcode == OPCODE_BANCOR_POWER) {
            uint256 multiplier = solveMath(self, nodeIdx + 1, variables);
            uint256 baseN = solveMath(self, nodeIdx + 2, variables);
            uint256 baseD = solveMath(self, nodeIdx + 3, variables);
            uint256 expV = solveMath(self, nodeIdx + 4, variables);
            require(expV < 1 << 32);
            (uint256 expResult, uint8 precision) = BancorPower.power(baseN, baseD, uint32(expV), 1e6);
            return expResult.mul(multiplier) >> precision;
        }
        revert();
    }

    function solveBool(uint256[] memory self, uint8 nodeIdx, uint256[] memory variables)
    private view returns (bool)
    {
        uint8 opcode = uint8(self[nodeIdx]);
        if (opcode == OPCODE_NOT) {
            return !solveBool(self, nodeIdx + 1, variables);
        } else if (opcode >= OPCODE_EQ && opcode <= OPCODE_GE) {
            uint256 leftValue = solveMath(self, nodeIdx + 1, variables);
            uint256 rightValue = solveMath(self, nodeIdx + 2, variables);
            if (opcode == OPCODE_EQ) {
                return leftValue == rightValue;
            } else if (opcode == OPCODE_NE) {
                return leftValue != rightValue;
            } else if (opcode == OPCODE_LT) {
                return leftValue < rightValue;
            } else if (opcode == OPCODE_GT) {
                return leftValue > rightValue;
            } else if (opcode == OPCODE_LE) {
                return leftValue <= rightValue;
            } else if (opcode == OPCODE_GE) {
                return leftValue >= rightValue;
            }
        } else if (opcode >= OPCODE_AND && opcode <= OPCODE_OR) {
            bool leftBoolValue = solveBool(self, nodeIdx + 1, variables);
            if (opcode == OPCODE_AND) {
                if (leftBoolValue) return solveBool(self, nodeIdx + 2, variables);
                else return false;
            } else if (opcode == OPCODE_OR) {
                if (leftBoolValue) return true;
                else return solveBool(self, nodeIdx + 2, variables);
            }
        } else if (opcode == OPCODE_IF) {
            bool condValue = solveBool(self, nodeIdx + 1, variables);
            if (condValue) return solveBool(self, nodeIdx + 2, variables);
            else return solveBool(self, nodeIdx + 3, variables);
        }
        revert();
    }

    function encodeExpressions(uint256[] memory _expressions) public view returns (
        uint256[] memory encoded,
        uint16[] memory slices
    ) {
        encoded = new uint256[](1);
        slices = new uint16[](_expressions.length);

        encoded[0] |= _expressions[0];

        uint256 expr;
        uint8 idx;
        uint16 shiftAmount;
        for (uint8 i = 1; i < _expressions.length;) {
            expr = _expressions[i];
            shiftAmount += expr > 255 ? 128 : 8; // If the number will overflow a uint8, set its slot to a uint128

            // If we're about to overflow the uint256, add another one to the array
            if (shiftAmount > 256) {
                shiftAmount = 0;
                unchecked { ++idx; }
            }

            encoded[idx] |= expr << shiftAmount;
            slices[i] = shiftAmount;
            unchecked { ++i; }
        }
    }

    function decodeExpressions(
        uint256[] memory _encoded,
        uint16[] memory slices
    ) public view returns (uint256[] memory expressions) {
        expressions = new uint256[](slices.length);
        uint8 idx;

        expressions[0] = uint8(_encoded[0]); // The first expression will always be in the first 8 bits of the encoded expression

        uint16 a;
        uint16 b;
        for (uint8 i = 1; i < slices.length; i++) {
            a = slices[i];
            b = slices[i - 1];
            if (a < b) {
                unchecked { ++idx; }
            }

            expressions[i] = uint256(
                a - b == 128
                ? uint128(_encoded[idx] >> slices[i])
                : uint8(_encoded[idx] >> slices[i])
            );
        }
    }
}