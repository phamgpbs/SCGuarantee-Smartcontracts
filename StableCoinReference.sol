// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title StableCoinReference
 * @dev Publish Stable Coin Balance and Account Statement
 */
 
import "./MultiOwner.sol";
import "./IERC1643.sol";
import "./IStableCoinReference.sol";
import "./SCRInfo.sol";

contract StableCoinReference is MultiOwner, IERC1643, SCRInfo, IStableCoinReference {

    struct document {
        string  uri;
        bytes32 hash;
        uint256 time;
    }
    
    string          version = "1.0",
    
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
    

    
    function getVersion() external view override returns(string memory) {
        return version;
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
