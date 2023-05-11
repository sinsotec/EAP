// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract EAP is Ownable {

    uint256 balance = 0;
    
    enum countries {Venezuela, USA} 
    //Identifier for each foundation;
    uint256 private foundationId = 1;
    uint256 private projectId = 1;


    //Foundations
    struct Foundation {
        uint256 id;
        string name;
        //string description;
        //string email;
        //countries country;
    }

    //Donors
    struct Donor {
        address account;
        uint256 balance;
    }

    //Contribution
    struct Contribution {
        address account;
        uint256 amount; 
    }

    //Projects 
    struct Project {
        uint256 id;
        string name;
        //string description;
        uint256 goal;
        uint256 balance; 
        uint256 remainingAmount;
        //bool published; //balance must be equal to 0. 
        //bool paused; //balance must be greater than 0.
    }

    //Register each foundation with an address and Ids
    mapping(address => Foundation) public foundationsByAccounts;
    mapping(uint256 => address) public foundationsById;

    //Register donors account
    mapping(address => Donor) public DonorsByAccounts;

    //Associate projects to foundations.id.
    mapping(uint256 => Project[]) public projectByFoundations;

    //Asociatte project.id to an array of contributions;
    mapping(uint256 => Contribution[]) public ContributionsByProjects;

    //Verify address is not used when create new foundation;
    modifier addressUsed(address account) {
        require(foundationsByAccounts[account].id <= 0 , "Account assigned");
        _;
    }

    //Verify is foundation is registered before add project.
    modifier foundationExist(address account) {
        require(foundationsByAccounts[account].id > 0 , "Foundation doesn't exist");
        _;
    }

    constructor() payable {}
        
        //add foundation
        
        function addFoundation(
            string memory _name
             ) public 
             addressUsed(msg.sender) {
                Foundation memory newFoundation = Foundation(foundationId, _name);
                foundationsByAccounts[msg.sender] = newFoundation;
                foundationsById[foundationId] = msg.sender;
                foundationId += 1;
        }

        function getFoundationbyAddress(address _account) public view returns(Foundation memory){
            return foundationsByAccounts[_account];
        }

        function getFoundationbyId(uint256 _id) public view returns(Foundation memory){
            return foundationsByAccounts[foundationsById[_id]];
        }

        //Projects
        function addProject(
            string memory _name, uint256 _goal
            ) public 
            foundationExist(msg.sender) {
                Project memory newProject = Project(projectId, _name, _goal, 0, _goal);
                projectId += 1;
                projectByFoundations[foundationsByAccounts[msg.sender].id].push(newProject);
        }
    
        //Create contribution
        function addContribution(uint256 _foundationId, uint256 _projectIndex) public payable{
            Project memory project = projectByFoundations[_foundationId][_projectIndex];
            //require(project.remainingAmount >= msg.value, "Amount is higher than the remaining");
            projectByFoundations[_foundationId][_projectIndex].balance += msg.value;
            projectByFoundations[_foundationId][_projectIndex].remainingAmount = project.remainingAmount - msg.value;
            Contribution memory newContribution = Contribution(msg.sender, msg.value);
            ContributionsByProjects[project.id].push(newContribution);
            balance += msg.value;
            //si remainin i 0 them call tranfer to foundation
            if(projectByFoundations[_foundationId][_projectIndex].remainingAmount == 0) {
                transfer(payable(foundationsById[_foundationId]), project.goal);
            }
        }

        function transfer(address payable to, uint256 amount) internal {
            to.transfer(amount);
        }

}
