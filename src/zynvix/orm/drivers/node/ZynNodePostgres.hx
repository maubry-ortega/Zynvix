// # VolleyDevByMaubry [6/∞] "Todo conector es un puente. Su firmeza está en la confianza entre extremos."
package zynvix.orm.drivers.node;

import zynvix.orm.ZynConnector;

@:jsRequire("pg", "Client")
extern class ZynPgClient {
  function new(config:Dynamic):Void;
  function connect(cb:Dynamic->Void):Void;
  function query(sql:String, params:Array<Dynamic>, cb:Dynamic->Dynamic->Void):Void;
}

class ZynNodePostgres implements ZynConnector {
  var zynClient:ZynPgClient;

  public function new() {}

  public function zynConnect(config:Dynamic):Void {
    zynClient = new ZynPgClient({
      user: config.user,
      password: config.password,
      host: config.host,
      database: config.dbname,
      port: config.port
    });

    zynClient.connect((err) -> {
      if (err != null) {
        trace("❌ Zyn: Connection error: " + err.message);
      } else {
        trace("✅ Zyn: Connected to PostgreSQL!");
      }
    });
  }

  public function zynQuery(sql:String, params:Array<Dynamic>, cb:Array<Dynamic>->Void):Void {
    zynClient.query(sql, params, function(err, res) {
      if (err != null) {
        trace("❌ Zyn: Query error: " + err.message);
        cb([]); // ⛔ retornar arreglo vacío si hay error
      } else {
        var result:Array<Dynamic> = [];
        for (row in (cast res.rows:Array<Dynamic>)) {
          result.push(row);
        }
        cb(result);
      }
    });
  }
}