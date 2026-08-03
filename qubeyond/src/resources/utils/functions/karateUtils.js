function fn() {
  const utils = {};

  // upper bound of the id pool - single source of truth, so the bound and the
  // messages that mention it cannot drift apart
  const MAX_ID = 400;

  /**
   * Picks an id between 1 and MAX_ID that is not already used by the given items.
   *
   * @param array  the list of objects, or the raw response ({ data: [ ... ] })
   * @param name   the property holding the id - defaults to 'id'
   * @return the free id as a string, which is the type the API expects
   */
  utils.get_new_id = function (array, name) {
    const key = name || "id";
    // accept both the response wrapper and a bare list
    const items = array && array.data ? array.data : array;

    // indexed loop: Karate exposes JSON arrays as a Java-backed proxy,
    // so map/filter/includes are not reliable here
    const used = {};
    if (items) {
      for (var i = 0; i < items.length; i++) {
        used["" + items[i][key]] = true;
      }
    }

    const free = [];
    for (var n = 1; n <= MAX_ID; n++) {
      if (used["" + n] !== true) free.push(n);
    }

    if (free.length === 0) {
      throw new Error(
        "get_new_id: every id between 1 and " + MAX_ID + " is already taken",
      );
    }

    // coerced to a string: the seed catalogue stores ids as "1", and a number
    // here would make every item the suite adds number-typed, forcing the
    // schema to accept both and blinding it to an id-type regression
    return "" + free[Math.floor(Math.random() * free.length)];
  };

  /**
   * Returns a copy of obj without the given key.
   *
   * @param obj   the source object - not mutated
   * @param name  the key to drop
   */
  utils.remove_key = function (obj, name) {
    const copy = JSON.parse(JSON.stringify(obj));
    delete copy[name];
    return copy;
  };

  /**
   * Finds the first object in the list whose id matches the given value.
   *
   * @param array  the list of objects, or the raw response ({ data: [ ... ] })
   * @param value  the id to look for - number or string, both match
   * @param name   the property holding the id - defaults to 'id'
   * @return the matching object, or null when there is none
   */
  utils.get_object_by_id = function (array, value, name) {
    const key = name || "id";
    const items = array && array.data ? array.data : array;

    if (!items) return null;

    // compare as strings: the API stores ids as "1" but accepts 1,
    // so the same item can carry either type
    const target = "" + value;
    for (var i = 0; i < items.length; i++) {
      if ("" + items[i][key] === target) return items[i];
    }

    return null;
  };

  return utils;
}
