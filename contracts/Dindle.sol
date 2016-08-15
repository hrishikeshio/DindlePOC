contract Dindle{
	address contractOwner = msg.sender;
	mapping(uint => Book) public books;
	mapping(uint => Listing) public listings;
	uint numBooks;
	uint numListings;

	modifier noether { if (msg.value > 0) throw; _ }
	modifier onlyLicensee(uint bookID) { if (books[bookID].licensees[msg.sender] == 0) throw; _ }

	struct Book{
		string bookName;
		string authorName;
		string imageURL;
		string bookURL;
		uint price;
		// mapping (address => uint) owners;
		mapping (address => uint) licensees; //0=dont ownn 1=licensed 2=selling
		address owner;
		address publisher;
		uint numOwners;
		uint numLicensees;
	}

	struct Listing{
		uint256 bookID;
		bool isNew;
		uint256 price;
		address seller;
	}

	function Dindle (uint platformCommission) noether  {
		register("The Adventures of Sherlock Holmes","Aurthur Conan Doyle","http://images.contentreserve.com/ImageType-100/1785-1/%7B24168643-5E3F-497D-A948-8BEC7B3D80CC%7DImg100.jpg","http://87.106.111.132/epub/sherlock.epub",1,0x0);
		register("Alice in Wonderland","Lewis Carroll","https://www.panmacmillan.com/panmacmillancorporatesite/media/panmacmillan/Cover%20Images/Lewis-Carroll/9781447279990Alice-s%20Adventures%20in%20Wonderland.jpg?ext=jpg","http://87.106.111.132/epub/alice.epub",3,0x0);
		list(1);
	}

	function register (
		string bookName,
		string authorName,
		string imageURL,
		string bookURL,
		uint price,
		address publisher
		) noether public returns (uint bookID)
	{	bookID=numBooks;
		numBooks++;
		address owner = msg.sender;
		books[bookID]=Book(bookName,authorName, imageURL, bookURL, 
			price, owner, publisher,0,0);
		uint listingID=numListings;
		numListings++;
		listings[listingID]=Listing(bookID, true, price,msg.sender );
		Book b = books[bookID];
		// 		uint stake=100.0;
		// if (publisher!=0x0)
		// {
		// 	b.owners[msg.sender]=100;
		// 	b.numOwners=1;
		// }
		// else
		// {
		// 	b.owners[msg.sender]=80;
		// 	b.owners[publisher]=20;
		// 	b.numOwners=2;
		// }
		b.licensees[msg.sender]=2;
		b.numLicensees=1;
	}

	function buy(uint listingID)
	{
		Listing l = listings[listingID];
		Book b = books[l.bookID];
		b.licensees[msg.sender]=1;
		if (b.publisher!=0x0)
		{
			b.publisher.send(msg.value/5);
			b.owner.send(msg.value/2);
		}
		//b.licensees[serial]=Licensee(licenseeAddress_);
	}

	function buyUsed(uint listingID)
	{
		Listing l = listings[listingID];
		Book b = books[l.bookID];
		b.licensees[msg.sender]=1;
		delete listings[listingID];
		//b.licensees[serial]=Licensee(licenseeAddress_);
		{
			b.publisher.send(msg.value/5);
			b.owner.send(msg.value/2);
			l.seller.send(msg.value/5);
		}
	}

	function list(uint bookID) onlyLicensee(bookID)
	{
		books[bookID].licensees[msg.sender]=2;
		listings[numListings++]=Listing(bookID,false,books[bookID].price,msg.sender);

	}
	function verifyLicense(uint bookID) constant public returns (uint license)
	{
		license=books[bookID].licensees[msg.sender];
	}
	function verifyOwnership(uint bookID) constant public returns (uint ownership)
	{
		if(books[bookID].owner==msg.sender) {
			ownership=1;
			} else {
			ownership=0;
			}
		// ownership=books[bookID].owners[msg.sender];
	}
	function getNumberOfBooks() constant public returns(uint256)
	{
		return numBooks;
	}
	function getNumberOfListings() constant public returns(uint256)
	{
		return numListings;
	}
	//"a","a","a","a",1,1,1
	function getBook(uint bookID) constant public returns
	(string bookName,
		string authorName,
		string imageURL,
		string bookURL,
		uint256 price,
		uint256 numOwners,
		uint256 numLicensees,
		address owner,
		address publisher)
	{
		Book book=books[bookID];
		bookName=book.bookName;
		authorName=book.authorName;
		imageURL=book.imageURL;
		bookURL=book.bookURL;
		price=book.price;
		numOwners=book.numOwners;
		numLicensees=book.numLicensees;
		owner=book.owner;
		publisher=book.publisher;
	}
	function getListing(uint listingID) constant public returns
	(uint bookID,
		bool isNew,
		uint price,
		address seller,
		string bookName,
		string authorName,
		string imageURL,
		string bookURL,
		uint256 numOwners,
		uint256 numLicensees
)
	{	Listing l = listings[listingID];
		bookID=l.bookID;
		isNew=l.isNew;
		price=l.price;
		seller=l.seller;
		Book book=books[bookID];
		bookName=book.bookName;
		authorName=book.authorName;
		imageURL=book.imageURL;
		bookURL=book.bookURL;
		price=book.price;
		numOwners=book.numOwners;
		numLicensees=book.numLicensees;
	}
}
