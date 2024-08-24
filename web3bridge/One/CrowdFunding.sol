// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    /*
    The Campaign struct holds the essential details for each crowdfunding initiative,
    including the campaign title, description, the benefactor's address, fundraising goal,
    deadline, and the total amount raised.
    */
    struct Campaign {
        string title;
        string description;
        address payable benefactor;
        uint goal;
        uint deadline;
        uint amountRaised;
    }

    // The campaigns array contains all the campaigns created through this contract.
    Campaign[] public campaigns;

    /* Events such as CampaignCreated, DonationReceived, and CampaignEnded are emitted
    to track significant contract activities. These events can be observed by external
    applications or users for monitoring purposes.
    */
    event CampaignCreated(uint campaignID, string title, string description, address benefactor, uint goal, uint deadline);
    event DonationReceived(uint campaignID, address donor, uint amount);
    event CampaignEnded(uint campaignID, address benefactor, uint amountRaised);

    /*
    Function: createCampaign
    This function allows any user to initiate a new crowdfunding campaign.
    The user must provide a title, description, benefactor address, goal, and duration.
    The deadline is determined by adding the provided duration to the current time.
    The new campaign is appended to the campaigns array, and an event is emitted to
    log the campaign's creation.
    */
    function createCampaign(string memory _title, string memory _description, address payable _benefactor, uint _goal, uint _duration) public {
        require(_goal > 0, "Goal must be greater than zero");

        uint deadline = block.timestamp + _duration;
        campaigns.push(Campaign({
            title: _title,
            description: _description,
            benefactor: _benefactor,
            goal: _goal,
            deadline: deadline,
            amountRaised: 0
        }));

        emit CampaignCreated(campaigns.length - 1, _title, _description, _benefactor, _goal, deadline);
    }

    /*
    Function: donateToCampaign
    This function enables users to donate to a specific campaign by providing the campaign ID.
    Before accepting the donation, the function verifies that the campaign's deadline has not
    passed. The donation amount is then added to the campaign's total amount raised, and an
    event is emitted to log the donation.
    */
    function donateToCampaign(uint _campaignID) public payable {
        Campaign storage campaign = campaigns[_campaignID];
        require(block.timestamp < campaign.deadline, "The campaign has ended");

        campaign.amountRaised += msg.value;
        emit DonationReceived(_campaignID, msg.sender, msg.value);
    }

    /*
    Function: endCampaign
    This function allows the campaign to be concluded once its deadline has passed.
    The total amount raised is transferred to the benefactor, and an event is emitted
    to log the campaign's conclusion. This function ensures that no further donations
    can be made after the campaign has ended.
    */
    function endCampaign(uint _campaignID) public {
        Campaign storage campaign = campaigns[_campaignID];
        require(block.timestamp >= campaign.deadline, "The campaign is still ongoing");

        campaign.benefactor.transfer(campaign.amountRaised);
        emit CampaignEnded(_campaignID, campaign.benefactor, campaign.amountRaised);
    }
}
