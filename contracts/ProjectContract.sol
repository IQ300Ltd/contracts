pragma solidity ^0.4.17;

contract Token {
    function balanceOf(address _owner) public view returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() {
        owner = msg.sender;
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }

}

contract ProjectContract is Ownable {
    address public tokenAddr;
    uint public  projectId;
    uint public  authorId;
    Token public  token;

    event TaskPaid(address beneficiary, uint amount, uint userId, uint taskId);

    function ProjectContract(address _token, uint _projectId, uint _authorId) {
        tokenAddr = _token;
        projectId = _projectId;
        authorId = _authorId;
        token = Token(_token);
    }

    function projectBalance() public view returns (uint) {
        return token.balanceOf(this);
    }

    function payForTask(address beneficiary, uint amount, uint userId, uint taskId) public onlyOwner returns (bool) {
         if(token.transfer(beneficiary, amount)) {
             TaskPaid(beneficiary, amount, userId, taskId);
             return true;
         } else {
             return false;
         }
    }
}
