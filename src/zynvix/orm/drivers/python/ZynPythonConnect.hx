package zynvix.orm.drivers.python;

// 💡 Importa directamente la función 'connect' del módulo psycopg2
@:pythonImport("psycopg2.connect")
extern function pyConnect(args:Dynamic):Dynamic;
