/**
 * Loaders for the JSON test data, resolved per environment.
 *
 * Each loader looks for an environment-specific file first and falls back to
 * the shared one, so an environment only needs its own copy when its data
 * actually differs:
 *
 *   utils/data/<folder>/<env>/<name>.json   <- used when present
 *   utils/data/<folder>/<name>.json         <- shared default
 *
 * Scenarios call these by name only, so pointing the suite at another
 * environment never means editing a feature file.
 */
function fn() {
  const functions = {};

  const env = (karate.env || "local").toLowerCase();

  /**
   * Builds the classpath path for a data file, preferring the environment copy.
   *
   * @param folder  the folder under utils/data - 'schemes', 'dataset', ...
   * @param name    the file name without the .json extension
   */
  function resolve(folder, name) {
    const base = "utils/data/" + folder + "/";
    const scoped = base + env + "/" + name + ".json";

    // getResource returns null when the file is not on the test classpath,
    // which is the only way to probe for it - karate.read throws instead
    const found = java.lang.Thread.currentThread()
      .getContextClassLoader()
      .getResource(scoped);

    return karate.read("classpath:" + (found ? scoped : base + name + ".json"));
  }

  functions.getSchemaJsonByName = function (name) {
    return resolve("schemes", name);
  };

  functions.getDataValidationJsonByName = function (name) {
    return resolve("dataValidation", name);
  };

  functions.getDataSetJsonByName = function (name) {
    return resolve("dataset", name);
  };

  return functions;
}
