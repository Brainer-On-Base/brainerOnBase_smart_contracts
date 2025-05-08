// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

interface INFTCollection {
    function ownerOf(uint256 tokenId) external view returns (address);
}

/// @title Brainer Token Presale Contract
/// @notice Handles token sale and NFT-based claims for $BRNR token
contract BrainerPreSale {
    address public owner;
    IERC20 public brainerToken;
    INFTCollection public nftCollection;

    uint256 public constant PRESALE_SUPPLY = 1_000_000_000 * 1e18;
    uint256 public constant CLAIM_SUPPLY = 500_000_000 * 1e18;
    uint256 public constant TOKENS_PER_NFT = 100_000 * 1e18;

    uint256 public rate = 4_000_000; // 1 ETH = 4M BRNR
    uint256 public minContribution = 0.02 ether;
    uint256 public maxContribution = 5 ether;

    uint256 public totalETHRaised;
    uint256 public tokensSold;
    uint256 public nftClaimedTotal;

    mapping(address => uint256) public totalContributed;
    mapping(uint256 => bool) public nftClaimed; // tokenId => claimed

    event TokensPurchased(
        address indexed buyer,
        uint256 ethAmount,
        uint256 tokenAmount
    );
    event WithdrawETH(address indexed admin, uint256 amount);
    event WithdrawTokens(address indexed admin, uint256 amount);
    event NFTClaimed(address indexed user, uint256 tokenId, uint256 amount);
    event TokensDeposited(address indexed from, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    /// @notice Initializes the presale with token and NFT collection addresses
    /// @param _tokenAddress Address of the $BRNR ERC20 token
    /// @param _nftAddress Address of the PixelBrainer NFT collection
    constructor(address _tokenAddress, address _nftAddress) {
        owner = msg.sender;
        brainerToken = IERC20(_tokenAddress);
        nftCollection = INFTCollection(_nftAddress);
    }

    /// @notice Allows users to buy tokens by sending ETH (fallback method)
    receive() external payable {
        buyTokens();
    }

    /// @notice Reverts if unknown calls are made
    fallback() external {
        revert("Don't send tokens directly");
    }

    /// @notice Users can buy $BRNR tokens with ETH during presale
    function buyTokens() public payable {
        require(msg.value >= minContribution, "Below minimum");
        require(
            totalContributed[msg.sender] + msg.value <= maxContribution,
            "Exceeds max per wallet"
        );

        uint256 tokenAmount = msg.value * rate;
        require(tokenAmount > 0, "Invalid token amount");
        require(
            tokensSold + tokenAmount <= PRESALE_SUPPLY,
            "Presale supply exceeded"
        );

        totalContributed[msg.sender] += msg.value;
        totalETHRaised += msg.value;
        tokensSold += tokenAmount;

        require(
            brainerToken.transfer(msg.sender, tokenAmount),
            "Token transfer failed"
        );

        emit TokensPurchased(msg.sender, msg.value, tokenAmount);
    }

    /// @notice Allows NFT holders to claim tokens once per NFT
    /// @param tokenId ID of the NFT used to claim tokens
    function claimForNFT(uint256 tokenId) external {
        require(
            nftCollection.ownerOf(tokenId) == msg.sender,
            "Not the owner of this NFT"
        );
        require(!nftClaimed[tokenId], "Already claimed");

        nftClaimed[tokenId] = true;
        nftClaimedTotal += TOKENS_PER_NFT;

        require(
            brainerToken.transfer(msg.sender, TOKENS_PER_NFT),
            "Token transfer failed"
        );

        emit NFTClaimed(msg.sender, tokenId, TOKENS_PER_NFT);
    }

    /// @notice Allows the owner to withdraw collected ETH
    /// @param amount Amount to withdraw in wei
    function withdrawETH(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient ETH");
        payable(owner).transfer(amount);
        emit WithdrawETH(msg.sender, amount);
    }

    /// @notice Owner deposits tokens into the contract for presale/claim use
    /// @param amount Amount of $BRNR tokens to deposit
    function depositTokens(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than 0");
        require(
            brainerToken.transferFrom(msg.sender, address(this), amount),
            "Token transfer failed"
        );
        emit TokensDeposited(msg.sender, amount);
    }
}
