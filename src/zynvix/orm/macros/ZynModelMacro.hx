// # VolleyDevByMaubry [5/∞] "La macro observa lo invisible y teje, en silencio, la lógica que sostiene lo evidente."
package zynvix.orm.macros;

import haxe.macro.Context;
import haxe.macro.Expr;

class ZynModelMacro {
  static var zynSchemas:Array<{ name:String, schema:Dynamic }> = [];

  public static macro function build():Array<Field> {
    var fields = Context.getBuildFields();
    var className = Context.getLocalClass().get().name.toLowerCase();

    var schema = {
      table: className,
      fields: []
    };

    for (field in fields) {
      for (meta in field.meta) {
        if (meta.name == ":field") {
          var constraints = {
            primaryKey: false,
            unique: false,
            maxLength: null
          };

          for (param in meta.params) {
            switch param.expr {
              case EConst(CIdent("primaryKey")): constraints.primaryKey = true;
              case EConst(CIdent("unique")): constraints.unique = true;
              case EBinop(OpAssign, { expr: EConst(CIdent("maxLength")) }, { expr: EConst(CInt(v)) }):
                constraints.maxLength = Std.parseInt(v);
              default:
            }
          }

          schema.fields.push({name: field.name, constraints: constraints});
        }
      }
    }

    // Guardar para registrar más tarde
    zynSchemas.push({ name: className, schema: schema });

    // Al final de todo, registrar todos los schemas
    Context.onGenerate((types) -> {
      for (entry in zynSchemas) {
        Context.defineModule("ZynModelSchema_" + entry.name, [macro class Dummy {
          static function __init__() {
            zynvix.orm.ZynModel.zynSchema.set($v{entry.name}, $v{entry.schema});
          }
        }]);
      }
    });

    return fields;
  }
}
