// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract RareShopInviteRewards is ReentrancyGuardUpgradeable,OwnableUpgradeable,UUPSUpgradeable {

    using SafeERC20 for IERC20;

    error SignerUnauthorizedAccount(address account);

    event ClaimRewards(address indexed recipient, uint256 claimedAmount);

    address public constant USDT_ADDRESS = 0x05D032ac25d322df992303dCa074EE7392C117b9;

    IERC20 USDT_ERC20;

    address internal signer;

    bytes32 DOMAIN_SEPARATOR;

    mapping(address => uint256) public rewardsClaimed;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) external initializer {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        DOMAIN_SEPARATOR = _computeDomainSeparator();
        USDT_ERC20 = IERC20(USDT_ADDRESS);
    }

    function setSigner(address _signer) external onlyOwner {
        require(_signer != address(0),"invalid address");
        signer = _signer;
    }

    function claimRewards(
        uint256 totalRewards,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external nonReentrant {
        address payable recipient = payable(msg.sender);
        require(_verfySigner(recipient, totalRewards, _v, _r, _s) == signer, "Invalid signer");
        require(totalRewards > rewardsClaimed[recipient], "Nothing to claim");

        uint256 toClaim = totalRewards - rewardsClaimed[recipient];
        require(USDT_ERC20.balanceOf(address(this)) >= toClaim, "Insufficient USDT balance");
        rewardsClaimed[recipient] = totalRewards;

        emit ClaimRewards(recipient, toClaim);
        USDT_ERC20.safeTransfer(
            recipient,
            toClaim
        );
    }

    function withdraw(address to) external onlyOwner {
        require(to != address(0), "invalid address");
        require(USDT_ERC20.balanceOf(address(this)) > 0, "USDT balance is 0");

        address payable recipient = payable(to);
        uint256 balance = USDT_ERC20.balanceOf(address(this));
        emit ClaimRewards(recipient, balance);

        USDT_ERC20.safeTransfer(
            recipient,
            balance
        );
    }

    function _verfySigner(
        address recipient,
        uint256 totalRewards,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) internal view returns (address _signer) {
        _signer = ECDSA.recover(
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    keccak256(
                        abi.encode(
                            keccak256("claimRewards(address recipient,uint256 totalRewards)"),
                            recipient,
                            totalRewards
                        )
                    )
                )
            ), _v, _r, _s
        );
    }

    function _computeDomainSeparator() internal view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256(
                        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                    ),
                    keccak256(bytes("RareShopInviteRewards")),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
