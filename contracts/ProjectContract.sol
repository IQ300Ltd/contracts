pragma solidity ^0.4.17;

contract Token {
    function balanceOf(address _owner) public view returns (uint);
    function transfer(address _to, uint _value) public returns (bool);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint a, uint b) internal pure returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }
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
    using SafeMath for uint;
    
    address public tokenAddr;
    address public payerAddr;

    uint public  projectId;
    uint public  authorId;
    uint public  deadlineAwardPercent;
    uint public  deadlinePenaltyPercent;
    uint public  obligationsAmount;
    uint public  paidAmount;

    uint constant deadlinePenaltyPeriod = 60 * 60 * 24; // 1 day

    Token public  token;

    struct TaskObligation {
        uint taskId;
        uint amount;
        uint createdAt;
        uint deadlineTimestamp;
    }

    mapping (uint => TaskObligation) public obligations;
    mapping (uint => address) public paidTasks;

    event TaskPaid(address beneficiary, uint amount, uint userId, uint taskId);

    function ProjectContract(
        address _token,
        address _payer,
        uint _projectId,
        uint _authorId,
        uint _deadlineAwardPercent,
        uint _deadlinePenaltyPercent
    ) {
        tokenAddr = _token;
        payerAddr = _payer;
        projectId = _projectId;
        authorId = _authorId;
        deadlineAwardPercent = _deadlineAwardPercent;
        deadlinePenaltyPercent = _deadlinePenaltyPercent;
        token = Token(_token);
    }

    function registerObligation(uint taskId, uint deadlineTimestamp, uint amount) public onlyOwner returns (bool) {
        require(obligations[taskId].createdAt == 0);
        obligations[taskId] = TaskObligation({
            amount: amount,
            taskId: taskId,
            deadlineTimestamp: deadlineTimestamp,
            createdAt: now
        });
        obligationsAmount = obligationsAmount.add(amount);
        return true;
    }

    function projectBalance() public view returns (uint) {
        return token.balanceOf(this);
    }

    function refund() public onlyOwner returns (bool) {
        var amount = projectBalance();
        if(amount > 0) {
            return token.transfer(payerAddr, amount);
        }
        return false;
    }

    function payForTask(address beneficiary, uint userId, uint taskId) public onlyOwner returns (bool) {
        var obligation = obligations[taskId];
        require(obligation.createdAt != 0);
        require(paidTasks[taskId] == 0);

        var amount = obligationReward(obligation.amount, obligation.deadlineTimestamp);

        if(token.transfer(beneficiary, amount)) {
            paidTasks[taskId] = beneficiary;
            obligationsAmount = obligationsAmount.sub(obligation.amount);
            paidAmount = paidAmount.add(amount);
            TaskPaid(beneficiary, amount, userId, taskId);
            return true;
         } else {
            return false;
         }
    }

    function obligationReward(uint amount, uint deadlineTimestamp) private view returns (uint) {
        if(now < deadlineTimestamp) {
            var award = amount.div(100).mul(deadlineAwardPercent);
            return amount.add(award);
        }
        if(now > deadlineTimestamp.add(deadlinePenaltyPeriod)) {
            var penalty = amount.div(100).mul(deadlinePenaltyPercent);
            return amount.sub(penalty);
        }
        return amount;
    }
}
