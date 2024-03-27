// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721 {
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
}

interface IERC721TokenReceiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4);
}

contract NFinTech is IERC721 {
    string private _name;
    string private _symbol;

    uint256 private _tokenId;

    mapping(uint256 => address) private _owner;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApproval;
    mapping(address => bool) private isClaim;
    mapping(address => mapping(address => bool)) private _operatorApproval;

    error ZeroAddress();
    error NotApproved();
    error NotOwner();

    constructor(string memory name_, string memory symbol_) payable {
        _name = name_;
        _symbol = symbol_;
    }

    function claim() public {
        if (!isClaim[msg.sender]) {
            uint256 id = _tokenId;
            _owner[id] = msg.sender;
            _balances[msg.sender]++;
            isClaim[msg.sender] = true;
            _tokenId++;
        }
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function balanceOf(address owner) public view returns (uint256) {
        if (owner == address(0)) revert ZeroAddress();
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owner[tokenId];
        if (owner == address(0)) revert ZeroAddress();
        return owner;
    }

    function setApprovalForAll(address operator, bool approved) external {
    	require(operator != address(0));
        _operatorApproval[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApproval[owner][operator];
    }

    function approve(address to, uint256 tokenId) external {
        address owner = ownerOf(tokenId);
        require(msg.sender == owner || _operatorApproval[owner][msg.sender]);
        _tokenApproval[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address operator) {
        require(_owner[tokenId] != address(0));
        return _tokenApproval[tokenId];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        require(_owner[tokenId] != address(0));
        address owner = ownerOf(tokenId);
        
        require(msg.sender == owner || _tokenApproval[tokenId] == msg.sender || _operatorApproval[owner][msg.sender]);
        require(from == owner);
        require(to != address(0));

        _tokenApproval[tokenId] = to;
        emit Approval(owner, to, tokenId);

        _balances[from] = _balances[from] - 1;
        _balances[to] = _balances[to] + 1;
        _owner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) public {
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, ""), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _transfer(address from, address to, uint256 tokenId) private {
        _owner[tokenId] = to;
        _balances[from]--;
        _balances[to]++;
        emit Transfer(from, to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
        if (_isContract(to)) {
            (bool success, bytes memory response) = to.call(abi.encodeWithSelector(IERC721TokenReceiver(to).onERC721Received.selector, msg.sender, from, tokenId, data));
            return success && (response.length == 0 || abi.decode(response, (bytes4)) == IERC721TokenReceiver(to).onERC721Received.selector);
        } else {
            return true;
        }
    }

    function _isContract(address addr) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}
