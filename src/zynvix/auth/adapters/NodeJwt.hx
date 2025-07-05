package zynvix.auth.adapters;

import js.node.JsonWebToken;

class NodeJwt {
  public static function generateToken(user:Dynamic):String {
    return JsonWebToken.sign({id: user.id, name: user.name}, "secret", {expiresIn: "1h"});
  }
}