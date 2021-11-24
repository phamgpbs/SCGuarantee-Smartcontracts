// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.3.2 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}


// @title IERC1643 Document Management (part of the ERC1400 Security Token Standards)
/// @dev See https://github.com/SecurityTokenStandard/EIP-Spec

interface IERC1643 {

    // Document Management
    //-- Included in interface but commented because getDocuement() & getAllDocuments() body is provided in the STGetter
    function getDocument(bytes32 _name) external view returns (string memory, bytes32, uint256);
    function getAllDocuments() external view returns (bytes32[] memory);
    function setDocument(bytes32 _name, string calldata _uri, bytes32 _documentHash) external;
    function removeDocument(bytes32 _name) external;

    // Document Events
    event DocumentRemoved(bytes32 indexed _name, string _uri, bytes32 _documentHash);
    event DocumentUpdated(bytes32 indexed _name, string _uri, bytes32 _documentHash);

}


///	@title	Multiownership for a contract
///	@author Philippe Meyer Gazprombank Switzerland
///	@notice	This contract is heavily inspired from the openzepplin Owner contract. It implements a basic
///			multi ownership with two owners.
/// @dev	It offers the same features as the Owner contract extended to two owners defined in the constructor
///		
contract MultiOwner {

    address private owner1;
    address private owner2;

	/// @dev 	This event must be fired when one of the two owners is changed
	/// @param	oldOwner is the address of the previous owner
	/// @param	newOwner is the address of the new owner
	
    event OwnerSet(address indexed oldOwner, address indexed newOwner);


   /// @dev 	Modifier to check if caller is one of the owners. Uses the msg.sender to identify the sender

    modifier isOwner() {
        require(msg.sender == owner1 || msg.sender == owner2, "Caller is not owner");
        _;
    }
    


	/// @dev	Constructor
	/// @param	_owner1: address of the new owner

    constructor(address _owner1, address _owner2) {
        if (owner1 == address(0)) {
            owner1 = _owner1; // 'msg.sender' is sender of current call, contract deployer for a constructor
            emit OwnerSet(address(0), owner1);
        }
        if (owner2 == address(0)) {
            owner2 = _owner2; // 'msg.sender' is sender of current call, contract deployer for a constructor
            emit OwnerSet(address(0), owner2);
        }
    }

	/// @dev	Change one of the owners. This method is restricted to the owners. It changes the sender
	///			into the new owner. It keeps silent if this is called by an address not having ownership.
	/// @param	newOwner address of the new owner

    function changeOwner(address newOwner) public isOwner {
        if (msg.sender == owner1) {
            emit OwnerSet(owner1, newOwner);
            owner1 = newOwner;
        }
        else {
            emit OwnerSet(owner2, newOwner);
            owner2 = newOwner;
        }
    }

    /**
     * @dev Return owner address
     * @return address of owner
     */

    function getOwners() public view returns (address, address) {
        return (owner1, owner2);
    }
}


contract SCRInfo {
    
        struct SCRParam {
        address         requester;              // Address of the operator requesting the creation of that Stable Coin reference
        IERC20Metadata  contractAddr;           // Address of the smart contract implementing the stable coin
        string          clientId;               // Client information: in our case the ACP reference of the pledged account
        bool            isStoredTx;             // Boolean to specify whether the transactions are stored or only issued as events
        string          url;                    // Url of the stable coin (produced by the issuer and containing the commercials and white paper)
    }
}

interface IStableCoinReference {

	/// @dev	Structure defining a transaction
	/// 		transactionId : unique transaction identifier coming from the core banking system
	///			customer: hash (kecakk256) of the customer's IBAN
	///			amount: amount of the deposit (translated into an integer)
    
	struct transaction {
        uint    transactionId;
        uint    customer;
        int256  amount;
    }
 
 
	/// @dev 	This event must be fired when the balance of the guarantee is updated
	/// @param	_contract is the address of the stablecoin for which the guarantee has been updated
	/// @param	_balance new guarantee of the stablecoin expressed as an integer (using the decimals defined in the sc)
	/// @param 	_currency string containing the symbol of the stablecoin for which the guarantee has changed
	
    event BalanceUpdated(IERC20Metadata indexed _contract, uint256 _balance, string _currency);
    
	
	/// @dev	This event must be fired when a new transaction has been uploaded (when an investor deposits fiat)
	/// @param	_transactionId contains the core banking identifier of the deposit
	/// @param 	_customer IBAN hashed (kecakk256 of the customer's IBAN)
	
	event Deposit(uint256 indexed _transactionId, uint256 _customer, int256 _deposit);
    
	
	/// @dev	This event must be fired when the stablecoin enters in redemption mode and a redemption address
	///			has been defined.
	///	@param	_redemptionWallet is the address of the redemption wallets where the coins will be moved
	
	event newRedemptionWallet(address indexed _redemptionWallet);


	/// @dev	returns the stablecoin's currency which the symbol of the stable coin
	/// @return	a string containing the stablecoin's currency
	
    function getCurrency() external view returns(string memory);
    

	/// @dev	returns the stablecoin's decimals (copied from the stablecoin during the initialization)
	/// @return	a uint containing the stablecoin's decimals
	
    function getDecimals() external view returns(uint);
    
	
	/// @dev	returns the stablecoin's name (copied from the stablecoin during the initialization)
	/// @return	a string containing the stablecoin's name

    function getName() external view returns(string memory);
	
	
	/// @dev	returns the stablecoin's address
	/// @return	the address of the stablecoin

    function getStableCoinAddress() view external returns(IERC20Metadata);


    /// @dev    returns the Url of the stable coin description
	/// @return	the url of the stablecoin description

    function getStableCoinUrl() view external returns(string memory);


	/// @dev	returns in one call all the stablecoin's characteristics
	/// @return	SCAddress: the address of the stablecoin
	/// @return currency: a string containing the stablecoin's currency
	/// @return name: a string containing the stablecoin's name
	/// @return decimals: a uint containing the stablecoin's decimals
	/// @return url: a string containing the url of the stablecoin description/white paper
    
    function getStableCoin() view external returns(IERC20Metadata, string memory, string memory, uint, string memory);
    

	/// @dev 	returns if the stablecoin is in redeöption mode
	/// @return a boolean true : redemption mode, false : normal operation
	
    function isRedemption() external view returns(bool);
	
	
	/// @dev 	returns the redemption address to which the coins should be transfered to process the claims
	/// @return	the address of the redemption wallet
    
    function getRedemptionWallet() external view returns(address);
	
	
	/// @dev	sets the stablecoin into redemption mode. This means that no update is then possible on the 
	///			guarantee nor on the transactions. This function is restricted to the owners and requires a
	///			multi-signature. This function triggers a newRedemptionWallet event.
	///	@param	_redemptionWallet: the address of the redemption wallet

    function setRedemptionWallet(address _redemptionWallet) external;
	
	
	///	@dev	updates the guarantee providing the new value of the balance and creating a new document.
	///			This feature is restricted to the owners. It triggers two events: BalanceUpdated and DocumentUpdated
	/// @param	_balance: unsigned integer containing the new value of the guarantee
	/// @param	_name: bytes32 containing the name of the document (see ERC-1643)
	/// @param	_uri: string containing the IFPS file name (see ERC-1643)
	/// @param	_documentHash: unisigned integer containing the SHA256 hash of the document (see ERC-1643)
	    
    function updateGuarantee(uint _balance, bytes32 _name, string calldata _uri, bytes32 _documentHash) external;
    
	
	/// @dev	get the value for the guarantee
	/// @return balance: an integer containing the value of the currency (to be divided by 10^decimals)
	/// @return currency: a string containing the currency (which is a copy of the symbol's stablecoin)
	
    function getBalance() external view returns(uint, string memory);
    
    
	/// @dev 	sets whether this contract is active or not. This feature is restricted to the owners
	/// @param	_isActive: boolean specifying if the stablecoin is active
	
	function setActive(bool _isActive) external;
	
	
	/// @dev	returns the activity status of the stablecoin
	/// @return a boolean. true = active
    
    function isActive() external view returns(bool);
    
	
	/// @dev	defines whether the contract stores the transactions or not (in any case transactions will trigger an event)
	///			This feature is restricted to the owners
	///	@param	_isStoredTx: boolean which specifies whether the transactions should be stored
	
    function setStoreTx(bool _isStoredTx) external;
	
	
	/// @dev	returns whether the transactions are stored in the contract
	/// @return	a boolean true = transactions are stored
	
    function isStoredTx() external view returns(bool);
    
	
	/// @dev	defines the address of the transactions operator. This role is able to delete transactions is the contract
	///			This feature is restricted to the owners and the current transaction operator. When the contract is 
	///			initialized, the transaction operator is set dy default to the stablecoin address
	/// @param	_txOperator: the address of the new transaction operator
	
	function setTxOperator(address _txOperator) external;
    
    
	/// @dev	publshes and optionnally stores the deposits processed by the core banking system. This feature is
	///			restricted to the owners and in any case fires a Deposit event for each transaction.
	///			Each time a transaction is processed, the id and the time are stored. It is assumed that the transactions
	///			should be ordered by transactionId
	/// @param	_txs: an array of transactions
	
	function publishTransactions(transaction[] memory _txs) external;
    
	
	/// @dev	removes the specified transaction from the contract. This is intended to be used in a smart contract
	///			which would perform the transfer of the stable coins to the investor and the removal of that transaction
	///			record in one ethereum transaction guarantying the atomicity and the consistency.
	///			This feature is available on for the transaction operator
	/// @param	txid: unique identifier of the core banking transaction
	
    function removeTransaction(uint txid) external;
	
	
	/// @dev	retrieves all the transactions stored in the contract.
	/// @return	an array of transactions

    function getAllTransactions() external view returns(transaction[] memory);
    
	
	/// @dev	stores a client data associated to the contract. This is used to store the reference to the account
	///			in the core banking system. This function is overwriting the default value that should be provided
	///			to the constructor. This feature is limited to the owners
	/// @param	_clientId: a string containing the client information
	
    function setClientId(string memory _clientId) external;


	///	@dev	gets the client data associated to the stablesoin.
	/// @return	a string containing the client information
	
    function getClientId() external view returns(string memory);


	/// @dev	gets information regarding the last recorded (or published) transaction
	/// @return	lastTxId: id of the last published transaction
	/// @return	lastTxTime: epoch of the last published transaction
	
    function getLastTransaction() external view returns(uint256, uint256);
}


/**
 * @title SCReferenceList
 * @dev List all the deployed StableCoinReference Smart contracts
 */

contract SCReferenceList is MultiOwner, SCRInfo{

    StableCoinReference[]   listSCR;
    mapping (IERC20Metadata => SCRParam) pendingRequests;
    SCRParam[] pendingRequestsList;

    constructor(address _owner2) MultiOwner(msg.sender, _owner2) {}

    
    function addStableCoinReference(IERC20Metadata _contract, string memory _clientId, bool _isStoredTx, string memory _url) external isOwner {
        for (uint i = 0 ; i < listSCR.length ; i++) {
            require(listSCR[i].getStableCoinAddress() != _contract, "SCReferenceList: this stable coin is already registered");
        }
        
        address otherOwner;
        address owner1;
        address owner2;
        (owner1, owner2) = getOwners();
        msg.sender == owner1 ? otherOwner = owner2 : otherOwner = owner1;
        
        if (pendingRequests[_contract].requester == otherOwner) {
            StableCoinReference scr = new StableCoinReference(pendingRequests[_contract], owner1, owner2);
            listSCR.push(scr);
            delete pendingRequests[_contract];
            for (uint i = 0 ; i < pendingRequestsList.length ; i++) {
                if (pendingRequestsList[i].contractAddr == _contract) {
                    uint l = pendingRequestsList.length;
                    if (l > 1 && i != l-1) pendingRequestsList[i] = pendingRequestsList[l -1];
                    pendingRequestsList.pop();
                    break;
                }
            }
        }
        else {
            SCRParam memory p = SCRParam(msg.sender, _contract, _clientId, _isStoredTx, _url);
            pendingRequests[_contract] = p;
            pendingRequestsList.push(p);
        }
    }
    
    function getPendingRequests() external view returns(SCRParam[] memory) {
        return pendingRequestsList;
    }
    
    function getPendingRequest(IERC20Metadata _contract) external view returns(SCRParam memory) {
        return pendingRequests[_contract];
    }
    
    function getStableCoinReference() external view returns(StableCoinReference[] memory) {
        return listSCR;
    }
}


contract StableCoinReference is MultiOwner, IERC1643, SCRInfo, IStableCoinReference {

    struct document {
        string  uri;
        bytes32 hash;
        uint256 time;
    }
    
    IERC20Metadata  SCAddress;
    uint            balance;
    uint            balanceTime;
    int             balanceVariation;
    string          currency;
    string          name;
    string          url;
    uint            decimals;
    address         redemptionWallet;
    string          clientId;
    uint256         lastTxId;
    uint256         lastTxTime;
    bool            isActiveSC;
    bool            isRedemptionSC;
    bool            isStoredTxSC;
    transaction[]   txsMap;
    address         txOperator;
    
    bytes32[] docNames;
    mapping(bytes32 => document)  docs;
    mapping(address => address) pendingRequests;

    constructor(SCRParam memory _params, address _owner1, address _owner2) MultiOwner(_owner1, _owner2) {
        SCAddress = _params.contractAddr;
        decimals = SCAddress.decimals();
        currency = SCAddress.symbol();
        name = SCAddress.name();
        isActiveSC = true;
        isRedemptionSC = false;
        isStoredTxSC = _params.isStoredTx;
        clientId = _params.clientId;
        url = _params.url;
        txOperator = address(SCAddress);
    }
    
    modifier isNotRedemption() {
        require(!isRedemptionSC, "GPBS StableCoinReference: this coin is under liquidation");
        _;
    }
    modifier isLive() {
        require(isActiveSC, "GPBS StableCoinReference: this coin is not active");
        _;
    }
    

    
    function getCurrency() external view override returns(string memory) {
        return currency;
    }
    
    function getDecimals() external view override returns(uint) {
        return decimals;    
    }
    
    function getName() external view override returns(string memory) {
        return name;
    }
    
    function getStableCoinUrl() external view override returns(string memory) {
        return url;
    }
    
    function getStableCoinAddress() view public override returns(IERC20Metadata) {
        return SCAddress;
    }
    
    function getStableCoin() view public override returns(IERC20Metadata, string memory, string memory, uint, string memory) {
        return(SCAddress, currency, name, decimals, url);
    }
    
    function isRedemption() external view override returns(bool) {
        return isRedemptionSC;
    }
    
    function getRedemptionWallet() external view override returns(address) {
        return redemptionWallet;
    }
    
    function setRedemptionWallet(address _redemptionWallet) external override  isOwner isNotRedemption isLive {
        address otherOwner;
        address owner1;
        address owner2;
        (owner1, owner2) = this.getOwners();
        msg.sender == owner1 ? otherOwner = owner2 : otherOwner = owner1;
        
        if (pendingRequests[_redemptionWallet] == otherOwner) {
            redemptionWallet = _redemptionWallet;
            delete pendingRequests[_redemptionWallet];
            isRedemptionSC = true;
            
            emit newRedemptionWallet(redemptionWallet);
        }
        else {
            redemptionWallet = address(0);
            pendingRequests[_redemptionWallet] == msg.sender;
        }
    }

    function setBalance(uint _balance) public isOwner isNotRedemption isLive {
        balanceVariation = (int)(_balance) - (int)(balance);
        balance = _balance;
        balanceTime = block.timestamp;

        emit BalanceUpdated(SCAddress, balance, currency);
    }
    
    function updateGuarantee(uint _balance, bytes32 _name, string calldata _uri, bytes32 _documentHash) external override isOwner isNotRedemption isLive {
        setBalance(_balance);
        setDocument( _name, _uri, _documentHash);
    }
    
    function getBalance() external view override returns(uint, string memory) {
        return(balance, currency);
    }
    
    function setActive(bool _isActive) external override isOwner isLive {
        isActiveSC = _isActive;
    }
    
    function isActive() external view override returns(bool) {
        return(isActiveSC);
    }
    
    function setStoreTx(bool _isStoredTx) external override isOwner isLive isNotRedemption {
        isStoredTxSC = _isStoredTx;
    }
    
    function setTxOperator(address _txOperator) external override isLive isNotRedemption {
        address owner1;
        address owner2;
        (owner1, owner2) = getOwners();
        require((msg.sender == owner1) || (msg.sender == owner2) || (msg.sender == txOperator), "GPBS StableCoinReference: accessible to owners or txOperator");
        
        txOperator = _txOperator;
    }
    
    function isStoredTx() external view override returns(bool) {
        return(isStoredTxSC);
    }
    
    function publishTransactions(transaction[] memory _txs) external override isOwner isLive isNotRedemption {
        for (uint i = 0 ; i < _txs.length ; i++) {
            if (isStoredTxSC) txsMap.push(_txs[i]);
            emit Deposit(_txs[i].transactionId, _txs[i].customer, _txs[i].amount);
        }
        uint256 l;
        l = _txs.length;
        lastTxId = _txs[l -1].transactionId;
        lastTxTime = block.timestamp;
    }
    
    function removeTransaction(uint txid) external override isLive isNotRedemption {
        uint i;
        
        require(msg.sender == txOperator, "GPBS StableCoinReference: accessible only to txOperator");
        for (i = 0 ; i < txsMap.length ; i ++) {
            if (txsMap[i].transactionId == txid) break;
        }
        require(i < txsMap.length, "GPBS StableCoinReference: cannot delete a non existing transaction");
        txsMap[i] = txsMap[txsMap.length -1];
        txsMap.pop();
    }

    function getAllTransactions() external view override returns(transaction[] memory) {
        return txsMap;
    }
    
    function setClientId(string memory _clientId) external override isOwner isLive isNotRedemption {
        clientId = _clientId;
    }
    
    function getClientId() external view override returns(string memory) {
        return(clientId);
    }
    
    function getLastTransaction() external view override returns(uint256, uint256) {
        return(lastTxId, lastTxTime);
    }

    function getAllDocuments() external view override returns (bytes32[] memory) {
        return docNames;
    }
    
    function getDocument(bytes32 _name) external view override returns (string memory, bytes32, uint256) {
        require(docs[_name].hash > 0, "GPBS StableCoinReference: Non existing document");
        
        return(docs[_name].uri, docs[_name].hash, docs[_name].time);
    }
    
    function setDocument(bytes32 _name, string calldata _uri, bytes32 _documentHash) public override isOwner isLive {
        if(docs[_name].hash == 0)           // This entry does not exist in the mapping
            docNames.push(_name);
        
        docs[_name].uri = _uri;
        docs[_name].hash = _documentHash;
        docs[_name].time = block.timestamp;

        emit DocumentUpdated(_name, _uri, _documentHash);
    }
    
    function removeDocument(bytes32 _name) external override isOwner isLive {
        require(docs[_name].hash > 0, "GPBS StableCoinReference: cannot delete a non existing document");
        
        string memory uri = docs[_name].uri;
        bytes32 hash = docs[_name].hash;
        
        uint index;
        
        for(index = 0; index < docNames.length; index++) {
            if (docNames[index] == _name) break;
        }
        require(index < docNames.length, "GPBS StableCoinReference: non existing document");
        docNames[index] = docNames[docNames.length-1];
        docNames.pop();

        emit DocumentRemoved(_name, uri, hash);
    }
}