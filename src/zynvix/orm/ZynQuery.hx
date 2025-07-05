// # VolleyDevByMaubry [2/∞] "Interrogar a la base de datos es preguntarle al alma del sistema qué ha sido de sus recuerdos."
package zynvix.orm;

import Reflect;

class ZynQuery {
  public static function zynCreate<T>(cls:Class<Dynamic>, data:Dynamic, cb:Dynamic->Void):Void {
    var schema = Reflect.callMethod(cls, Reflect.field(cls, "getSchema"), []);
    var fields:Array<Dynamic> = cast schema.fields;

    var insertFields = [for (f in fields) if (f.name != "id") f.name];
    var values = [for (name in insertFields) Reflect.field(data, name)];

    // 💡 Placeholders dinámicos según el target
    var placeholders:Array<String>;

    #if python
    // psycopg2 usa %s para todos los valores, sin índice
    placeholders = [for (_ in 0...values.length) "%s"];
    #else
    // Otros (como pg en Node.js) usan $1, $2, $3...
    placeholders = [for (i in 0...values.length) '$' + (i + 1)];
    #end

    var sql = 'INSERT INTO "${schema.table}" (${insertFields.join(",")}) VALUES (${placeholders.join(",")}) RETURNING *';

    ZynvixORM.zynConnector.zynQuery(sql, values, function(res) {
      cb(res.length > 0 ? res[0] : null);
    });
  }

  public static function zynFind<T>(cls:Class<Dynamic>, id:Int, cb:Dynamic->Void):Void {
    var schema = Reflect.callMethod(cls, Reflect.field(cls, "getSchema"), []);

    var sql:String;

    #if python
    sql = 'SELECT * FROM "${schema.table}" WHERE id = %s';
    #else
    sql = 'SELECT * FROM "${schema.table}" WHERE id = $1';
    #end

    ZynvixORM.zynConnector.zynQuery(sql, [id], function(res) {
      cb(res.length > 0 ? res[0] : null);
    });
  }
}
