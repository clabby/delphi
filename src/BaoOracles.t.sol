// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "ds-test/test.sol";

import "./BaoOracles.sol";

contract BaoOraclesTest is DSTest {
    BaoOracles oracles;

    function setUp() public {
        oracles = new BaoOracles();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
