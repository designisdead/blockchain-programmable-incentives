pragma solidity ^0.4.23;
/**
 * @title Proxy
 * @dev Gives the possibility to delegate any call to a foreign implementation.
 */
 import '../registry/contract-registry.sol';
 import '../registry/enabled.sol';

contract PeopleProxy is Enabled {
  /**
  * @dev Fallback function allowing to perform a delegatecall to the given implementation.
  * This function will return whatever the implementation call returns
  */

  //MESSAGE SENDER IS THE CONTROLLER AND NOT THE STORAGE CONTRACT DUE TO STORAGE CONTRACT DELEGATING THE CALL THROUGH THE INTERFACE
  function () payable isEnabled("controller") public {
    ContractRegistry contractRegistry = ContractRegistry(CMC);
    address _impl = contractRegistry.getLibrary("people");
    require(_impl != address(0));

    assembly {
      let ptr := mload(0x40)
      calldatacopy(ptr, 0, calldatasize)
      let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
      let size := returndatasize
      returndatacopy(ptr, 0, size)

      switch result
      case 0 { revert(ptr, size) }
      default { return(ptr, size) }
    }
  }
}
