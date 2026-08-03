# home-test-api

API test automation for the **"automationapptest"** challenge — QA Automation, QUBEYOND.

Built with [Karate](https://github.com/karatelabs/karate) on JUnit 5 and Maven. The suite is
multi-environment: the same feature files run against `local`, `dev`, `qa`, `staging` or `prod`
by changing a single command-line flag.

---

## 1. Requirements

| Software | Version | Notes |
|---|---|---|
| **JDK** | 11 or higher | `pom.xml` compiles to Java 11. Verified on JDK 21. |
| **Maven** | 3.8 or higher | Verified on 3.8.4. |
| **Git** | any | To clone the repository. |
| Karate | 1.4.1 | Resolved automatically by Maven — no manual install. |
| JUnit 5 | — | Pulled in transitively by `karate-junit5`. |

No global Karate installation, Node.js or IDE plugin is needed. Maven downloads everything on the
first build.

**Verify your toolchain:**

```bash
java -version
mvn -v
```

**For `local` runs only:** the API under test must be listening on `http://localhost:3100`.
Start it before running the suite, otherwise every scenario fails with connection refused.

> The hosts configured for `dev`, `qa`, `staging` and `prod` (`api.develop.com`, `api.qa.com`,
> `api.staging.com`, `api.production.com`) are placeholders. Point them at real endpoints in
> `src/resources/config/environments/` before using those environments.

---

## 2. Project structure

```
home-test-api/
├── README.md
├── .gitignore
└── qubeyond/
    ├── pom.xml                                  ← dependencies, classpath, default environment
    └── src/
        ├── resources/                           ← test classpath root
        │   ├── karate-config.js                 ← base config: loads the YAML for the active env
        │   ├── karate-config-dev.js             ← per-environment overrides (logic only)
        │   ├── karate-config-qa.js
        │   ├── karate-config-staging.js
        │   ├── karate-config-prod.js            ← reads credentials from environment variables
        │   ├── logback-test.xml                 ← logging configuration
        │   ├── config/
        │   │   ├── environments/                ← WHERE each environment lives
        │   │   │   ├── config-local.yml
        │   │   │   ├── config-dev.yml
        │   │   │   ├── config-qa.yml
        │   │   │   ├── config-staging.yml
        │   │   │   └── config-prod.yml
        │   │   └── api/                         ← WHICH endpoints exist
        │   │       ├── config-local.path.yml
        │   │       ├── config-dev.path.yml
        │   │       ├── config-qa.path.yml
        │   │       ├── config-staging.path.yml
        │   │       └── config-prod.path.yml
        │   ├── utils/data/                      ← JSON fixtures
        │   │   ├── dataset/inventory.json       ← payloads driving the add-item cases
        │   │   ├── dataset/inventoryRequiredKeys.json ← drives the missing-field cases
        │   │   ├── dataValidation/inventory.json
        │   │   ├── schemes/inventory.json
        │   │   └── <folder>/<env>/inventory.json ← optional per-environment override
        │   └── features/
        │       ├── operations/                   ← the API layer: every HTTP call
        │       │   └── inventory/
        │       │       └── inventory.feature
        │       └── tests/                        ← the assertions
        │           ├── quality/                  ← response bodies, schemas, data
        │           │   ├── testInventoryAddItem.feature
        │           │   ├── testInventoryAddItemAndValidatePresent.feature
        │           │   ├── testInventoryAddItemForExistent.feature
        │           │   ├── testInventoryAddItemMissingInfo.feature
        │           │   ├── testInventoryFilter.feature
        │           │   └── testInventoryMenu.feature
        │           └── stability/                ← status codes only
        │               ├── testInventoryAddItem.feature
        │               ├── testInventoryAddItemForExistent.feature
        │               ├── testInventoryAddItemMissingInfo.feature
        │               ├── testInventoryFilter.feature
        │               └── testInventoryMenu.feature
        └── test/java/
            └── karate/KarateRunnerTest.java     ← JUnit 5 entry point
```

---

## 3. Architecture

The design principle is a strict separation between **data** and **logic**:

- **YAML files hold data** — hosts, ports, protocols, timeouts, feature flags, endpoint paths, and
  the seed data the assertions depend on. Adding an environment means adding files, not editing code.
- **JavaScript files hold logic** — anything YAML cannot express: reading secrets from the
  environment, validating preconditions, conditional setup.
- **Feature files hold intent** — they never contain a URL, a hardcoded path, a fixed id or a fixed
  count. They reference `baseUrl`, `api.*` and `testData.*`, so the same scenario is
  environment-agnostic.
- **Nothing is shared between scenarios** — `call read('...@tag')` hands the caller back the called
  scenario's variables, so assertions read `response` and `responseStatus` straight off the
  returned value. The suite runs on 5 threads, and no scenario can observe another's state.
- **A test case exists exactly once** — see below.

### Test organisation: directories vs tags

Two independent dimensions classify a test, and each is expressed with the mechanism that fits it:

| Dimension | Values | Expressed as | Why |
|---|---|---|---|
| **What is asserted** | `quality` / `stability` | **directory** | Different assertions on the same call — genuinely different files. `stability` checks the status code; `quality` checks the body, the schema and the data. |
| **When it runs** | `smoke` / `regression` | **tag** | The *same* test, selected by different suites. A copy per suite would be duplication. |

So a quality test carries both tags on one file:

```gherkin
@smokeQuality @regressionQuality
Feature: Inventory Test - Quality
```

`--tags @smokeQuality` and `--tags @regressionQuality` both select it, and a plain `mvn test` runs
it **once**. Promoting a regression test into the smoke suite is adding a tag, never copying a file.

> This replaced an earlier `smoke/` + `regression/` directory split in which every test case existed
> as four byte-identical files (smoke/regression × quality/stability). That layout ran the whole
> suite twice per `mvn test`, made each edit a four-way sync, and had already drifted — two files
> under `regression/stability/` were tagged `@regressionQuality` and were invisible to
> `--tags @regressionStability`. 20 feature files became 11, with identical coverage and tag
> selection.

### Configuration resolution chain

```mermaid
flowchart TD
    A["mvn test -Dkarate.env=qa"] --> B["pom.xml<br/>surefire passes karate.env to the JVM"]
    B --> C["karate-config.js<br/>runs for every environment"]
    C --> D["config/environments/config-qa.yml<br/>protocol · host · port · flags · timeouts"]
    C --> E["config/api/config-qa.path.yml<br/>endpoint paths"]
    D --> F["baseUrl = protocol://host[:port]"]
    E --> G["api = { inventory: { getItems, ... } }"]
    F --> H["config object"]
    G --> H
    H --> I["karate-config-qa.js<br/>overrides merged on top"]
    I --> J["Scenario runs against the resolved config"]
```

**Step by step:**

1. `-Dkarate.env=<env>` is passed on the command line. If omitted, `pom.xml` supplies the default
   (`local`), forwarded to the forked test JVM via surefire's `systemPropertyVariables`.
2. `karate-config.js` runs first for every scenario. It reads `karate.env`, then loads the matching
   pair of YAML files from the classpath.
3. It assembles `baseUrl` from `protocol` + `host` + optional `port`, exposes the endpoint paths as
   `api`, and applies `ssl`, `connectTimeout` and `readTimeout` via `karate.configure`.
4. Karate then loads `karate-config-<env>.js` if present and **merges its return value over** the
   base config. This is where per-environment logic lives.
5. Feature files consume the resulting variables.

### What each layer contains

**`config/environments/config-<env>.yml`** — the environment definition, including the seed data
the scenarios assert against:

```yaml
url:
  protocol: http
  host: localhost
  port: 3100

config:
  debug: true
  ssl: false
  connectTimeout: 5000
  readTimeout: 5000
  mockExternalServices: true
  allowWrites: true      # may the mutating tests POST to this environment?

testData:
  filterId: "3"          # id used by the filter-by-id scenarios
  existingItemId: "1"    # id that must already exist, so POSTing it returns 400
  minItemCount: 9        # smallest catalogue size the menu scenario accepts
```

Without `testData` the scenarios would carry ids and counts that only hold for one environment,
and pointing the suite elsewhere would mean editing feature files. Every environment declares its
own values instead.

**`config/api/config-<env>.path.yml`** — the endpoint catalogue:

```yaml
inventory:
  getItems: /api/inventory
  filterById: /api/inventory/filter
  addItem: /api/inventory/add
```

**`karate-config-<env>.js`** — logic-only overrides. `dev`, `qa` and `staging` are stubs returning
`{}`; `prod` reads credentials from environment variables and fails fast when they are absent:

```javascript
var apiKey = java.lang.System.getenv('PROD_API_KEY');
if (!apiKey) {
  throw new Error('PROD_API_KEY environment variable is required');
}
```

**`inventory.feature`** — no URLs, no hardcoded paths:

```gherkin
Background:
    * url baseUrl

@validation_items
Scenario: Validation keys items
    Given path api.inventory.getItems
    When method GET
    Then status 200
```

### Variables available in every scenario

| Variable | Description |
|---|---|
| `env` | Active environment name, lowercased. |
| `baseUrl` | Full base URL assembled from the environment YAML. |
| `api` | Endpoint paths, e.g. `api.inventory.getItems`. |
| `testData` | Seed data the scenarios assert against — `filterId`, `existingItemId`, `minItemCount`. |
| `debugMode` | When true, enables verbose request/response logging in console and report. |
| `mockExternalServices` | Flag for scenarios that need to branch on mocking. |
| `allowWrites` | Whether this environment may be written to. Absent counts as `false`. |
| `credentials` | **`prod` only** — `apiKey` and `clientSecret` from environment variables. |

---

## 4. Running the tests

All commands run from the **`qubeyond`** directory (the one containing `pom.xml`):

```bash
cd qubeyond
```

### Basic runs

| Goal | Command |
|---|---|
| Full suite, `local` (default) | `mvn test` |
| Full suite, specific environment | `mvn test '-Dkarate.env=qa'` |
| Single tag | `mvn test '-Dkarate.options=--tags @validation_items'` |
| Tag + environment | `mvn test '-Dkarate.env=qa' '-Dkarate.options=--tags @validation_items'` |
| Clean run | `mvn clean test` |

Valid environments: `local`, `dev`, `qa`, `staging`, `prod`.

### ⚠️ Shell quoting

**PowerShell requires single quotes around each `-D` argument.** Without them PowerShell mangles
the arguments and Maven fails with `Unknown lifecycle phase ".env=local"`. The quotes also stop
PowerShell from interpreting `@` as a splatting operator:

```powershell
mvn test '-Dkarate.env=local' '-Dkarate.options=--tags @validation_items'
```

In **Bash / Git Bash** the conventional form works:

```bash
mvn test -Dkarate.env=local -Dkarate.options="--tags @validation_items"
```

### Tag filtering

Tags are declared above a scenario:

```gherkin
@validation_items
Scenario: Validation keys items
```

| Selection | Option |
|---|---|
| One tag | `--tags @smokeQuality` |
| Either tag (OR) | `--tags @smokeQuality,@smokeStability` |
| Both tags (AND) | `--tags @smokeQuality --tags @regressionQuality` |
| Exclude a tag | `--tags ~@wip` |

The suite tags:

| Tag | Selects | Features |
|---|---|---|
| `@smokeQuality` | body / schema / data assertions, smoke suite | 6 |
| `@regressionQuality` | body / schema / data assertions, regression suite | 6 |
| `@smokeStability` | status-code assertions, smoke suite | 5 |
| `@regressionStability` | status-code assertions, regression suite | 5 |
| `@destructive` | every feature that `POST`s — exclude with `~@destructive` where writes are unwanted | 7 |

Quality features carry `@smokeQuality @regressionQuality` and stability features carry
`@smokeStability @regressionStability`, so the two suites currently select the same tests. When they
need to diverge, drop the tag that no longer applies — do not copy the file.

### Running against production

Production refuses to start without credentials, by design:

```powershell
$env:PROD_API_KEY = "..."
$env:PROD_CLIENT_SECRET = "..."
mvn test '-Dkarate.env=prod' '-Dkarate.options=--tags ~@destructive'
```

```bash
PROD_API_KEY=... PROD_CLIENT_SECRET=... mvn test -Dkarate.env=prod -Dkarate.options="--tags ~@destructive"
```

**`~@destructive` is required on production.** The API has no delete, so every
`POST` is permanent — an unfiltered run would leave test items in the live catalogue
forever. `config-prod.yml` sets `allowWrites: false`, so if the filter is forgotten the
mutating scenarios fail immediately with an explicit message **before any request is
sent**; the read-only scenarios still pass. The tag is how you skip them cleanly, the
flag is what guarantees they cannot write.

### Running from an IDE

Run `KarateRunnerTest` directly. It defaults to `local`; select another environment by adding
`-Dkarate.env=qa` to the run configuration's VM options.

---

## 5. Reports

After any run:

```
qubeyond/target/karate-reports/karate-summary.html
```

Open it in a browser for the full HTML report. Cucumber-compatible JSON is emitted alongside it
(`outputCucumberJson(true)` in the runner) for CI tools that consume that format.

When `debug: true` is set for the environment, full request and response bodies are captured in
both the console and the report.

---

## 6. Extending the suite

### Adding an environment

1. Create `src/resources/config/environments/config-<env>.yml`, including its `testData` block
   and `config.allowWrites`. Omitting `allowWrites` counts as `false`, so a new environment is
   never exposed to writes by oversight — it has to opt in.
2. Create `src/resources/config/api/config-<env>.path.yml`.
3. Optionally create `karate-config-<env>.js` for logic-only overrides.
4. Optionally add `utils/data/<folder>/<env>/<name>.json` when a JSON fixture differs from the
   shared default — most notably `dataValidation/<env>/inventory.json`, which must describe the
   record for that environment's `testData.filterId`.
5. Run it: `mvn test '-Dkarate.env=<env>'`.

No change to `karate-config.js` and no change to any feature file is required — resolution is by
naming convention.

### Environment-scoped test data

`functions.getSchemaJsonByName`, `getDataValidationJsonByName` and `getDataSetJsonByName` resolve
in two steps (`utils/functions/DinamicsCalls.js`):

```
utils/data/<folder>/<env>/<name>.json   ← used when present
utils/data/<folder>/<name>.json         ← shared default otherwise
```

An environment only needs its own copy when its data actually differs, so there is no duplication
by default. Scenarios call these loaders by name only and never know which file was used.

### Adding a test case to an existing scenario

The add-item scenarios are **dynamic Scenario Outlines**: the `Examples` table is a single cell
holding an expression, and Karate generates one scenario per element of the list it returns. A new
test case is a new object in a JSON file — no feature file is edited.

Two fixtures drive them:

**`dataset/inventory.json`** — the payloads posted by the add-item scenarios:

```json
[
    {
        "description": "standard item",
        "item": { "id": "10", "name": "Hawaiian", "image": "hawaiian.png", "price": "$14" }
    }
]
```

```gherkin
Scenario Outline: Add new item (<description>) - POST (Add new item)
  * copy new_item = item
  * set new_item.id = utils.get_new_id(items)
  ...
  Examples:
    | read('classpath:utils/data/dataset/inventory.json') |
```

`description` labels the generated scenario in the report, and `item` is the whole payload — so
adding a field to the API means editing the fixture only, never the outline. The `id` is always
overwritten at runtime with a free one, so the value in the file is just a placeholder.

**`dataset/inventoryRequiredKeys.json`** — the fields whose absence must be rejected:

```json
[
    { "key": "id" },
    { "key": "name" },
    { "key": "image" },
    { "key": "price" }
]
```

```gherkin
Scenario Outline: Add new item with missing information (<key>) - ...
  * def body_with_missing_information = utils.remove_key(body, key)
  ...
  Examples:
    | read('classpath:utils/data/dataset/inventoryRequiredKeys.json') |
```

Each object becomes one scenario, and each of its properties becomes a variable inside the outline
(`item` / `key`, also usable as `<description>` / `<key>` in the scenario name). Both fixtures are
shared by their `quality` and `stability` feature files, so one edit covers all.

The scenarios that need one payload rather than the whole set — "add for existent id", "add with
missing information" — take the first entry, `functions.getDataSetJsonByName("inventory")[0].item`:
what they assert depends on the id or the missing key, not on which payload was used.

> Two constraints on the `Examples` cell:
>
> - It is evaluated before the `Background` runs and outside the `karate-config.js` scope, so it can
>   only use Karate built-ins. That is why it calls `read(...)` directly instead of
>   `functions.getDataSetJsonByName(...)` — a `def` from the `Background` or a config variable is
>   not yet defined at that point. Fixtures read this way are not environment-scoped.
> - The `Examples` variables belong to the generated scenario and are not visible from the
>   `Background`, so any step that uses them lives inside the outline.

### Adding an endpoint

Add it to the `config-<env>.path.yml` files, then reference it as `api.<resource>.<operation>`.

### Adding a feature

Drop any `.feature` file under `src/resources/features/`. The runner picks up the whole tree via
`Runner.path("classpath:features")` — no registration needed.

Put it under `features/tests/quality/` when it asserts on the body, and under
`features/tests/stability/` when it asserts on the status code, then tag it for the suites that
should run it — `@smokeQuality @regressionQuality` or `@smokeStability @regressionStability`. One
file per test case: an untagged suite is a missing tag, never a copied file.

Add `@destructive` if it writes — including when the write is *expected to be rejected*, since a
regression in the API's validation would turn that rejection into a real record. Forgetting the tag
does not expose a protected environment: the guard lives in the operations layer, at the single step
every write passes through, so the run fails with an explicit message instead of writing.

A new resource follows the same shape — `features/operations/<resource>/<resource>.feature` for the
calls, one file per test case under `tests/quality/` and `tests/stability/` for the assertions.

---

## 7. Secrets

Credentials are never committed. They are read from environment variables at runtime and validated
in `karate-config-prod.js`. `.gitignore` excludes `config-*-secrets.yml` and `credentials.yml`.

Note that `.gitignore` also carries a broad `*-local.yml` rule, with an explicit exception for
`config/**/config-local*.yml` — that file defines the local environment, contains no secrets, and
must stay in version control so a fresh clone can run `mvn test` out of the box.
