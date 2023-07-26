/* Class criada para persistência de dados da nossa aplicação 

  Dados persistidos significa dizer que vai manter as informações no
  armazenamento do celular e 
*/

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Store {
  /* Método para salvar uma string.

      Recebe como parâmetros uma chave um valor.
   */
  static Future<bool> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    /* Retorna um boolean que diz se ele foi ou não persistido */
    return prefs.setString(key, value);
  }

  /* Método que salva um Map 

    Recebe como parâmetros uma String chave um Map valor.
  */

  static Future<bool> saveMap(String key, Map<String, dynamic> value) async {
    return saveString(key, jsonEncode(value));
  }

  /* Retorna o valor da string */
  static Future<String> getString(String key,
      [String defaultValue = '']) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? defaultValue;
  }

  /* Retorna o valor do Map
  caso não tenha um json válido retorna um método vazio */
  static Future<Map<String, dynamic>> getMap(String key) async {
    try {
      return jsonDecode(await getString(key));
    } catch (_) {
      return {};
    }
  }

  /* Método utilizado para remoção */
  static Future<bool> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }
}
