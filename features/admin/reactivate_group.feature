Feature: Reactivate Group

  As a Loomio admin
  So that I can meet the requests of users who ask to have their group reactivated
  I want to be able to reactivate archived groups from the admin panel

  Scenario: Loomio admin reactivates group
    Given there is a user in an archived group
    When their group is reactivated
    And they sign-in
    Then they should be able to view their group page
    And any subgroups should be reactivated
    And their membership archived_at attribute should be nil
