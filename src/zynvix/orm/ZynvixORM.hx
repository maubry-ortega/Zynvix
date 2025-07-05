// # VolleyDevByMaubry [4/∞] "El inicio de toda conexión no está en el código, sino en la voluntad de comunicarse."
package zynvix.orm;

import zynvix.orm.ZynConnector;

#if python
import zynvix.orm.drivers.python.ZynPythonPostgres;
#end

#if nodejs
import zynvix.orm.drivers.node.ZynNodePostgres;
#end

class ZynvixORM {
  public static var zynConnector:ZynConnector;

  public static function zynInit(config:Dynamic):Void {
    #if python
    zynConnector = new ZynPythonPostgres(); // 👈 solo para Python
    #elseif nodejs
    zynConnector = new ZynNodePostgres();   // 👈 solo para Node.js
    #else
    throw "❌ Target no soportado para ZynvixORM";
    #end

    zynConnector.zynConnect(config);
  }
}
