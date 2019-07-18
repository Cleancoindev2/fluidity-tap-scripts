pragma solidity 0.5.10;

import "./ERC20Detailed.sol";

/**
  * @notice Represents value that will be stored in a MCD
  * @dev inherits IERC20, ERC20 and MinterRole
  * @dev inherits ERC20Detailed, ERC20Burnable, ERC20Mintable
  * @dev deployer is the owner to start
  */
contract ColDetailed is ERC20Detailed {

    /**
    * @notice The constructor for the ColTea.
    * @param _name name of the token (per ERC20Detailed)
    * @param _symbol symbol of the token (per ERC20Detailed)
    * @param _decimals decimals of the token (per ERC20Detailed)
    */
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    )
    public
    ERC20Detailed(_name, _symbol, _decimals) {
    }
}