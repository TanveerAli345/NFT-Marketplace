// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './ERC165.sol';
import './interfaces/IERC721.sol';

/*

To build the minting function, we want -
    a. the nft to point to an address
    b. to keep track of the token IDs
    c. to keep track of token owner addresses to token IDs
    d. to keep track of how many tokens an owner address has
    e. to create an event that emits a transfer log - contract address,
    where its being minted to, the ID 

*/

contract ERC721 is ERC165, IERC721 {

    mapping(uint256 => address) private _tokenOwner;

    mapping(address => uint256) private _ownedTokensCount;

    mapping(uint256 => address) private _tokenApprovals;

    constructor() {
        _registerInterface(bytes4(keccak256('ownerOf(bytes4)')^
        keccak256('tranferFrom(bytes4)')^keccak256('balanceOf(bytes4)')));
    }

    function balanceOf(address _owner) public override view returns(uint256) {
        require(_owner != address(0), 'token doesnt exist');
        return _ownedTokensCount[_owner];
    }

    function ownerOf(uint256 _tokenId) public override view returns(address) {
        address owner = _tokenOwner[_tokenId];
        require(owner != address(0), 'token doesnt exist');
        return owner;
    }

    function _exists(uint256 tokenId) internal view returns(bool) {
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), 'ERC721: minting to the zero address');
        require(!_exists(tokenId), 'ERC721: token already minted');

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to] += 1;

        emit Transfer(address(0), to, tokenId);
    }

    function _transferFrom(address _from, address _to, uint256 _tokenId) internal {
        require(_to != address(0), 'ERC721: minting to the zero address');
        require(ownerOf(_tokenId) == _from, 'Dont own the token');

        _ownedTokensCount[_from] -= 1;
        _tokenOwner[_tokenId] = _to;
        _ownedTokensCount[_to] += 1;

        emit Transfer(_from, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) override public {
        _transferFrom(_from, _to, _tokenId);
    }

}