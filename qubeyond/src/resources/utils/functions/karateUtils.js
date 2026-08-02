function fn() {
  const utils = {};

  utils.basic_auth = function (username, password) {
    var temp = username + ':' + password;
    var Base64 = Java.type('java.util.Base64');
    var String = Java.type('java.lang.String');
    var encoded = Base64.getEncoder().encodeToString(new String(temp).getBytes('utf-8'));
    return 'Basic ' + encoded;
  };

  utils.print_request_info = (res, res_status, body) => {
    if (true) {
      karate.log(`[${karate.prevRequest.method}] - ${karate.prevRequest.url}`);
      if (body) {
        karate.log(`[BODY]:`);
        karate.log(body);
      }
      karate.log(`[RESPONSE]: ${res_status}`);
      if (res) {
        karate.log(res);
      }
    }
  };

  utils.getFilteredData = (response, filter) => {
    return karate.jsonPath(response, filter)
  };

  utils.dataPreparation = () => { };

  utils.getRandomEmail = (baseEmail) => {
    var f = new Date();
    return baseEmail + "+" + notepad.get('store_id') + f.getDate() + "" + (f.getMonth() + 1) + "" + f.getFullYear() + "" + f.getHours() + "" + f.getMinutes() + "" + f.getSeconds() + "@gmail.com";
  };

  utils.getRandomData = (array_data) => {
    const randomIndex = Math.floor(Math.random() * array_data.length);
    return array_data[randomIndex]
  };

  utils.sleep = (seconds) => { java.lang.Thread.sleep(seconds * 1000) };

  utils.getJSONObjectFromListByAttributeValue = (jsonlist, attributename, attibutevalue) => {
    return jsonlist.find(s => s[attributename] == attibutevalue);
  };

  utils.convertStringToJSON = (payloadstring) => {
    return JSON.parse(payloadstring);
  };

  utils.getCurrentTimestamp = () => {
    return new Date().getTime().toString();
  };

  utils.exitsData = (list, word) => {
    if (list.includes(word)) {
      return word
    } else {
      throw Error('\x1B[31;40m \n******INVALID DATA******\n- "' + word + '" does not exist.\x1B[0m' + '\n' + '\u001B[32m- Expected values: ' + list + '' + '\u001B[0m')
    }
  };

  utils.doUpperCase = (word) => {
    return word.toUpperCase();
  };

  utils.getActualDate = () => {
    // var f = new Date();
    // return f.getDate() + "" + (f.getMonth() + 1) + "" + f.getFullYear() + "" + f.getHours() + "" + f.getMinutes() + "" + f.getSeconds();
    return (new Date()).toISOString().replaceAll(/\-|\:/g, "") + " (UTC)";
  };

  utils.printResponse = (response) => {
    karate.log('**************** RESPONSE ****************');
    if (karate.prevRequest) karate.log('[' + karate.prevRequest.method + '] - ' + karate.prevRequest.url);
    karate.log(response);
    karate.log('************** END RESPONSE **************');
    return response;
  }

  utils.printVariable = (name, value) => {
    karate.log(name + ': ' + value);
    return true;
  }

  utils.getTagName = (tag) => {
    return tag.slice(4, (tag.length - 4))
  }


  utils.getToken = () => {
    // Ejemplo: genera un string aleatorio de 64 caracteres alfanuméricos
    var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    var token = '';
    for (var i = 0; i < 64; i++) {
      token += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return token;
  }

  utils.getEmailBuyerOrSellerRol = function (role) {
    var rol = '';
    if (!role || typeof role !== 'string') return role;
    rol = role.charAt(0).toUpperCase() + role.slice(1);
    var name = 'rolUser' + rol + 'Username' + country.toUpperCase();
    let email = { value: name }
    return email.value
  }

  utils.generateCSRF = function () {
    var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    var result = '';
    for (var i = 0; i < 24; i++) {
      result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
  }

  utils.generateNickname = function () {
    var letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    var chars = letters;
    var length = Math.floor(Math.random() * 5) + 4; // entre 4 y 8
    var nickname = letters.charAt(Math.floor(Math.random() * letters.length)); // empieza con letra
    for (var i = 1; i < length; i++) {
      nickname += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return nickname;
  }

  return utils;
}
