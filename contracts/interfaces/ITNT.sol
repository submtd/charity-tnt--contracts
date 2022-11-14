// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ITNT {
    function addMinter ( address minter_, uint256 max_ ) external;
    function addressBook (  ) external view returns ( address );
    function allowance ( address owner, address spender ) external view returns ( uint256 );
    function approve ( address spender, uint256 amount ) external returns ( bool );
    function balanceOf ( address account ) external view returns ( uint256 );
    function buy ( uint256 amount_ ) external;
    function canAddNewMinters (  ) external view returns ( bool );
    function decimals (  ) external view returns ( uint8 );
    function decreaseAllowance ( address spender, uint256 subtractedValue ) external returns ( bool );
    function disableAddingNewMinters (  ) external;
    function disableMinting (  ) external;
    function increaseAllowance ( address spender, uint256 addedValue ) external returns ( bool );
    function initialize (  ) external;
    function mint ( address to_, uint256 amount_ ) external returns ( bool );
    function minters ( address ) external view returns ( uint256 );
    function mintingEnabled (  ) external view returns ( bool );
    function name (  ) external view returns ( string memory );
    function owner (  ) external view returns ( address );
    function pause (  ) external;
    function paused (  ) external view returns ( bool );
    function proxiableUUID (  ) external view returns ( bytes32 );
    function renounceOwnership (  ) external;
    function setAddressBook ( address address_ ) external;
    function symbol (  ) external view returns ( string memory );
    function totalSupply (  ) external view returns ( uint256 );
    function transfer ( address to, uint256 amount ) external returns ( bool );
    function transferFrom ( address from, address to, uint256 amount ) external returns ( bool );
    function transferOwnership ( address newOwner ) external;
    function unpause (  ) external;
    function upgradeTo ( address newImplementation ) external;
    function upgradeToAndCall ( address newImplementation, bytes memory data ) external;
}
