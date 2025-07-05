package zynvix.orm.connectors;

import StringTools;

class MockConnector implements zynvix.orm.Connector {
  var tables:Map<String, Array<Dynamic>>;
  public function new() {
    tables = new Map();
  }

  public function connect(config:Dynamic):Void {
    trace("MockConnector: Connected with config " + Std.string(config));
  }

  public function query(sql:String, params:Array<Dynamic>):Array<Dynamic> {
    trace("MockConnector: Executing query: " + sql + " with params: " + params);
    
    if (sql.indexOf("CREATE TABLE") == 0) {
      var tableName = sql.split(" ")[3];
      tables.set(tableName, []);
      return [];
    }

    if (sql.indexOf("INSERT INTO") == 0) {
      var tableName = sql.split(" ")[2];
      var record = {};
      var fields = sql.substring(sql.indexOf("(") + 1, sql.indexOf(")")).split(",").map(s -> StringTools.trim(s));
      for (i in 0...fields.length) {
        Reflect.setField(record, fields[i], params[i]);
      }
      if (!tables.exists(tableName)) tables.set(tableName, []);
      tables.get(tableName).push(record);
      return [record];
    }

    if (sql.indexOf("SELECT * FROM") == 0) {
      var tableName = sql.split(" ")[3];
      var id = params[0];
      var table = tables.get(tableName);
      if (table != null) {
        for (record in table) {
          if (Reflect.field(record, "id") == id) {
            return [record];
          }
        }
      }
      return [];
    }

    return [];
  }
}
