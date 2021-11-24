// SPDX-License-Identifier: GPL-3.0
 
pragma solidity >=0.7.0 <0.9.0;

import './SCRInfo.sol';
import './MultiOwner.sol';
import './StableCoinReference.sol';

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
            require(!((listSCR[i].getStableCoinAddress() == _contract) && (listSCR[i].isActive())), "SCReferenceList: this stable coin is already registered");
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
    
    function getPendingRequests() external view returns(SCRParam[] memory)  {
        return pendingRequestsList;
    }
    
    function getPendingRequest(IERC20Metadata _contract) external view returns(SCRParam memory)  {
        return pendingRequests[_contract];
    }
    
    function getStableCoinReference() external view returns(StableCoinReference[] memory) {
        return listSCR;
    }
    
    function registerStableCoinReference(StableCoinReference _scReference) external isOwner {
        listSCR.push(_scReference);
    }
}
