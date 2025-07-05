package zynvix.auth;

import zynvix.orm.ZynvixORM;

class Auth {
  public static function authenticate(username:String, password:String):Dynamic {
    var user = ZynvixORM.find(User, u -> Reflect.field(u, "name") == username);
    if (user == null || Reflect.field(user, "password") != password) {
      throw "Invalid credentials";
    }
    return {token: adapters.NodeJwt.generateToken(user)};
  }
}