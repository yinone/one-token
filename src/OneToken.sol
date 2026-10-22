// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Capped} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @notice 固定上限的 ERC-20：部署时给 owner 铸造初始供应，之后只有 owner 能增发，任何持有人都能销毁自己的币。
contract OneToken is ERC20, ERC20Burnable, ERC20Capped, Ownable {
    constructor(address initialOwner, uint256 initialSupply, uint256 cap_)
        ERC20("One Token", "ONE")
        ERC20Capped(cap_)
        Ownable(initialOwner)
    {
        _mint(initialOwner, initialSupply);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function _update(address from, address to, uint256 value) internal override(ERC20, ERC20Capped) {
        super._update(from, to, value);
    }
}
