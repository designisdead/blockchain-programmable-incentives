pragma solidity ^0.4.23;

interface ContractProvider {
    function contracts(bytes32 _name) external view returns (address);
}


contract Enabled {
    address public CMC;

    modifier isEnabled(bytes32 _name) {
        require(msg.sender == ContractProvider(CMC).contracts(_name));
        _;
    }

    function setCMCAddress(address _CMC) external {
        if (CMC != 0x0 && msg.sender != CMC) {
            revert();
        } else {
            CMC = _CMC;
        }
    }

    function changeCMCAddress(address _newCMC) external {
      require(CMC == msg.sender);
      CMC = _newCMC;
    }

    function kill() external {
        assert(msg.sender == CMC);
        selfdestruct(CMC);
    }
}
