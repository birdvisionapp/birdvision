Feature: Authentication API flow - Single Sign On

  Scenario: Authorize client with given invalid client_id
    When I send a GET request to "/auth/bvc/authorize" with "invalid" client_id and with "invalid" redirect_uri
    Then the response should be "200"
    Then I should receive the following JSON response:
      """
      {"title":"errors","status_code":1,"status_message":"Invalid client id"}
      """

  Scenario: Authorize client with given valid client_id and without redirect_uri
    When I send a GET request to "/auth/bvc/authorize" with "valid" client_id and with "invalid" redirect_uri
    Then the response should be "200"
    Then I should receive the following JSON response:
      """
      {"title":"errors","status_code":1,"status_message":"Please present the redirect uri / callback url"}
      """

  Scenario: Authorize client with given valid client_id and redirect_uri
    When I send a GET request to "/auth/bvc/authorize" with "valid" client_id and with "valid" redirect_uri
    Then the response should be "200"
    Then I should receive the following JSON response:
      """
      {"title":"errors","status_code":1,"status_message":"Please present the ParticipantID in scope"}
      """

  Scenario: Authorize client and access_grant with invalid participant_id
    When I send a GET request to "/auth/bvc/authorize" with "invalid" participant_id
    Then the response should be "200"
    Then I should receive the following JSON response:
      """
      {"title":"errors","status_code":1,"status_message":"Could not find BVC user account with ParticipantID: t1"}
      """

  Scenario: Authorize client and access_grant with inactive participant
    When I send a GET request to "/auth/bvc/authorize" with "inactive" participant_id
    Then the response should be "200"
    Then I should receive the following JSON response:
      """
      {"title":"errors","status_code":1,"status_message":"The participant is in INACTIVE status"}
      """

  Scenario: Authorize client and access_grant with valid participant_id
    When I send a GET request to "/auth/bvc/authorize" with "valid" participant_id
    Then the response should be "302"
    Then I should be redirect to "www.test.domain.com/callback" page

  Scenario: AccessToken authenticate with given invalid client_id and client_secret
    When I send a GET request to "/auth/bvc/access_token" with "invalid" client_id and client_secret
    Then the response should be "200"
    Then I should receive the following JSON response:
      """
      {"title":"errors","status_code":1,"status_message":"Invalid client id or client secret"}
      """

  Scenario: AccessToken authenticate with given valid client_id and client_secret
    When I send a GET request to "/auth/bvc/access_token" with "valid" client_id and client_secret
    Then the response should be "200"
    Then I should receive the following JSON response:
      """
      {"title":"errors","status_code":1,"status_message":"Could not authenticate access code"}
      """

