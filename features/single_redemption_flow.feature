Feature: Single redemption flow

  Background: Set up user and item data.
    Given I login as operations manager into the admin app
    And I create the following suppliers
      | name                 | address                   | phone number | geographic reach | delivery time | payment terms |
      | bvc-Chroma Pune      | Yerwada, Pune MH 411006   | 02012345678  | Pan India        | 1-2 days      | 10 days       |
      | bvc-Reliance Digital | Chicnhwad, Pune MH 411051 | 02012345678  | Pan India        | 3-4 days      | 12 days       |
      | bvc-FlipKart         | Latur, Pune MH 411051     | 02013345678  | Pan India        | 2-3 days      | 20 days       |
    And I create the following categories
      | index | title           | parent          |
      | 1     | bvc-Electronics |                 |
      | 2     | bvc-Furniture   |                 |
      | 3     | bvc-Apparel     |                 |
      | 4     | bvc-Sofa        | bvc-Furniture   |
      | 5     | bvc-Mobile      | bvc-Electronics |
    And I add the following clients
      | client_name | code     | points_to_rupee_ratio | client_contact_name                   | email                      | phone_number | description               |
      | bvc-Acme    | bvc-Acme | 1                     | contact name of client representative | bvc.axs@mailinator.com.com | 1234567890   | description of the client |
    And I create the following schemes
      | client   | name                   | total_budget_INR | start_date | end_date   | redemption_start_date | redemption_end_date | image_path                              | single_redemption | level_names          | club_names           |
      | bvc-Acme | bvc-Acme First Scheme  | 100000           | 01-01-2012 | 01-10-2012 | 27-12-2012            | 27-12-2100          | /features/fixtures/big_bang_dhamaka.png | true              | level1,level2,level3 | platinum,gold,silver |

  @javascript
  Scenario:Uploaded Items should be published and shown in single-redemption participants catalog
    When I upload draft items from "draft_items" file for supplier "bvc-FlipKart"
    And I publish the draft item with title "bvc-Galaxy" with category "bvc-Electronics/bvc-Mobile"
    And I publish the draft item with title "bvc-Red Sofa" with category "bvc-Furniture/bvc-Sofa"
    And I add base price "25000" for item "bvc-Galaxy"
    And I add base price "25000" for item "bvc-Red Sofa"
    And I add following items to "bvc-Acme" client catalog
      | item_name             | client_price |
      | bvc-Galaxy | 50000        |
      | bvc-Red Sofa          | 76000        |
    And I associate following items with "level1-platinum" catalog for "bvc-Acme First Scheme" of "bvc-Acme"
      | item_name             | client_price |
      | bvc-Galaxy | 50000        |
      | bvc-Red Sofa          | 76000        |
    And I add participants for the scheme "bvc-Acme First Scheme" of "bvc-Acme"
    And I activate participant "bvc-acme.bvcuser" account
    And I inactive participant "bvc-acme.bvcuser" account
    And I active participant "bvc-acme.bvcuser" account
    And I logout

    When participant follow "activation link" link in inbox of "bvcuser@mailinator.com" with subject as "bvc-Acme Rewards Program - Account Activation Details"
    And participant activates account and logs out
    And participant follow "Sign In" link in inbox of "bvcuser@mailinator.com" with subject as "bvc-Acme Rewards Program - Account Details"

    When I login as "bvcuser" for client "bvc-Acme"
    And I view scheme "bvc-Acme First Scheme"
    Then "bvc-Galaxy" should be shown on catalog without price
    And I redeem "bvc-Galaxy"
    Then I should see the following orders in my orders
      | Product Description   | Status          |
      | bvc-Galaxy | Order Confirmed |
    And I logout

    When I login as fulfilment manager into the admin app
    Then I should be able to view "bvc-Galaxy" order for "bvc-acme.bvcuser" in admin dashboard
    Then I change the status of order for "bvc-Galaxy" to "Send for delivery"
    And I logout

    When I login as "bvcuser" for client "bvc-Acme"
    And I should see the following orders in my orders
      | Product Description   | Status  |
      | bvc-Galaxy | Shipped |
    And "bvcuser@mailinator.com" opens the email with subject "bvc-Acme Rewards Program - Shipment of Item in Order"
    Then I should see "bvc-Galaxy" in the email body
