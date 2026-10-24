Feature: Credit card registration
  A card is not an account. It has a limit, closing day, due day, default payment account and start date.

  Background:
    Given today is 2026-03-15
    And the account "Nubank" of kind "checking" with opening balance R$ 1,000.00 on 2026-01-01
    And the account "Reserve" of kind "reserve" with purpose "saving" and opening balance R$ 2,000.00 on 2026-01-01
    And the account "Old" of kind "checking" with opening balance R$ 0.00 on 2026-01-01
    And the account "Old" is archived

  @CAR-1 @CAR-3 @CAR-8 @FAT-3 @FAT-13
  Scenario: A card is created with valid data
    When I create the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10 and payment account "Nubank"
    Then the card "Purple" is active
    And the start date of card "Purple" is 2026-03-15
    And the available limit of card "Purple" is R$ 5,000.00
    And the current open statement of card "Purple" is the 2026-04 one
    And the 2026-04 statement of card "Purple" closes on 2026-04-03 and is due on 2026-04-10

  @CAR-1 @GER-8 @error
  Scenario Outline: Invalid fields block the registration
    When I create the card "<name>" with limit <limit>, closing day <closes>, due day <due> and payment account "Nubank"
    Then the operation is blocked with the message "<message>"
    And there is no new card

    Examples:
      | name                                      | limit             | closes | due | message                              |
      |                                           | R$ 5,000.00       | 3      | 10  | Name is required                     |
      | AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA | R$ 5,000.00       | 3      | 10  | Name must have at most 40 characters |
      | Violet                                    | R$ 0.00           | 3      | 10  | Limit must be greater than zero      |
      | Violet                                    | -R$ 100.00        | 3      | 10  | Limit must be greater than zero      |
      | Violet                                    | R$ 100,000,000.00 | 3      | 10  | Maximum limit is R$ 99,999,999.99    |
      | Violet                                    | R$ 5,000.00       | 0      | 10  | Closing day must be between 1 and 31 |
      | Violet                                    | R$ 5,000.00       | 32     | 10  | Closing day must be between 1 and 31 |
      | Violet                                    | R$ 5,000.00       | 3      | 0   | Due day must be between 1 and 31     |
      | Violet                                    | R$ 5,000.00       | 3      | 32  | Due day must be between 1 and 31     |

  @CAR-1 @GER-9 @error
  Scenario: A name with only spaces is empty
    When I create the card "     " with limit R$ 5,000.00, closing day 3, due day 10 and payment account "Nubank"
    Then the operation is blocked with the message "Name is required"

  @CAR-1 @GER-8 @edge
  Scenario Outline: Values at the allowed boundaries are accepted
    When I create the card "<name>" with limit <limit>, closing day <closes>, due day <due> and payment account "Nubank"
    Then the card "<name>" is active

    Examples:
      | name                                     | limit            | closes | due |
      | X                                        | R$ 5,000.00      | 3      | 10  |
      | AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA | R$ 5,000.00      | 3      | 10  |
      | Minimum                                  | R$ 0.01          | 3      | 10  |
      | Maximum                                  | R$ 99,999,999.99 | 3      | 10  |
      | Extremes A                               | R$ 5,000.00      | 1      | 31  |
      | Extremes B                               | R$ 5,000.00      | 31     | 1   |

  @CAR-1 @GER-9
  Scenario: The name is saved without leading or trailing spaces and with inner spaces collapsed
    When I create the card "  Banco   Inter  " with limit R$ 5,000.00, closing day 3, due day 10 and payment account "Nubank"
    Then the card "Banco Inter" is active

  @CAR-1 @GER-9 @error
  Scenario Outline: A name repeated among active cards, compared normalized
    Given the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10 and payment account "Nubank"
    When I create the card "<name>" with limit R$ 1,000.00, closing day 28, due day 5 and payment account "Nubank"
    Then the operation is blocked with the message "An active card with this name already exists"

    Examples:
      | name   |
      | Purple |
      | purple |
      | PURPLE |
      | Púrple |

  @CAR-1 @GER-9 @error
  Scenario: Renaming to the name of another active card is blocked
    Given the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10 and payment account "Nubank"
    And the card "Black" with limit R$ 10,000.00, closing day 28, due day 5 and payment account "Nubank"
    When I rename the card "Black" to "purple"
    Then the operation is blocked with the message "An active card with this name already exists"

  @CAR-1
  Scenario: The name of an archived card can be reused
    Given the card "Retired" with limit R$ 1,000.00, closing day 3, due day 10 and payment account "Nubank"
    And the card "Retired" is archived
    When I create the card "retired" with limit R$ 2,000.00, closing day 15, due day 22 and payment account "Nubank"
    Then the card "retired" is active

  @CAR-3 @error
  Scenario Outline: Payment account required, active and "spending"
    When I create the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10 and payment account "<account>"
    Then the operation is blocked with the message "<message>"

    Examples:
      | account | message                                        |
      |         | A payment account is required                  |
      | Old     | The payment account must be active             |
      | Reserve | The payment account must be a spending account |

  @CAR-3 @error
  Scenario: Switching the payment account to a "saving" account is blocked
    Given the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10 and payment account "Nubank"
    When I change the default payment account of card "Purple" to "Reserve"
    Then the operation is blocked with the message "The payment account must be a spending account"
    And the default payment account of card "Purple" is "Nubank"
