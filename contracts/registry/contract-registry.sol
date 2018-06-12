pragma solidity ^0.4.23;

import '../util/Ownable.sol';
import './enabled.sol';

contract ContractRegistry is Ownable {
  mapping (bytes32 => address) public contracts;
  mapping(bytes32 => address) public libraries;

  function addLibrary(bytes32 _name, address _lib) external onlyOwner {
    require(libraries[_name] == address(0), "LIBRARY_ALREADY_EXISTS");
    require(_lib != address(0), "INSERT_VALID_LIBRARY_ADDRESS");
    libraries[_name] = _lib;
  }

  function replaceLibrary(bytes32 _name, address _newLib) external onlyOwner {
    require(libraries[_name] != address(0), "LIBRARY_DOESNT_EXIST");
    libraries[_name] = _newLib;
  }

  function getLibrary(bytes32 _name) external view returns (address) {
    return libraries[_name];
  }

  function addContract(bytes32 _name, address _address) onlyOwner external {
    Enabled _Enabled = Enabled(_address);
    _Enabled.setCMCAddress(address(this));
    contracts[_name] = _address;
  }

  function getContract(bytes32 _name) external view returns (address) {
    return contracts[_name];
  }

  function removeContract(bytes32 _name) external onlyOwner returns (bool) {
    require(contracts[_name] != address(0));
    Enabled _Enabled = Enabled(contracts[_name]);
    _Enabled.kill();
    contracts[_name] = 0x0;
  }

  function changeContractCMC(bytes32 _name, address _newCMC) external onlyOwner {
    Enabled _Enabled = Enabled(contracts[_name]);
    _Enabled.changeCMCAddress(_newCMC);
  }

  function kill() external onlyOwner {
    selfdestruct(owner);
  }
}
