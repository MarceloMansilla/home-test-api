function fn() {
  const functions = {};

  functions.getSchemaJsonByName = function (name) {
    return karate.read("classpath:utils/data/schemes/" + name + ".json");
  };

  functions.getDataValidationJsonByName = function (name) {
    return karate.read("classpath:utils/data/dataValidation/" + name + ".json");
  };

  functions.getDataSetJsonByName = function (name) {
    return karate.read("classpath:utils/data/dataset/" + name + ".json");
  };

  return functions;
}
