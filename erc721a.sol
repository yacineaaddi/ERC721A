// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/MerkleProof.sol";
/*import "https://github.com/chiru-labs/ERC721A/blob/main/contracts/ERC721A.sol";*/
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
/*import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol";*/
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/common/ERC2981.sol";
import "https://github.com/chiru-labs/ERC721A/blob/main/contracts/extensions/ERC721AQueryable.sol";


contract NFTSol is ERC721AQueryable, ERC2981, Ownable {

    uint256 public Maxsupply = 100;
    uint256 public Maxmintperwallet = 40;
    uint256 public price = 10000000000000 wei;
    uint public wlSalePrice = 10000000000000 wei;
    uint public publicSalePrice = 20000000000000 wei;
    uint256 private constant Reservedtoken = 20;
    uint256 public TotalMinted = 0 ;
    bytes32 private merkleRoot = 0x2381a8aa5d4d4857e7625ba987686151bedcf5b39d8e1350a9df46bef13f2374;
    bool public Issalesactive = false ;  
    bool public WhithlistMint = false ; 
    bool public PublicMint = false; 
    string public Mintstate = "Not started";
    string public BaseURI ;
    string private BaseExtension = ".json";

    mapping (address => uint256) public Mintedperwallet ;

    enum Status {
        Notstartedyet,
        WhitelistSale,
        PublicSale,
        SoldOut
    }
    
    Status public status;

   constructor () ERC721A("TestCollection", "TC-TC"){
        for (uint256 i = 1 ; i <= Reservedtoken ; ++i) {
            _safeMint(payable(msg.sender) , 1  );}
            Mintedperwallet[msg.sender] += Reservedtoken ;
            TotalMinted = Reservedtoken;
           }

/*-------------------------------------------------------------------------------------------------------------MODIFY DATA BY OWNER*/

    function StartWLmint() public onlyOwner{
      status = Status.WhitelistSale;
      Mintstate = "WLActive";
      Issalesactive = true;
      price = wlSalePrice;}

     function StartPBmint() public onlyOwner{
      status = Status.PublicSale;
      Mintstate = "PBActive";
      Issalesactive = true;
      price = publicSalePrice;}

     function setSoldOut() public onlyOwner{
      Mintstate = "SoldOut";
      status = Status.SoldOut;}

     function setStatus(Status _status) public onlyOwner {
        status = _status ;}
  
    function ChangeMerkroot(bytes32 _merkleRoot) public onlyOwner {merkleRoot = _merkleRoot;}

    function ToggleMintStatus() public onlyOwner {
            Issalesactive = !Issalesactive;}


    function Setnftbaseuri(string memory _baseUri) public onlyOwner (){
             BaseURI = _baseUri;
            }

    function setRoyaltyInfo(address _receiver, uint96 _royaltyFeesInBips) public onlyOwner {
            _setDefaultRoyalty(_receiver, _royaltyFeesInBips );}

    function ChangeTotalsupply(uint256 _Newsupply) public onlyOwner {
            Maxsupply = _Newsupply ;}

    function ChangeWLprice(uint256 _NewWLprice) public onlyOwner {
            wlSalePrice = _NewWLprice ;}

    function ChangePBprice(uint256 _NewPBprice) public onlyOwner {
            publicSalePrice = _NewPBprice ;}

/*------------------------------------------------------------------------------------------------------------- WHITLIST MINT*/


    function WhitlistMint(uint256 _NumToken, bytes32[] calldata _proof) public payable {

        
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(status == Status.WhitelistSale, "WL sale is not active");
        require(MerkleProof.verify(_proof, merkleRoot, leaf),"You are not whitlisted");
        require(Issalesactive,"Mint is paused");
        require( _NumToken <= Maxmintperwallet ,"Cannot mint more than 40");
        require( Mintedperwallet[msg.sender] + _NumToken <= Maxmintperwallet ,"Max mint reached");
        uint256 CurrentTotalMinted = TotalMinted ;
        require(CurrentTotalMinted + _NumToken <=  Maxsupply , "Total Mint Reached" );
        require( _NumToken * price >= msg.value , "Insufficient funds");

        for (uint256 i = 1 ; i <= _NumToken  ; ++i){
           _safeMint(payable(msg.sender) , 1 );} 


        Mintedperwallet[msg.sender] += _NumToken ;
        TotalMinted += _NumToken ;  }

/*------------------------------------------------------------------------------------------------------------- PUBLIC MINT*/


        function Publicmint(uint256 _NumToken) public payable {

        require(status == Status.PublicSale, "PB sale is not active");
        require(Issalesactive,"The sales is paused");
        require( _NumToken <= Maxmintperwallet ,"Cannot mint more than 40");
        require( Mintedperwallet[msg.sender] + _NumToken <= Maxmintperwallet ,"Max mint reached");
        uint256 CurrentTotalMinted = TotalMinted ;
        require(CurrentTotalMinted + _NumToken <=  Maxsupply , "Total Mint Reached" );
        require( _NumToken * price >= msg.value , "Insufficient funds");

        for (uint256 i = 1 ; i <= _NumToken  ; ++i){
           _safeMint(payable(msg.sender) , 1 );} 


        Mintedperwallet[msg.sender] += _NumToken ;
        TotalMinted += _NumToken ;}


        function BurnToken(uint256 tokenId) public {
            _burn(tokenId);
        }


/*------------------------------------------------------------------------------------------------------------- WITHDRAW FUNDS BY OWNER*/

        function Withdraw() public onlyOwner {

            uint256 BALANCE = address(this).balance ;
            uint256 BalanceOne = BALANCE * 50 /100 ;
            uint256 BalanceTwo = BALANCE * 50 /100 ;
            (bool TransferOne,) = address(0x328c956838d99bD665505965d001DA813044791a).call{value : BalanceOne}("");
            (bool TransferTwo,) = address(0x328c956838d99bD665505965d001DA813044791a).call{value : BalanceTwo}("");
            require(TransferOne && TransferTwo, "Withdraw Money Failed");}



/*-------------------------------------------------------------------------------------------------------------*/

     function tokensOfOwner(address owner) public view virtual override(ERC721AQueryable) returns (uint256[] memory) {
        uint256 start = _startTokenId();
        uint256 stop = _nextTokenId();
        uint256[] memory tokenIds;
        if (start != stop) tokenIds = _tokensOfOwnerIn(owner, start, stop);
        return tokenIds;
    }

/*-------------------------------------------------------------------------------------------------------------*/

        
            function tokenURI(uint256 tokenId) public view  override(ERC721A,IERC721A) returns (string memory) {
            if (!_exists(tokenId)) _revert(URIQueryForNonexistentToken.selector);

            string memory baseURI = _baseURI();
            return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, _toString(tokenId), BaseExtension)) : "";
            }


            function _baseURI() override internal view returns (string memory) {
            return BaseURI;
            }

            function _startTokenId() internal pure override returns (uint256) {
             return 1 ;
            }


            function CalculateRoyalties(uint256 _salePrice, uint256 royaltyFeesInBips) pure public returns (uint256){
                return (_salePrice  * royaltyFeesInBips) / 100  ;
            }
            
             function supportsInterface(bytes4 interfaceId) public view virtual override(ERC2981, ERC721A,IERC721A) returns (bool) {
             return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
             }

}
