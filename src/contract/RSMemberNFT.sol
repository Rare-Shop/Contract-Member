// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract RSMemberNFT is
    Initializable,
    ERC721Upgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    using Strings for uint256;

    address public signer;

    string private _defaultURI;

    error SignerUnauthorizedAccount(address account);

    uint256 private _nextTokenId;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) external initializer {
        __ERC721_init("Safe Growth SBT", "SBT");
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
    }

    /**
     * @dev Throws if called by any account other than the signer.
     */
    modifier onlySigner() {
        if (signer != _msgSender()) {
            revert SignerUnauthorizedAccount(_msgSender());
        }
        _;
    }

    function setSigner(address _signer) external onlyOwner {
        require(
            _signer != address(0),
            "The input parameters of the address type must not be zero address."
        );
        signer = _signer;
    }

    function mint(address to, uint256 tokenId) internal returns (uint256) {
        require(balanceOf(to) == 0, "SBT: one address can only own one token");
        _mint(to, tokenId);
        return tokenId;
    }

    function mintBatch(address[] calldata addressList) external onlySigner {
        for (uint256 i = 0; i < addressList.length; ) {
            mint(addressList[i], ++_nextTokenId);
            unchecked {
                ++i;
            }
        }
    }

    function setDefaultURI(string calldata uri) external onlyOwner {
        _defaultURI = uri;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        _requireOwned(tokenId);
        return string.concat(_defaultURI, tokenId.toString());
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        require(false, "SBT: Soul Bound Token");
        super.transferFrom(from, to, tokenId);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}
}
