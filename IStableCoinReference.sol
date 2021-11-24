// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './IERC20Metadata.sol';


interface IStableCoinReference {

	/// @dev	Structure defining a transaction
	/// 		transactionId : unique transaction identifier coming from the core banking system
	///		customer: hash (kecakk256) of the customer's IBAN
	///		amount: amount of the deposit (translated into an integer)
    
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
	/// @param	_redemptionWallet is the address of the redemption wallets where the coins will be moved
	
	event newRedemptionWallet(address indexed _redemptionWallet);


	/// @dev	returns the version of the interface of this smartcontract
	/// @return	a string containing the smartcontract version
	
    	function getVersion() external view returns(string memory);
    
    
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
	/// @param	_redemptionWallet: the address of the redemption wallet

    	function setRedemptionWallet(address _redemptionWallet) external;
	
	
	/// @dev	updates the guarantee providing the new value of the balance and creating a new document.
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
	/// @param	_isStoredTx: boolean which specifies whether the transactions should be stored
	
    	function setStoreTx(bool _isStoredTx) external;
	
	
	/// @dev	returns whether the transactions are stored in the contract
	/// @return	a boolean true = transactions are stored
	
	function isStoredTx() external view returns(bool);
   

	/// @dev	returns the txOperator for this stablecoin
	/// @return	the address of the txOperator who has the right to store and remove transactions

	function getTxOperator() external view returns(address);
		

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
	///			This feature is available only for the transaction operator for the deposits (amounts > 0) and for the bank 
	///			operators (owners) for withdrawls (amounts < 0)
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


	/// @dev	gets the client data associated to the stablesoin.
	/// @return	a string containing the client information
	
    	function getClientId() external view returns(string memory);


	/// @dev	gets information regarding the last recorded (or published) transaction
	/// @return	lastTxId: id of the last published transaction
	/// @return	lastTxTime: epoch of the last published transaction
	
    	function getLastTransaction() external view returns(uint256, uint256);
}
