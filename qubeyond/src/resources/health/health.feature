Feature: Preflight - is the target reachable?

    # This file lives outside features/ on purpose. The runner's main path is
    # classpath:features, so the preflight can never be picked up as an extra
    # test case, and no tag has to be maintained to keep it out.
    #
    # It asserts reachability, not behaviour: if this fails the suite is not
    # run at all, so it must not fail for any reason other than "the target
    # is not answering". Keep assertions here to the bare minimum.

    Background:
        # baseUrl and api come from karate-config.js, so the URL stays resolved
        # from the environment YAML - the runner never has to know a host
        * url baseUrl

    Scenario: Target is reachable
        Given path api.inventory.getItems
        # a container that is still starting answers late rather than not at all,
        # so treat that as 'not ready yet' instead of 'down'
        * configure retry = { count: 3, interval: 2000 }
        And retry until responseStatus == 200
        When method GET
        Then status 200
