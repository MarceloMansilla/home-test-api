function fn() {
  const utils = {};

  /**
   * Picks an id between 1 and 100 that is not already used by the given items.
   *
   * @param array  the list of objects, or the raw response ({ data: [ ... ] })
   * @param name   the property holding the id - defaults to 'id'
   * @return the free id as a string, which is the type the API expects
   */
  utils.get_new_id = function (array, name) {
    const key = name || 'id';
    // accept both the response wrapper and a bare list
    const items = (array && array.data) ? array.data : array;

    // indexed loop: Karate exposes JSON arrays as a Java-backed proxy,
    // so map/filter/includes are not reliable here
    const used = {};
    if (items) {
      for (var i = 0; i < items.length; i++) {
        used['' + items[i][key]] = true;
      }
    }

    const free = [];
    for (var n = 1; n <= 100; n++) {
      if (used['' + n] !== true) free.push(n);
    }

    if (free.length === 0) {
      throw new Error('get_new_id: every id between 1 and 100 is already taken');
    }

    return free[Math.floor(Math.random() * free.length)];
  };

  return utils;
}
