// # VolleyDevByMaubry [4/∞] "El inicio de toda conexión no está en el código, sino en la voluntad de comunicarse."
package zynvix.orm;

import zynvix.orm.connectors.ZynNodePostgres;

class ZynvixORM {
  public static var zynConnector:ZynConnector;

  public static function zynInit(config:Dynamic):Void {
    zynConnector = new ZynNodePostgres();
    zynConnector.zynConnect(config);
  }
}
