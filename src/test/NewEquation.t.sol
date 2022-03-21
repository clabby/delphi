// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../math/EquationGasEfficient.sol";

contract NewEquationTest is DSTest {

    Equation.Node[] public nodes;
    uint256[] public variables;
    uint256[] public expressions;

    // -----------------------------
    // ARITHMETIC OPERATOR TESTS
    // -----------------------------

    function test_GasEq() public {
        expressions = new uint256[](5);
        expressions[0] = 6;
        expressions[1] = 0;
        expressions[2] = 2;
        expressions[3] = 0;
        expressions[4] = 2;

        (uint256[] memory encoded, uint16[] memory slices) = Equation.encodeExpressions(expressions);

        uint256[] memory decoded = Equation.decodeExpressions(encoded, slices);
        assertEq(decoded[0], expressions[0]);
        assertEq(decoded[1], expressions[1]);
        assertEq(decoded[2], expressions[2]);
        assertEq(decoded[3], expressions[3]);
        assertEq(decoded[4], expressions[4]);

        assertEq(Equation.calculate(decoded, variables), 1e18 + 2);
    }
}