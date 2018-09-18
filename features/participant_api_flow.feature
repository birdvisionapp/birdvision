Feature: Participant API flow

  Scenario: Registration should be success with valid participant information
    When I send a POST request to "/api/participants/registration" with valid headers and with:
      """
      {"participant_id": "test1", "full_name": "Test Name", "email": "test@testing.com", "mobile_number": "9876543210", "landline_number": "123456", "address": "testing", "pincode": "560067", "notes": "test notes"}
      """
    And I send and accept JSON
    Then the response should be "200"
    Then I should receive the following JSON response:
      """
      {"title":"ok","status_code":0,"status_message":"The participant has successfully registered"}
      """

  Scenario: Registration should fail with invalid client_id and client_secret headers
    When I send a POST request to "/api/participants/registration" with:
    """
    """
    And I send and accept JSON
    Then the response should be "200"
    Then I should receive the following JSON response:
      """
      {"title":"errors","status_code":1,"status_message":"Invalid client id or client secret"}
      """

  Scenario: Registration should return exception if valid client_id and, client_secret and empty json body
    When I send a POST request to "/api/participants/registration" with valid headers and with:
    """
    """
    And I send and accept JSON
    Then the response should be "200"
    Then I should receive the following JSON response:
      """
      {"title":"exception","status_code":2,"status_message":"795: unexpected token at ''"}
      """

  Scenario: Registration should check unacceptable parameters in the json body
    When I send a POST request to "/api/participants/registration" with valid headers and with:
      """
      {"participant_id": "test1", "username": "", "full_name": "Test Name", "email": "test@testing", "mobile_number": "987654321"}
      """
    And I send and accept JSON
    Then the response should be "200"
    Then I should receive the following JSON response:
      """
      {"title":"errors","status_code":1,"status_message":"The following parameters only can be acceptable in the JSON body to REGISTER the Participant. Acceptable parameters: participant_id, full_name, email, mobile_number, landline_number, address, pincode, and notes. Unacceptable parameters: username"}
      """

  Scenario: Registration return validation errors for invalid participant information
    When I send a POST request to "/api/participants/registration" with valid headers and with:
      """
      {"participant_id": "", "full_name": "Test Name", "email": "test@testing", "mobile_number": "987654321"}
      """
    And I send and accept JSON
    Then the response should be "200"
    Then I should receive the following JSON response:
      """
      {"title":"errors","status_code":1,"status_message":["Please enter the participant id","Email format should be valid e.g email@domain.com","Mobile number is the wrong length (should be 10 characters)"]}
      """

  Scenario: Get rewards information
    When I send a GET request to "/api/participants/rewards" with valid participant_id and status "active"
    And I send and accept JSON
    Then the response should be "200"
    Then I should receive the following JSON response:
      """
      {"points":{"total":"2,000","redeemed":"300","remaining":"1,700"},"achievements":[{"scheme_name":"BBD test","total":"20,000"}]}
      """

  Scenario: Get rewards information if participant id not match
    When I send a GET request to "/api/participants/rewards" with invalid participant_id
    And I send and accept JSON
    Then the response should be "200"
    Then I should receive the following JSON response:
      """
      {"title":"errors","status_code":1,"status_message":"Could not find BVC user account with ParticipantID: testuser1"}
      """

  Scenario: Get rewards information if participant is in inactive state
    When I send a GET request to "/api/participants/rewards" with valid participant_id and status "inactive"
    And I send and accept JSON
    Then the response should be "200"
    Then I should receive the following JSON response:
      """
      {"title":"errors","status_code":1,"status_message":"The participant is in INACTIVE status"}
      """

  Scenario: Update Participant information with valid information
    When I send a POST request to "/api/participants/update_info" with valid participant_id and status "active"
    """
    {"full_name":"Update Testname","email":"updated@testing.com","mobile_number":"8876543210"}
    """
    And I send and accept JSON
    Then the response should be "200"
    Then I should receive the following JSON response:
      """
      {"title":"ok","status_code":0,"status_message":"The participant has successfully updated"}
      """

  Scenario: Update participant information with given invalid client_id and client_secret headers
    When I send a POST request to "/api/participants/update_info" with:
    """
    """
    And I send and accept JSON
    Then the response should be "200"
    Then I should receive the following JSON response:
      """
      {"title":"errors","status_code":1,"status_message":"Invalid client id or client secret"}
      """

  Scenario: Update participant information with given invalid participant_id header
    When I send a POST request to "/api/participants/update_info" with invalid participant_id
    And I send and accept JSON
    Then the response should be "200"
    Then I should receive the following JSON response:
      """
      {"title":"errors","status_code":1,"status_message":"Could not find BVC user account with ParticipantID: testuser1"}
      """

  Scenario: Update Participant information with participant inactive state
    When I send a POST request to "/api/participants/update_info" with valid participant_id and status "inactive"
    """
    """
    And I send and accept JSON
    Then the response should be "200"
    Then I should receive the following JSON response:
      """
      {"title":"errors","status_code":1,"status_message":"The participant is in INACTIVE status"}
      """

  Scenario: Update Participant information with invalid information
    When I send a POST request to "/api/participants/update_info" with valid participant_id and status "active"
    """
    {"full_name":"","email":"test@testing","mobile_number":"1234"}
    """
    And I send and accept JSON
    Then the response should be "200"
    Then I should receive the following JSON response:
      """
      {"title":"errors","status_code":1,"status_message":["Full name can't be blank","Email format should be valid e.g email@domain.com","Mobile number is the wrong length (should be 10 characters)"]}
      """
  Scenario: De-Activate Participant
    When I send a POST request to "/api/participants/de_activate" with valid participant_id and status "active"
    """
    """
    And I send and accept JSON
    Then the response should be "200"
    Then I should receive the following JSON response:
      """
      {"title":"ok","status_code":0,"status_message":"The participant has successfully De-Activated"}
      """

  Scenario: De-Activate Participant with participant inactive state
    When I send a POST request to "/api/participants/de_activate" with valid participant_id and status "inactive"
    """
    """
    And I send and accept JSON
    Then the response should be "200"
    Then I should receive the following JSON response:
      """
      {"title":"errors","status_code":1,"status_message":"The participant is in INACTIVE status"}
      """