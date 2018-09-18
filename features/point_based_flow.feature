Feature: Point based flow

  Background: create item from scratch and redeem it.
    Given I login as operations manager into the admin app

    And I create the following suppliers
      | name                 | address                   | phone number | geographic reach | delivery time | payment terms |
      | bvc-Chroma Pune      | Yerwada, Pune MH 411006   | 02012345678  | Pan India        | 1-2 days      | 10 days       |
      | bvc-Reliance Digital | Chicnhwad, Pune MH 411051 | 02012345678  | Pan India        | 3-4 days      | 12 days       |
      | bvc-FlipKart         | Latur, Pune MH 411051     | 02013345678  | Pan India        | 2-3 days      | 20 days       |

    And I create the following categories
      | index | title            | parent       |
      | 1     | bvc-category     |              |
      | 2     | bvc-Furniture    |              |
      | 3     | bvc-Apparel      |              |
      | 4     | bvc-sub-category | bvc-category |
      | 5     | bvc-Mobile       | bvc-category |

    And I add the following clients
      | client_name | code     | points_to_rupee_ratio | client_contact_name                   | email                      | phone_number | description               |
      | bvc-Acme    | bvc-Acme | 10                    | contact name of client representative | bvc.emrsn@mailinator.com   | 1234567890   | description of the client |
      | bvc-Axis    | bvc-axis | 1                     | contact name of client representative | bvc.axs@mailinator.com.com | 1234567890   | description of the client |

    And I create the following client managers
      | name               | client   | email                             | mobile_number |
      | bvc-client-manager | bvc-Acme | bvc_client_manager@mailinator.com | 1234567890    |

    And I create the following resellers
      | name         | email                       | phone_number |
      | bvc-Reseller | bvc_reseller@mailinator.com | 1234567890   |

    And I assign "bvc-Reseller" to "bvc-Acme" with "1000" finders fee and following slabs
      | slab | limit | percentage |
      | 1    | 1000  | 10         |
      | 2    | 5000  | 20         |
      | 3    | 10000 | 50         |

    And I create the following schemes
      | client   | name                 | total_budget_INR | start_date | end_date   | redemption_start_date | redemption_end_date | image_path                              | level_names          | club_names           |
      | bvc-Acme | bvc-Big Bang Dhamaka | 100000           | 01-01-2012 | 01-10-2012 | 27-12-2012            | 27-12-2100          | /features/fixtures/big_bang_dhamaka.png | level1               | platinum,gold,silver |
      | bvc-Acme | bvc-Past Scheme      | 1000             | 01-01-2008 | 01-10-2009 | 27-12-2010            | 27-12-2011          | /features/fixtures/big_bang_dhamaka.png | level1,level2,level3 | platinum,gold,silver |

  @javascript

  Scenario:Uploaded Draft Item should be published and shown in point-based participants catalog
    When I upload draft items from "draft_items" file for supplier "bvc-FlipKart"
    And I publish the draft item with title "bvc-Galaxy" with category "bvc-category/bvc-sub-category"
    And I publish the draft item with title "bvc-Red Sofa" with category "bvc-category/bvc-sub-category"
    And I add base price "25000" for item "bvc-Galaxy"
    And I add base price "25000" for item "bvc-Red Sofa"
    And I add following items to "bvc-Acme" client catalog
      | item_name    | client_price |
      | bvc-Galaxy   | 50000        |
      | bvc-Red Sofa | 76000        |
    And I add following items to "bvc-Big Bang Dhamaka" scheme catalog for "bvc-Acme"
      | item_name    |
      | bvc-Galaxy   |
      | bvc-Red Sofa |
    And I associate following items with "level1-platinum" catalog for "bvc-Big Bang Dhamaka" of "bvc-Acme"
      | item_name    | client_price |
      | bvc-Galaxy   | 50000        |
      | bvc-Red Sofa | 76000        |

    And I add participants for the scheme "bvc-Big Bang Dhamaka" of "bvc-Acme"
    And I activate participant "bvc-acme.bvcuser" account
    And I inactive participant "bvc-acme.bvcuser" account
    And I active participant "bvc-acme.bvcuser" account
    And I logout

    When participant follows "activation link" link in inbox of "bvcuser@mailinator.com" with subject as "bvc-Acme Rewards Program - Account Activation Details"
    And participant activates account and logs out

    When I login as "bvcuser" for client "bvc-Acme"
    And I view scheme "bvc-Big Bang Dhamaka"
    Then The following items should be shown on catalog
      | item_name    | price  |
      | bvc-Galaxy   | 500000 |
      | bvc-Red Sofa | 760000 |
    And Only applicable categories should be shown on catalog page
      | index | title        | parent           |
      | 1     | bvc-category |                  |
      | 2     | bvc-category | bvc-sub-category |
    When I add "bvc-Galaxy" to a cart with price "500000"
    Then I should be able to redeem order for "bvc-Galaxy"
    And I should see the following orders in my orders
      | Product Description | Quantity | Status          |
      | bvc-Galaxy          | 1        | Order Confirmed |
    And I logout

    When I login as fulfilment manager into the admin app
    And I remove "bvc-Galaxy" from client catalog of "bvc-Acme"
    And I change the status of order for "bvc-Galaxy" to "Send for delivery"
    And I logout

    When reseller follows "here" link in inbox of "bvc_reseller@mailinator.com" with subject as "Reseller - Account Activation Details"
    And I activate my admin account and log out

    When client manager follows "here" link in inbox of "bvc_client_manager@mailinator.com" with subject as "Client Manager - Account Activation Details"
    And I activate my admin account and log out

    And I login as reseller "bvc-Reseller" into the admin app
    Then I should see the following orders for "bvc-Acme" and scheme "bvc-Big Bang Dhamaka"
      | item       | Quantity | Status | Price  |
      | bvc-Galaxy | 1        | new    | 500000 |
    And I should see the following participants for "bvc-Acme" and scheme "bvc-Big Bang Dhamaka"
      | participant | points_redeemed |
      | bvcuser     | 500000          |

    When I login as "bvcuser" for client "bvc-Acme"
    And I view scheme "bvc-Big Bang Dhamaka"
    And The item "bvc-Galaxy" with price "500000" should not be shown in catalog page
    Then The following items should be shown on catalog
      | item_name    | price  |
      | bvc-Red Sofa | 760000 |
    And I should see the following orders in my orders
      | Product Description | Quantity | Status  |
      | bvc-Galaxy          | 1        | Shipped |
    And I logout

    When I login as client manager "bvc-client-manager" into the admin app
    Then I should see following infographics on the dashboard
      | active_schemes                  | active_schemes_budget_total | activated_user_count | order_count |
      | 1 Ready For Redemption Upcoming | 6,00,000                    | 1                    | 1           |
    Then I should see the client "bvc-Acme"
    Then I should be able to see the following schemes
      | scheme_name          |
      | bvc-Big Bang Dhamaka |
      | bvc-Past Scheme      |
    And I should see the following participants for "bvc-Acme"
      | participant      |
      | bvc-acme.bvcuser |
    And I should see the following client items in "bvc-Acme" client catalog
      | name         | client_price |
      | bvc-Red Sofa | 76,000       |
    And I should see the following client items in scheme catalog of "bvc-Big Bang Dhamaka" of "bvc-Acme"
      | name         | client_price |
      | bvc-Red Sofa | 76,000       |
