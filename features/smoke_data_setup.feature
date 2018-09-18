@smoke_data
Feature: smoke data setup flow
#this code is not completely idempotent and will fail creation of reseller, client manager, uploading draft items,
#uploading users will pollute the users and unnecessarily increase number of users if already present hence only run the code that is safe
#activate the account of reseller client manager manually
#TO run smoke pointing to local use following command
#ENVIRONMENT=localhost:3000 be cucumber -p smoke_data

  Background: create item from scratch and redeem it.
    Given I login as operations manager into the admin app

    And I create the following suppliers
      | name         | address | phone number | geographic reach | delivery time | payment terms |
      | bvc-supplier | Delhi   | 01112345678  | Pan India        | 2-3 days      | 10 days       |

    And I create the following categories
      | index | title            | parent       |
      | 1     | bvc-category     |              |
      | 2     | bvc-sub-category | bvc-category |

    And I add the following clients
      | client_name     | code            | points_to_rupee_ratio | client_contact_name                   | email                          | phone_number | description               |
      | bvc-point-based | bvc-point-based | 2                     | contact name of client representative | bvc-point-based@mailinator.com | 1234567890   | description of the client |
      | bvc-club-based  | bvc-club-based  | 1                     | contact name of client representative | bvc-club-based@mailinator.com  | 1234567890   | description of the client |

  # name is not unique be careful
    And I create the following resellers
      | name         | email                    | phone_number |
      | BVC reseller | bvc.smoke@mailinator.com | 9403012352   |

    And I assign "BVC reseller" to "bvc-point-based" with "1234" finders fee and following slabs
      | slab | limit | percentage |
      | 1    | 50    | 10         |
      | 2    | 500   | 20         |
      | 3    | 5000  | 50         |

    And I create the following schemes
      | client          | name              | total_budget_INR | start_date | end_date   | redemption_start_date | redemption_end_date | image_path                              | single_redemption | level_names          | club_names           |
      | bvc-point-based | bvc points scheme | 100000           | 01-01-2012 | 01-10-2013 | 21-01-2013            | 1-1-2015            | /features/fixtures/big_bang_dhamaka.png | false             | level1               | platinum             |
      | bvc-club-based  | bvc club scheme   | 1000             | 01-01-2012 | 01-01-2013 | 21-01-2013            | 01-01-2015          | /features/fixtures/big_bang_dhamaka.png | true              | level1,level2,level3 | platinum,gold,silver |
    And I create the following client managers
      | name               | client          | email                             | mobile_number |
      | bvc-client-manager | bvc-point-based | bvc_client_manager@mailinator.com | 1234567890    |

  @javascript
  Scenario:Uploaded Draft Item should be published and shown in point-based participants catalog
    When I upload draft items from "smoke_draft_items" file for supplier "bvc-supplier"
    And I publish the draft item with title "bvc-item" with category "bvc-category/bvc-sub-category"
    And I add base price "950" for item "bvc-item"
    And I add following items to "bvc-point-based" client catalog
      | item_name | client_price |
      | bvc-item  | 1000         |
    And I add following items to "bvc points scheme" scheme catalog for "bvc-point-based"
      | item_name |
      | bvc-item  |
    And I add following items to "bvc-club-based" client catalog
      | item_name | client_price |
      | bvc-item  | 1000         |
    And I add following items to "bvc club scheme" scheme catalog for "bvc-club-based"
      | item_name |
      | bvc-item  |
    And I associate following items with "level1-platinum" catalog for "bvc club scheme" of "bvc-club-based"
      | item_name | client_price |
      | bvc-item  | 1000         |
    And I add participants for the scheme "bvc points scheme" of "bvc-point-based"
    And I add participants for the scheme "bvc club scheme" of "bvc-club-based"
    And I activate participant "bvc-point-based.bvcuser" account
    And I inactive participant "bvc-point-based.bvcuser" account
    And I active participant "bvc-point-based.bvcuser" account
    And I activate participant "bvc-club-based.bvcuser" account
    And I inactive participant "bvc-club-based.bvcuser" account
    And I active participant "bvc-club-based.bvcuser" account

    And I logout