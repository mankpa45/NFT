// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol"; 


contract CryptoDevs is ERC721Enumerable, Ownable {
 /**
       * @dev _baseTokenURI for computing {tokenURI}. If set, the resulting URI for each
       * token will be the concatenation of the `baseURI` and the `tokenId`.
       */
      string _baseTokenURI;

     // price of one nft is set to
     uint256 public _price = 0.01 ether;


     //_paused is used to pause the contract in case of an emargency
     bool public _paused;

     //max number of crytodevs
     uint256 public maxTokenIds = 20;

     //total number of tokenIds minted
     uint256 public tokenIds;
    //whitelist contract instance
    IWhitelist Whitelist;
    //track presale start or not
    bool public presaleStarted;

// time stamp for when presale end
    uint256 public presaleEnded;

    modifier onlyWhenNotPaused{
    require(!_paused, "contract currently paused");
       _;

    }

/**
       * @dev ERC721 constructor takes in a `name` and a `symbol` to the token collection.
       * name in our case is `Crypto Devs` and symbol is `CD`.
       * Constructor for Crypto Devs takes in the baseURI to set _baseTokenURI for the collection.
       * It also initializes an instance of whitelist interface*/
    
 constructor (string memory baseURI, address WhitelistContract) ERC721("Crypto Devs", "CD") { 
        _baseTokenURI = baseURI;
          Whitelist = IWhitelist(WhitelistContract);
      }

      function startpresale () public onlyOwner{
        presaleStarted = true;
        // set presale ended as current time +5 mins
        presaleEnded = block.timestamp  + 5 minutes;
    
      }

       function presaleMint() public payable onlyWhenNotPaused {
          require(presaleStarted && block.timestamp < presaleEnded, "Presale is not running");
          require(Whitelist.whiteListedAddresses(msg.sender), "You are not whitelisted");
          require(tokenIds < maxTokenIds, "Exceeded maximum Crypto Devs supply");
          require(msg.value >= _price, "Ether sent is not correct");
          tokenIds += 1;
          _safeMint(msg.sender, tokenIds);
      }


/* @dev mint allows a user to mint 1 NFT per transaction after the presale 
has ended.*/
      function mint() public payable onlyWhenNotPaused {
          require(presaleStarted && block.timestamp >=  presaleEnded, "Presale has not ended yet");
          require(tokenIds < maxTokenIds, "Exceed maximum Crypto Devs supply");
          require(msg.value >= _price, "Ether sent is not correct");
          tokenIds += 1;
          _safeMint(msg.sender, tokenIds);
      }
  

  function _baseURI() internal view virtual override returns (string memory) {
          return _baseTokenURI;
      }

function setPaused(bool Val) public onlyOwner {
    _paused = Val;
}

//to send all ethers in the contract to the owner of the contract
function withdraw() public onlyOwner {
    address _owner = owner ();
    uint256 amount = address (this).balance;
    (bool sent,) = _owner.call{value:amount}("");
    require (sent, "failed to send ether");
}

receive () external payable {}

fallback() external payable  {}

}