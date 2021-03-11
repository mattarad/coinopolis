pragma solidity ^0.6.6;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract CGI1155 is ERC1155 {

    string public name;
    string public symbol;

    address private minter;
    uint256 public tokenID;

    mapping(uint256 => uint256) public totalSupply;

    mapping(uint256 => string) public tokenURI;

    event Minted(
        uint256 tokenId,
        uint256 supply,
        string tokenUri
    );

    event IncreaseMinted(
        uint256 tokenId,
        uint256 supplyIncrease,
        uint256 newSupply
    );

    event TokenBurn (
        uint256 tokenId,
        uint256 amountBurned,
        uint256 newTotalSupply
    );


    constructor() public ERC1155("https://coinopolisgameitems.herokuapp.com/items/") {
        minter = msg.sender;
        name =  "Coinopolis Game Items v2";
        symbol  = "CGIv2";
        tokenID = 0;
    }

    modifier onlyMinter {
        require(msg.sender == minter);
        _;
    }

    function mint(uint256 _supply, string memory _tokenURI) public onlyMinter {
        require(_supply > 0);
        tokenID++;
        _mint(minter, tokenID, _supply, "");
        totalSupply[tokenID] += _supply;
        tokenURI[tokenID] = _tokenURI;

        emit Minted( tokenID, _supply, _tokenURI );
    }

    function increaseMint(uint256 _tokenID, uint256 _supply) public onlyMinter {
        require(_tokenID >0 && _tokenID <= tokenID, "ERC1155: Invalid tokenID...");
        _mint(minter, _tokenID, _supply, "");
        totalSupply[_tokenID] += _supply;
        uint256 _newSupply = totalSupply[_tokenID];

        emit IncreaseMinted( _tokenID, _supply, _newSupply );
    }

    function updateUri(uint256 _tokenID, string memory _tokenURI) public onlyMinter returns (bool) {
        tokenURI[_tokenID] = _tokenURI;
        return true;
    }

    function tokenUri(uint256 _tokenID) public view returns (string memory) {
        require(_tokenID > 0 && _tokenID <= tokenID, "ERC1155: invalid tokend ID");
        return tokenURI[_tokenID];
    }

    function transfer(address _from, address _to, uint256 _tokenID, uint256 _amount) public {
        bytes memory _data = bytes("safeTransferFrom");
        safeTransferFrom(_from, _to, _tokenID, _amount, _data);
    }

    function batchTransfer(address from, address to, uint256[] memory ids, uint256[] memory amounts) public {
        bytes memory _data = bytes("safeTransferFrom");
        safeBatchTransferFrom( from, to, ids, amounts, _data );
    }

    function burn(uint256 _tokenID, uint256 _amount) public onlyMinter {
        _burn(minter, _tokenID, _amount);
        totalSupply[_tokenID] -= _amount;

        emit TokenBurn ( _tokenID, _amount, totalSupply[_tokenID] );
    }
}