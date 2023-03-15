// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/**
 * A DAO making contract, for proposals, and contributions, and voting.
 * collects money from investors and allocates shares.
 * Keep track of contributions and shares.
 * Allow investors transfer shares.
 * Allow investment proposals to be created and voted.
 * Execute successful investment proposals.
 */

contract DAO {

    struct Proposal{
        uint id;
        uint amount;
        uint votes;
        uint end;
        string name;
        address payable recipient;
        bytes data;
        bool executed;
    }

    mapping(address => bool) public isInvestor; // keep track of investors
    mapping(address => uint) public shares; // keep track of shares
    mapping(address => mapping(uint => bool)) public votes; // keep track of individual votes
    mapping(uint => Proposal) public proposals; // maps proposals
    uint public totalShares; // total shares of members
    uint public availableFunds; // address(this).balance of contract
    uint public contributionEnd; // time for ending contributions
    uint public nextProposalId; // id for proposals
    uint public voteTime; // deadline for vote on proposal to end
    uint public minVotes; // minimal number of votes required
    address public admin;
    address [] public investors;

    modifier onlyInvestors() {
        require(isInvestor[msg.sender] = true, "error: Not investor");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "error: nnot admin");
        _;
    }

    constructor(
        uint contributionTime,
        uint _voteTime,
        uint _minVotes) {
        require(_minVotes > 0 && minVotes < 200, "minVotes should be between 0 and 200");
        contributionEnd = block.timestamp + contributionTime;
        voteTime = _voteTime;
        minVotes = _minVotes;
        admin = msg.sender;
    }

    // for eth returns of successful proposal investments
    receive() external payable {
        availableFunds += msg.value;
    }

    function contribute(address investor) payable external {
        require(block.timestamp < contributionEnd, "error: contribution over");
        investors.push(investor);
        isInvestor[msg.sender] = true; // make contributor an investor
        shares[msg.sender] += msg.value; // increase shares of investor
        totalShares += msg.value; // increase totalShares
        availableFunds += msg.value; // increase available funds
    }

    // use function to extend contribution time
    function extendContributionTime(uint _newContributionTime) public onlyAdmin {
        contributionEnd = block.timestamp + _newContributionTime;
    }

    function redeemShare(uint amount) external onlyInvestors {
        require(shares[msg.sender] >= amount, "error: not enough shares");
        require(availableFunds >= amount, "error: not enough available funds");
        shares[msg.sender] -= amount;
        availableFunds -= amount;
        payable(msg.sender).transfer(amount);
    }

    function transferShare(uint amount, address to) external onlyInvestors {
        require(shares[msg.sender] >= amount, "error: insufficient shares");
        shares[msg.sender] -= amount;
        shares[to] += amount;
        isInvestor[to] = true;
    }

    function createProposal(
        string memory name,
        uint amount,
        address payable recipient,
        bytes calldata data
    ) public onlyInvestors {
        require(availableFunds >= amount, "error: insufficient funds");
        proposals[nextProposalId] = Proposal(
            nextProposalId,
            amount,
            0,
            block.timestamp + voteTime,
            name,
            recipient,
            data,
            false
        );
        availableFunds -= amount;
        nextProposalId++;
    }

    function voteOnProposal(uint proposalId) external onlyInvestors {
        Proposal storage proposal = proposals[proposalId];
        require(votes[msg.sender][proposalId] == false, "error: investor can only vote once");
        require(block.timestamp < proposal.end, "error: proposal already ended");
        votes[msg.sender][proposalId] = true;
        proposal.votes += shares[msg.sender];
    }

    function executePropsal(uint proposalId) external onlyAdmin {
        Proposal storage proposal = proposals[proposalId];
        require(block.timestamp >= proposal.end, "error: cannot execute before end of proposal");
        require(!proposal.executed, "error: proposal already executed");
        require((proposal.votes / totalShares) * 200 >= minVotes, "error: cannot execute proposal with votes below minVotes");
        // transfer funds using call for check effects
        (bool success, ) = proposal.recipient.call{value: proposal.amount}(proposal.data);
        require(success, "error: tx failed");
    }

    function transferFunds(address payable to, bytes memory data, uint amount) external onlyAdmin {
        require(amount <= availableFunds, "error: insufficient funds");
        availableFunds -= amount;
        (bool success, ) = to.call{value: amount}(data);
        require(success, "error: tx failed");
    }
    
    // transfer using to
    function transferEther(uint amount, address payable to) external onlyAdmin {
        to.transfer(amount);
    }

    // Getter functions
    function getInvestors() public view returns(address [] memory) {
        return investors;
    }

    function getTotalAvailableFunds() public view returns (uint256) {
        return address(this).balance;
    }

    function getShares(address investor) public view returns(uint256) {
        return shares[investor];
    }

}