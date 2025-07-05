package zynvix.orm.drivers.python;

import python.Dict;
import python.Syntax;
import zynvix.orm.ZynConnector;
import zynvix.orm.drivers.python.PyPsycopg2;

class ZynPythonPostgres implements ZynConnector {
  public var conn:Dynamic;
  public var cursor:Dynamic;

  public function new() {}

  public function zynConnect(config:Dynamic):Void {
    var pyDict = new Dict<String, Dynamic>();
    pyDict.set("host", config.host);
    pyDict.set("user", config.user);
    pyDict.set("password", config.password);
    pyDict.set("dbname", config.dbname);
    pyDict.set("port", config.port);

    trace("💡 Cargando psycopg2...");

    // Usa Syntax.code para pasar el dict como **kwargs
    conn = Syntax.code("psycopg2.connect(**{0})", pyDict);
    cursor = conn.cursor();

    trace("✅ Zyn (Python): ¡Conectado a PostgreSQL!");
  }

  public function zynQuery(sql:String, params:Array<Dynamic>, cb:Array<Dynamic>->Void):Void {
    try {
      cursor.execute(sql, params);
      var rows = cursor.fetchall();
      var result:Array<Dynamic> = [for (r in python.Lib.toHaxeIterable(rows)) r];
      cb(result);
    } catch (e:Dynamic) {
      trace("❌ Error al ejecutar consulta: " + e);
      cb([]);
    }
  }
}
