// SPDX-License-Identifier: GPL-3.0

 
pragma solidity >=0.7.0 <0.9.0;



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
