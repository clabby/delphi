// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "ds-test/test.sol";
import "../math/Equation.sol";

contract EquationTest is DSTest {
    Equation.Node[] public nodes;
    uint256[] public variables;

    // -----------------------------
    // ARITHMETIC OPERATOR TESTS
    // -----------------------------

    function test_Addition(uint128 a, uint128 b) public {
        uint256[] memory expressions = new uint256[](5);
        expressions[0] = 4;
        expressions[1] = 0;
        expressions[2] = a;
        expressions[3] = 0;
        expressions[4] = b;

        Equation.init(nodes, expressions);
        assertEq(Equation.calculate(nodes, variables), uint256(a) + uint256(b));
    }

    function test_Subtraction(uint256 a, uint256 b) public {
        bool aGt = a > b;
        uint temp = a;
        a = aGt ? a : b;
        b = aGt ? b : temp;

        uint256[] memory expressions = new uint256[](5);
        expressions[0] = 5;
        expressions[1] = 0;
        expressions[2] = a;
        expressions[3] = 0;
        expressions[4] = b;

        Equation.init(nodes, expressions);
        assertEq(Equation.calculate(nodes, variables), a - b);
    }

    function test_Multiplication(uint128 a, uint128 b) public {
        uint256[] memory expressions = new uint256[](5);
        expressions[0] = 6;
        expressions[1] = 0;
        expressions[2] = a;
        expressions[3] = 0;
        expressions[4] = b;

        Equation.init(nodes, expressions);
        assertEq(Equation.calculate(nodes, variables), uint256(a) * uint256(b));
    }

    function test_Division(uint256 a, uint256 b) public {
        bool aGt = a > b;
        uint temp = a;
        a = aGt ? a : b;
        b = aGt ? b : temp;

        if (b == 0) return; // skip division by 0 revert

        uint256[] memory expressions = new uint256[](5);
        expressions[0] = 7;
        expressions[1] = 0;
        expressions[2] = a;
        expressions[3] = 0;
        expressions[4] = b;

        Equation.init(nodes, expressions);
        assertEq(Equation.calculate(nodes, variables), a / b);
    }

    // Only test exponent of 2, large exponents will always overflow with large bases.
    function test_Exponent(uint128 a) public {
        uint256[] memory expressions = new uint256[](5);
        expressions[0] = 8;
        expressions[1] = 0;
        expressions[2] = a;
        expressions[3] = 0;
        expressions[4] = 2;

        Equation.init(nodes, expressions);
        assertEq(Equation.calculate(nodes, variables), uint256(a) ** expressions[4]);
    }

    function test_Percentage(uint128 a, uint128 b) public {
        uint256[] memory expressions = new uint256[](5);
        expressions[0] = 9;
        expressions[1] = 0;
        expressions[2] = a;
        expressions[3] = 0;
        expressions[4] = b;

        Equation.init(nodes, expressions);
        assertEq(Equation.calculate(nodes, variables), uint256(a) * uint256(b) / 1 ether);
    }

    // -----------------------------
    // BOOLEAN OPERATOR TESTS
    // -----------------------------

    function test_BooleanNot() public {
        uint256[] memory expressions = new uint256[](11);
        // !(1 == 2) ? 1 : 0
        expressions[0] = 18;
        expressions[1] = 3;
        expressions[2] = 10;
        expressions[3] = 0;
        expressions[4] = 1;
        expressions[5] = 0;
        expressions[6] = 2;
        expressions[7] = 0;
        expressions[8] = 1;
        expressions[9] = 0;
        expressions[10] = 0;

        Equation.init(nodes, expressions);
        assertEq(Equation.calculate(nodes, variables), 1);
    }

    function test_Equality() public {
        uint256[] memory expressions = new uint256[](10);
        // 1 == 2 ? 1 : 0
        expressions[0] = 18;
        expressions[1] = 10;
        expressions[2] = 0;
        expressions[3] = 1;
        expressions[4] = 0;
        expressions[5] = 2;
        expressions[6] = 0;
        expressions[7] = 1;
        expressions[8] = 0;
        expressions[9] = 0;

        Equation.init(nodes, expressions);
        assertEq(Equation.calculate(nodes, variables), 0);
    }

    function test_Inequality() public {
        uint256[] memory expressions = new uint256[](10);
        // 1 != 2 ? 1 : 0
        expressions[0] = 18;
        expressions[1] = 11;
        expressions[2] = 0;
        expressions[3] = 1;
        expressions[4] = 0;
        expressions[5] = 2;
        expressions[6] = 0;
        expressions[7] = 1;
        expressions[8] = 0;
        expressions[9] = 0;

        Equation.init(nodes, expressions);
        assertEq(Equation.calculate(nodes, variables), 1);
    }

    function test_LessThan() public {
        uint256[] memory expressions = new uint256[](10);
        // 1 < 2 ? 1 : 0
        expressions[0] = 18;
        expressions[1] = 12;
        expressions[2] = 0;
        expressions[3] = 1;
        expressions[4] = 0;
        expressions[5] = 2;
        expressions[6] = 0;
        expressions[7] = 1;
        expressions[8] = 0;
        expressions[9] = 0;

        Equation.init(nodes, expressions);
        assertEq(Equation.calculate(nodes, variables), 1);
    }

    function test_GreaterThan() public {
        uint256[] memory expressions = new uint256[](10);
        // 1 > 2 ? 1 : 0
        expressions[0] = 18;
        expressions[1] = 13;
        expressions[2] = 0;
        expressions[3] = 1;
        expressions[4] = 0;
        expressions[5] = 2;
        expressions[6] = 0;
        expressions[7] = 1;
        expressions[8] = 0;
        expressions[9] = 0;

        Equation.init(nodes, expressions);
        assertEq(Equation.calculate(nodes, variables), 0);
    }

    function test_LessThanEqualTo() public {
        uint256[] memory expressions = new uint256[](10);
        // 1 <= 2 ? 1 : 0
        expressions[0] = 18;
        expressions[1] = 14;
        expressions[2] = 0;
        expressions[3] = 1;
        expressions[4] = 0;
        expressions[5] = 2;
        expressions[6] = 0;
        expressions[7] = 1;
        expressions[8] = 0;
        expressions[9] = 0;

        Equation.init(nodes, expressions);
        assertEq(Equation.calculate(nodes, variables), 1);
    }

    function test_GreaterThanEqualTo() public {
        uint256[] memory expressions = new uint256[](10);
        // 1 >= 2 ? 1 : 0
        expressions[0] = 18;
        expressions[1] = 15;
        expressions[2] = 0;
        expressions[3] = 1;
        expressions[4] = 0;
        expressions[5] = 2;
        expressions[6] = 0;
        expressions[7] = 1;
        expressions[8] = 0;
        expressions[9] = 0;

        Equation.init(nodes, expressions);
        assertEq(Equation.calculate(nodes, variables), 0);
    }

    function test_BooleanAnd() public {
        uint256[] memory expressions = new uint256[](16);
        // (1 >= 1 && 1 == 1) ? 1 : 0
        expressions[0] = 18;
        expressions[1] = 16;
        expressions[2] = 15;
        expressions[3] = 0;
        expressions[4] = 1;
        expressions[5] = 0;
        expressions[6] = 1;
        expressions[7] = 10;
        expressions[8] = 0;
        expressions[9] = 1;
        expressions[10] = 0;
        expressions[11] = 1;
        expressions[12] = 0;
        expressions[13] = 1;
        expressions[14] = 0;
        expressions[15] = 0;

        Equation.init(nodes, expressions);
        assertEq(Equation.calculate(nodes, variables), 1);
    }

    function test_BooleanOr() public {
        uint256[] memory expressions = new uint256[](16);
        // (1 >= 2 || 1 == 1) ? 1 : 0
        expressions[0] = 18;
        expressions[1] = 17;
        expressions[2] = 15;
        expressions[3] = 0;
        expressions[4] = 1;
        expressions[5] = 0;
        expressions[6] = 2;
        expressions[7] = 10;
        expressions[8] = 0;
        expressions[9] = 1;
        expressions[10] = 0;
        expressions[11] = 1;
        expressions[12] = 0;
        expressions[13] = 1;
        expressions[14] = 0;
        expressions[15] = 0;

        Equation.init(nodes, expressions);
        assertEq(Equation.calculate(nodes, variables), 1);
    }
}