Feature: Starting to use the app with a card already in use

  Background:
    Given today is 2026-03-01
    And the user's time zone is "America/Sao_Paulo"

  @integration @CAR-9 @CAR-8 @FAT-5 @FAT-6 @FAT-9 @STA-4 @PRJ-2 @LIM-1 @INV-7
  Scenario Outline: Starting with a closed unpaid statement
    Given today is <today>
    And the account "Nubank" of kind "checking" with opening balance R$ 2,000.00 on 2026-03-01
    And the daily amount is R$ 0.00 since 2026-03-01
    When I create the card "Purple" with limit R$ 5,000.00, closing day 3, due day 10, payment account "Nubank" and start date <today>
    And I enter the closed unpaid statement balance of card "Purple" as R$ 700.00
    Then the purchase "Pre-app balance" of R$ 700.00 has date 2026-03-02 and is in the 2026-03 statement of card "Purple"
    And the 2026-03 statement of card "Purple" is "<status>" with outstanding R$ 700.00
    And the available limit of card "Purple" is R$ 4,300.00
    And the "Pre-app balance" is valid under INV-7 even with a date before the start date, through the exception in CAR-9
    And <question> "Did you pay?" for the 2026-03 statement of card "Purple"
    And the projected balance of account "Nubank" on <today> is <projected today>

    Examples:
      | today      | status  | question             | projected today |
      | 2026-03-05 | closed  | there is no question | R$ 2,000.00     |
      | 2026-03-10 | closed  | there is no question | R$ 1,300.00     |
      | 2026-03-15 | overdue | I see the question   | R$ 1,300.00     |
