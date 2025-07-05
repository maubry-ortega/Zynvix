// # VolleyDevByMaubry [2/∞] "Interrogar a la base de datos es preguntarle al alma del sistema qué ha sido de sus recuerdos."
package zynvix.orm;

import Reflect;

class ZynQuery {
  public static function zynCreate<T>(cls:Class<Dynamic>, data:Dynamic, cb:Dynamic->Void):Void {
    var schema = Reflect.callMethod(cls, Reflect.field(cls, "getSchema"), []);
    var fields:Array<Dynamic> = cast schema.fields;

    // ✅ Ignorar el campo id al insertar
    var insertFields = [for (f in fields) if (f.name != "id") f.name];
    var values = [for (name in insertFields) Reflect.field(data, name)];
    var placeholders = [for (i in 0...values.length) '$' + (i + 1)];

    var sql = 'INSERT INTO "${schema.table}" (${insertFields.join(",")}) VALUES (${placeholders.join(",")}) RETURNING *';

    ZynvixORM.zynConnector.zynQuery(sql, values, function(res) {
      cb(res.length > 0 ? res[0] : null);
    });
  }

  public static function zynFind<T>(cls:Class<Dynamic>, id:Int, cb:Dynamic->Void):Void {
    var schema = Reflect.callMethod(cls, Reflect.field(cls, "getSchema"), []);
    var sql = 'SELECT * FROM "${schema.table}" WHERE id = $1';
    ZynvixORM.zynConnector.zynQuery(sql, [id], function(res) {
      cb(res.length > 0 ? res[0] : null);
    });
  }
}
