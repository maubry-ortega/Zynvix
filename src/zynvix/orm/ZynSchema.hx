// # VolleyDevByMaubry [8/∞] "El esquema es el mapa invisible que guía a los datos antes de que existan."
package zynvix.orm;

typedef ZynField = {
  name:String,
  constraints: {
    primaryKey:Bool,
    unique:Bool,
    maxLength:Null<Int>
  }
};

typedef ZynSchemaDef = {
  table:String,
  fields:Array<ZynField>
};
