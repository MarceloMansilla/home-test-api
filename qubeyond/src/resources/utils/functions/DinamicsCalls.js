function fn() {
  const functions = {};

  functions.getSchemaJsonByName = function (name) {
    return karate.read("classpath:utils/data/schemes/" + name + ".json");
  };

  return functions;
}
