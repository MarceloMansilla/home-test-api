@ignore
Feature: Inventory

    Background:
        # baseUrl and api both come from karate-config.js for the active karate.env
        * url baseUrl


    @validation_items
    Scenario: Validation keys items
        Given path api.inventory.getItems
        When method GET
        * notepad.set('response_items', response)

        
    @filter_by_id
    Scenario: Filter by id
        Given path api.inventory.filterById
        And param id = id_item
        When method GET
        * notepad.set('response_filter_by_id', response)