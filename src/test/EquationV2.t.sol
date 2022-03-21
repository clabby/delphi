// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../math/EquationV2.sol";

contract EquationV2Test is DSTest {

    // -----------------------------
    // ARITHMETIC OPERATOR TESTS
    // -----------------------------

    function test_EncodeAndDecode() public {
        uint256[] memory expressions = new uint256[](5);
        expressions[0] = 6;
        expressions[1] = 0;
        expressions[2] = 2;
        expressions[3] = 0;
        expressions[4] = 1e18;

        (uint256[] memory encoded, uint16[] memory slices) = EquationV2.encodeExpressions(expressions);
        assertEq(encoded[0], 5708990770823839524233143877797980545530986496000000000000131078);

        uint256[] memory decoded = EquationV2.decodeExpressions(encoded, slices);
        assertEq(decoded[0], expressions[0]);
        assertEq(decoded[1], expressions[1]);
        assertEq(decoded[2], expressions[2]);
        assertEq(decoded[3], expressions[3]);
        assertEq(decoded[4], expressions[4]);
    }
}