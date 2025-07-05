package zynvix.orm.drivers.python;

@:pythonImport("psycopg2")
extern class PyPsycopg2 {
  public static function connect(args:haxe.extern.Rest<Dynamic>):Dynamic;
}
