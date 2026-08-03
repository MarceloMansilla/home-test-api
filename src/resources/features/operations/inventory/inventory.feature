@ignore
Feature: Inventory

    Background:
        # baseUrl and api both come from karate-config.js for the active karate.env
        * url baseUrl

    # Each scenario ends on the call itself: Karate hands the caller back this
    # scenario's variables, so 'response' and 'responseStatus' are read from the
    # value that 'call read(...)' returns - no shared state in between.

    @validation_items
    Scenario: Validation keys items
        Given path api.inventory.getItems
        When method GET

    @filter_by_id
    Scenario: Filter by id
        Given path api.inventory.filterById
        And param id = id_item
        When method GET

    @add_new_item
    Scenario: Add new item
        # Every write in the suite passes through here, so this is the one place
        # that can guarantee a protected environment is never written to - a new
        # write test cannot bypass it, and neither can a mistaken --tags run.
        # The @destructive tag is the ergonomic way to skip these tests; this is
        # the guarantee. Any future write verb needs the same line.
        * if (!allowWrites) karate.fail("writes are disabled for env '" + env + "': the API has no delete, so a POST here would be permanent. Exclude the mutating tests with --tags ~@destructive, or set config.allowWrites: true in config/environments/config-" + env + ".yml")
        Given path api.inventory.addItem
        And request body_item
        When method POST
