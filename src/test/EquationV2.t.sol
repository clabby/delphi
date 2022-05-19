// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "../math/EquationV2.sol";
import "solmate/test/utils/DSTestPlus.sol";

contract EquationV2Test is DSTestPlus {

    // -----------------------------
    // ARITHMETIC OPERATOR TESTS
    // -----------------------------

    uint8[] public slices;
    uint256[] public encodedExpression;

    function test_EncodeAndDecode() public {
        // 1e24 / (1e18 * 2)
        uint256[] memory expressions = new uint256[](9);
        expressions[0] = 7;
        expressions[1] = 6;
        expressions[2] = 0;
        expressions[3] = 1e24;
        expressions[4] = 6;
        expressions[5] = 0;
        expressions[6] = 1e18;
        expressions[7] = 0;
        expressions[8] = 2;

        startMeasuringGas("Encode Expressions");
        EquationV2.packExpression(expressions, encodedExpression, slices);
        stopMeasuringGas();

        uint256[] memory decoded = EquationV2.unpackExpression(encodedExpression, slices);
        assertUintArrayEq(expressions, decoded);
    }

    function test_Math() public {
        uint256[] memory expressions = new uint256[](8);
        expressions[0] = 6;
        expressions[1] = 0;
        expressions[2] = 2;
        expressions[3] = 6;
        expressions[4] = 0;
        expressions[5] = 2;
        expressions[6] = 0;
        expressions[7] = 2;

        EquationV2.packExpression(expressions, encodedExpression, slices);

        uint256[] memory expression = EquationV2.unpackExpression(encodedExpression, slices);
        uint256[] memory variables;
        EquationV2.calculate(expression, variables);
    }
}