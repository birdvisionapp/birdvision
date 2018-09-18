@smoke
Feature: Smoke Flow
#TO run smoke pointing to local use following command
#ENVIRONMENT=localhost:3000 be cucumber -p smoke SMOKE_ADMIN=admin SMOKE_ADMIN_PASSWORD=password
#CLIENT_MANAGER=bvc.client_manager CLIENT_MANAGER_PASSWORD=password BROWSER=firefox
  @javascript
  Scenario: User should be able to checkout after adding an item to a cart and check the order status in my orders
    When I login as "bvcuser" for client "bvc-point-based"
    And I view scheme "bvc points scheme"
    And I add "bvc-item" to a cart with price "2000"
    Then I should be able to redeem order for "bvc-item"
    And I should see the following orders in my orders
      | Product Description | Quantity | Status          |
      | bvc-item            | 1        | Order Confirmed |
    And I logout

    When I login as operations manager into the admin app
    Then I should be able to view "bvc-item" order for "bvcuser" in admin dashboard
    Then I change the status of order for "bvc-item" to "Send for delivery"
    And I logout
    When I login as "bvcuser" for client "bvc-point-based"
    Then I should see the following orders in my orders
      | Product Description | Quantity | Status  |
      | bvc-item            | 1        | Shipped |
    And I logout

    When I login as smoke reseller into the admin app
    Then I should be able to view the "bvc-item" order for "bvc user" in reseller dashboard for "bvc-point-based"
    And I logout

    When I login as smoke client manager into the admin app
    Then I should be able to see the following schemes
      | scheme_name     |
      | bvc-point-based |

    And I should see the following participants for "bvc-point-based"
      | participant             |
      | bvc-point-based.bvcuser |

    And I should see the following client items in "bvc-point-based" client catalog
      | name     | client_price |
      | bvc-item | 1,000         |

    And I should see the following client items in scheme catalog of "bvc points scheme" of "bvc-point-based"
      | name     | client_price |
      | bvc-item | 1,000         |

    And I logout


  @javascript
  Scenario: User should be able to search for an item and filter by points in the result set
    When I login as "bvcuser" for client "bvc-point-based"
    And I view scheme "bvc points scheme"
    Then I should be able to search for "bvc-item"
    And I should see the search results in the left navigation for "bvc-sub-category"

  @javascript
  Scenario: User should be able to browser through catalog for a particular scheme
    When I login as "bvcuser" for client "bvc-club-based"
    And I view scheme "bvc club scheme"
    And I view "Platinum" club catalog
    Then I should be able to redeem

  @javascript
  Scenario: User should be able to search for an item
    When I login as "bvcuser" for client "bvc-club-based"
    And I view scheme "bvc club scheme"
    Then I should be able to search for "bvc-item"
