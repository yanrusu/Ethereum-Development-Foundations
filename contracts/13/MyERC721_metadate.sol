// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/Strings.sol";


interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

contract MyERC72_metadata {
    using Strings for uint256;
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // NFT 基本資訊
    string private _name;
    string private _symbol;

    // 最多發行 100 顆，每次 mint 需支付 0.001 ETH。
    uint256 public constant MAX_SUPPLY = 100;
    uint256 public constant MINT_PRICE = 0.001 ether;

    // 下一顆要鑄造的 tokenId（從 1 開始）
    uint256 private _nextTokenId = 1;

    // tokenId => 擁有者地址
    mapping(uint256 => address) private _owners;
    // 擁有者地址 => 持有 NFT 數量
    mapping(address => uint256) private _balances;
    // tokenId => 單顆 token 被授權的地址
    mapping(uint256 => address) private _tokenApprovals;
    // owner => operator => 是否為全部授權
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Metadata 
    string private _baseTokenURI;
    mapping(uint256 => string) private _tokenURIs;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    //設定 NFT 名稱與代號
    constructor() {
        _name = "MyERC721";
        _symbol = "MYNFT";
        owner = msg.sender;
        _baseTokenURI = "ipfs://"; // 預設 baseURI
    }

    // 讀取 NFT 名稱
    function name() external view returns (string memory) {
        return _name;
    }

    // 讀取 NFT 代號
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    // Metadata

    function setBaseURI(string calldata newBaseURI) external onlyOwner {
        _baseTokenURI = newBaseURI;
    }

    function baseURI() external view returns (string memory) {
        return _baseTokenURI;
    }

    function setTokenURI(uint256 tokenId, string calldata uri) external {
        require(_owners[tokenId] != address(0), "Token does not exist");
        require(msg.sender == _owners[tokenId] || msg.sender == owner, "Not authorized");
        _tokenURIs[tokenId] = uri;
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token does not exist");

        // 若有單顆設定，優先回傳
        string memory specific = _tokenURIs[tokenId];
        if (bytes(specific).length > 0) {
            return specific;
        }

        // 否則回傳 baseURI + tokenId + ".json"
        return string(abi.encodePacked(_baseTokenURI, Strings.toString(tokenId), ".json"));
    }

    // ERC721

    // 查詢某地址持有幾顆 NFT 零地址不可查詢
    function balanceOf(address owner_) public view returns (uint256) {
        require(owner_ != address(0), "Zero address");
        return _balances[owner_];
    }

    // 查詢某顆 token 的擁有者
    function ownerOf(uint256 tokenId) public view returns (address) {
        address tokenOwner = _owners[tokenId];
        require(tokenOwner != address(0), "Token does not exist");
        return tokenOwner;
    }

    // 授權某地址可操作指定 token
    // 只有 token 擁有者或其已授權者可以呼叫
    function approve(address to, uint256 tokenId) external {
        address tokenOwner = ownerOf(tokenId);
        require(to != tokenOwner, "Approve to current owner");
        require(msg.sender == tokenOwner || isApprovedForAll(tokenOwner, msg.sender), "Not authorized");

        _tokenApprovals[tokenId] = to;
        emit Approval(tokenOwner, to, tokenId);
    }

    // 查詢指定 token 的單顆授權地址。
    function getApproved(uint256 tokenId) public view returns (address) {
        ownerOf(tokenId);
        return _tokenApprovals[tokenId];
    }

    // 設定或取消全部授權
    function setApprovalForAll(address operator, bool approved) external {
        require(operator != msg.sender, "Approve to caller");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    // 查詢 operator 是否有 owner 的全部NFT授權
    function isApprovedForAll(address tokenOwner, address operator) public view returns (bool) {
        return _operatorApprovals[tokenOwner][operator];
    }

    // 基本轉移 不檢查接收方是否為可接收 NFT 的合約
    function safeTransferFrom(address from, address to, uint256 tokenId) external {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not owner nor approved");
        require(ownerOf(tokenId) == from, "Wrong from");
        require(to != address(0), "Transfer to zero");

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    // 安全轉移若 to 是合約，必須回傳正確 selector
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public {
        require(_checkOnERC721Received(from, to, tokenId, data), "Unsafe recipient");
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not owner nor approved");
        require(ownerOf(tokenId) == from, "Wrong from");
        require(to != address(0), "Transfer to zero");

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    // 每次 mint 一顆。
    function mint() external payable {
        require(msg.value == MINT_PRICE, "Mint price is 0.001 ETH");
        require(totalSupply() < MAX_SUPPLY, "Max supply reached");

        uint256 tokenId = _nextTokenId;
        _nextTokenId += 1;

        _balances[msg.sender] += 1;
        _owners[tokenId] = msg.sender;

        emit Transfer(address(0), msg.sender, tokenId);
    }

    // 目前總供應量 = 已鑄造 token 數量
    function totalSupply() public view returns (uint256) {
        return _nextTokenId - 1;
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) private view returns (bool) {
        address tokenOwner = ownerOf(tokenId);
        return (spender == tokenOwner || getApproved(tokenId) == spender || isApprovedForAll(tokenOwner, spender));
    }

    // 若接收方是合約，檢查其是否可以接收 onERC721Received
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
        if (to.code.length == 0) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(
            msg.sender, from, tokenId, data);
        return (retval == IERC721Receiver.onERC721Received.selector);
    }
}