// # VolleyDevByMaubry [3/∞] "Migrar es aceptar que la estructura de hoy no será la misma que la de mañana."
package zynvix.orm;

import zynvix.orm.ZynSchema.ZynField;
import zynvix.orm.ZynSchema.ZynSchemaDef;

class ZynMigration {
  public static function zynRun():Void {
    var raw:Map<String, Dynamic> = ZynModel.zynSchema;
    for (table in raw.keys()) {
      var schema:ZynSchemaDef = cast raw.get(table);
      var sql = 'CREATE TABLE IF NOT EXISTS "${schema.table}" (';
      var fields = [];
      var fList:Array<Dynamic> = cast schema.fields;
      for (f in fList) {
        var line = '${f.name} ${zynGetType(f)}';
        if (f.constraints.primaryKey) line += ' PRIMARY KEY';
        if (f.constraints.unique) line += ' UNIQUE';
        fields.push(line);
      }
      sql += fields.join(", ") + ");";
      ZynvixORM.zynConnector.zynQuery(sql, [], function(_) {
        trace("📦 Zyn: Migrated " + schema.table);
      });
    }
  }

  static function zynGetType(f:ZynField):String {
    return switch (f.name) {
      case "id": "SERIAL";
      case "name", "email": 'VARCHAR(${f.constraints.maxLength ?? 255})';
      default: "TEXT";
    }
  }
}
