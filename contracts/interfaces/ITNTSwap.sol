// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ITNTSwap {
    function addressBook (  ) external view returns ( address );
    function buy ( address payment_, uint256 amount_ ) external;
    function buyOutput ( address payment_, uint256 amount_ ) external view returns ( uint256 );
    function factory (  ) external view returns ( address );
    function tnt (  ) external view returns ( address );
    function initialize (  ) external;
    function owner (  ) external view returns ( address );
    function pair (  ) external view returns ( address );
    function pause (  ) external;
    function paused (  ) external view returns ( bool );
    function proxiableUUID (  ) external view returns ( bytes32 );
    function renounceOwnership (  ) external;
    function router (  ) external view returns ( address );
    function sell ( uint256 amount_ ) external;
    function sellOutput ( uint256 amount_ ) external view returns ( uint256 );
    function setAddressBook ( address address_ ) external;
    function setup (  ) external;
    function tax (  ) external view returns ( uint256 );
    function taxHandler (  ) external view returns ( address );
    function transferOwnership ( address newOwner ) external;
    function unpause (  ) external;
    function upgradeTo ( address newImplementation ) external;
    function upgradeToAndCall ( address newImplementation, bytes memory data ) external;
    function usdc (  ) external view returns ( address );
}
