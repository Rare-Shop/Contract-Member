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

    event ClaimRewards(address indexed recipient, uint256 claimedAmount);
    address internal constant REWARDS_SIGNER = 0xA6Ec99f3B80229222d5CB457370E36a3870edb06;
    address public constant USDT_ADDRESS = 0xED85184DC4BECf731358B2C63DE971856623e056;
    IERC20 USDT_ERC20 = IERC20(USDT_ADDRESS);

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
    }

    function claimRewards(
        uint256 totalRewards,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external nonReentrant {
        address payable recipient = payable(msg.sender);
        require(_verfySigner(recipient, totalRewards, _v, _r, _s) == REWARDS_SIGNER, "Invalid signer");
        require(totalRewards > rewardsClaimed[recipient], "Nothing to claim");

        uint256 toClaim = totalRewards - rewardsClaimed[recipient];
        require(USDT_ERC20.balanceOf(address(this)) >= toClaim, "Insufficient USDT balance");
        rewardsClaimed[recipient] = totalRewards;

        emit ClaimRewards(recipient, toClaim);
        USDT_ERC20.safeTransferFrom(
            address(this),
            recipient,
            toClaim
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
                            keccak256("RareShopInviteRewards(address recipient,uint256 totalRewards)"),
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
