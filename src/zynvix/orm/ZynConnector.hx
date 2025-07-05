// # VolleyDevByMaubry [7/∞] "Conectar no es solo enlazar procesos, es abrir caminos entre mundos que antes no se hablaban."
package zynvix.orm;

interface ZynConnector {
  function zynConnect(config:Dynamic):Void;
  function zynQuery(sql:String, params:Array<Dynamic>, cb:Array<Dynamic>->Void):Void;
}
