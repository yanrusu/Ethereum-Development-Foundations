// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//  safeTransfer，檢查接收方。
interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

contract ERC721_14 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    // 單一 token 的授權
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    // 全部 token 授權
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // NFT 基本資訊
    string private _name;
    string private _symbol;

    // 最多發行 100 顆，每次 mint 需支付 0.001 ETH。
    uint256 public constant MAX_SUPPLY = 100;
    uint256 public constant MINT_PRICE = 0.001 ether;

    // 下一顆要鑄造的 tokenId（從 0 開始）
    uint256 private _tokenId = 0;

    // tokenId => 擁有者地址
    mapping(uint256 => address) private _owners;
    // 擁有者地址 => 持有 NFT 數量
    mapping(address => uint256) private _balances;
    // tokenId => 單顆 token 被授權的地址
    mapping(uint256 => address) private _tokenApprovals;
    // owner => operator => 是否為全部授權
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    //設定 NFT 名稱與代號
    constructor() {
        _name = "MyERC721";
        _symbol = "MYNFT";
    }

    // 讀取 NFT 名稱
    function name() external view returns (string memory) {
        return _name;
    }

    // 讀取 NFT 代號
    function symbol() external view returns (string memory) {
        return _symbol;
    }
    // 查詢某地址持有幾顆 NFT 零地址不可查詢
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "Zero address");
        return _balances[owner];
    }

    // 查詢某顆 token 的擁有者
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "Token does not exist");
        return owner;
    }

    // 授權某地址可操作指定 token
    // 只有 token 擁有者或其已授權者可以呼叫
    function approve(address to, uint256 tokenId) external {
        address owner = ownerOf(tokenId);
        require(to != owner, "Approve to current owner");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "Not authorized");

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
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
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
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

        _tokenId += 1;

        _balances[msg.sender] += 1;
        _owners[_tokenId] = msg.sender;

        emit Transfer(address(0), msg.sender, _tokenId);
    }

    // 目前總供應量 = 已鑄造 token 數量
    function totalSupply() public view returns (uint256) {
        return _tokenId;
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) private view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
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
