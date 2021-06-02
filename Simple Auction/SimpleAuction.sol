pragma solidity >=0.7.0 <0.9.9;

contract SimpleAuction{
    // Parameters of the SimpleAuction
    address payable public beneficiary;
    uint public auctionEndTime;
    
    // Current state of the auctionEndTime
    address public highestBidder;
    uint public highestBid;
    
    mapping(address => uint) public pendingReturns;
    
    bool ended = false;
    
    event HighestBidIncrease(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);
    
    constructor(uint _biddingTime, address payable _beneficiary){
        beneficiary = _beneficiary;
        auctionEndTime = block.timestamp + _biddingTime;
    }
    

    modifier aucitonTimeOk {
        require(block.timestamp < auctionEndTime, "The auction has already ended");
        _;
    }
    
    modifier aucitonTimeEnd {
        require(block.timestamp > auctionEndTime, "The auction has not ended");
        _;
    }
    
    modifier higherBid {
        require(msg.value > highestBid, "There is already a higher or equial bid");
        _;
    }

    
    function bid() public payable aucitonTimeOk higherBid{
        
        if (highestBid != 0){
            pendingReturns[highestBidder] += highestBid;
        }
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncrease(msg.sender, msg.value);
        
    }
    
    function withdraw() public returns(bool){
        uint amount = pendingReturns[msg.sender];
        if(amount > 0){
            pendingReturns[msg.sender] = 0;
            
            if(!payable(msg.sender).send(amount)){
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }
    
    function auctionEnd() public aucitonTimeEnd {
        if(ended){
            revert("The function AuctionEnd has already been called");
        }
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);
        
        beneficiary.transfer(highestBid);
    }
}