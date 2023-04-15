// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "interfaces/ISafe.sol";

import {BaseModule} from "../BaseModule.sol";

contract RevokeModule is BaseModule {
    ////////////////////////////////////////////////////////////////////////////
    // INMUTABLE VARIABLES
    ////////////////////////////////////////////////////////////////////////////
    ISafe public immutable safe;

    ////////////////////////////////////////////////////////////////////////////
    // EVENTS
    ////////////////////////////////////////////////////////////////////////////

    event Revoked(address safe, address token, address spender, address signer, uint256 timestamp);

    constructor(ISafe _safe) {
        safe = ISafe(_safe);
    }

    function revoke(address token, address spender) external isSigner(safe) {
        if (!safe.isModuleEnabled(address(this))) revert ModuleMisconfigured();

        uint256 allowanceAmount = IERC20(token).allowance(address(safe), spender);
        if (allowanceAmount > 0) {
            _checkTransactionAndExecute(safe, token, abi.encodeCall(IERC20.approve, (spender, 0)));
            emit Revoked(address(safe), token, spender, msg.sender, block.timestamp);
        }
    }
}
