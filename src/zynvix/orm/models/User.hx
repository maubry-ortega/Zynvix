package zynvix.orm.models;

import zynvix.orm.ZynModel;

@:model
class User extends ZynModel {
  @:field(primaryKey) public var id:Int;
  @:field(unique, maxLength = 50) public var name:String;
  @:field(unique) public var email:String;
  @:field() public var password:String;

  // ✅ función en vez de variable
  public static function getSchema():Dynamic {
    return zynvix.orm.ZynModel.zynSchema.get("user");
  }
}
