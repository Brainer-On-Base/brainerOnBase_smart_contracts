// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Brainer Token ($BRNR)
/// @notice Main utility token for the Brainer Society ecosystem
contract BrainerToken is ERC20, ERC20Burnable, Ownable {
    uint256 public constant MAX_SUPPLY = 10_000_000_000 * 10 ** 18;

    address public liquidtyAndMarketsAddress;
    address public playToEarnAddress;
    address public stakingGovAddress;
    address public marketingAddress;
    address public devAddress;

    /// @notice Initializes the $BRNR token and distributes initial supply
    /// @param _liquidtyAndMarkets Address to receive 55% of total supply
    /// @param _playToEarn Address to receive 20% of total supply
    /// @param _stakingGov Address to receive 10% of total supply
    /// @param _marketing Address to receive 5% of total supply
    /// @param _dev Address to receive 10% of total supply
    constructor(
        address _liquidtyAndMarkets,
        address _playToEarn,
        address _stakingGov,
        address _marketing,
        address _dev
    ) ERC20("Brainer Token", "BRNR") Ownable(msg.sender) {
        require(_liquidtyAndMarkets != address(0), "Invalid liquidity address");
        require(_playToEarn != address(0), "Invalid P2E address");
        require(_stakingGov != address(0), "Invalid staking address");
        require(_marketing != address(0), "Invalid marketing address");
        require(_dev != address(0), "Invalid dev address");

        liquidtyAndMarketsAddress = _liquidtyAndMarkets;
        playToEarnAddress = _playToEarn;
        stakingGovAddress = _stakingGov;
        marketingAddress = _marketing;
        devAddress = _dev;

        // Initial distribution of the total supply
        _mint(liquidtyAndMarketsAddress, (MAX_SUPPLY * 55) / 100); // 55% Liquidity & Markets
        _mint(playToEarnAddress, (MAX_SUPPLY * 20) / 100); // 20% Play to Earn/Burn
        _mint(stakingGovAddress, (MAX_SUPPLY * 10) / 100); // 10% Staking & Governance
        _mint(devAddress, (MAX_SUPPLY * 10) / 100); // 10% Developer wallet
        _mint(marketingAddress, (MAX_SUPPLY * 5) / 100); // 5% Marketing
    }

    /// @notice Mints additional tokens to an address (owner only)
    /// @dev Minting is capped by MAX_SUPPLY
    /// @param to Recipient of minted tokens
    /// @param amount Amount of tokens to mint
    function mint(address to, uint256 amount) external onlyOwner {
        require(totalSupply() + amount <= MAX_SUPPLY, "Exceeds max supply");
        _mint(to, amount);
    }

    /// @notice Burns tokens from a user (typically used by game mechanics)
    /// @dev Can only be called by the owner (game backend/controller)
    /// @param account Address from which tokens will be burned
    /// @param amount Amount of tokens to burn
    function burnFromGame(address account, uint256 amount) external onlyOwner {
        _burn(account, amount);
    }

    /// @notice Prevents receiving ETH directly to the token contract
    receive() external payable {
        revert("No ETH allowed");
    }

    /// @notice Reverts unexpected calls
    fallback() external payable {
        revert("Invalid call");
    }
}
