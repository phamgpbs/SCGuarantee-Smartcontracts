// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import './IERC20Metadata.sol';

contract SCRInfo {
    
        struct SCRParam {
        address         requester;              // Address of the operator requesting the creation of that Stable Coin reference
        IERC20Metadata  contractAddr;           // Address of the smart contract implementing the stable coin
        string          clientId;               // Client information: in our case the ACP reference of the pledged account
        bool            isStoredTx;             // Boolean to specify whether the transactions are stored or only issued as events
        string          url;                    // Url of the stable coin (produced by the issuer and containing the commercials and white paper)
    }
}
