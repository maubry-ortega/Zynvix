# Documentación Técnica: ZynvixORM

## Propósito
**ZynvixORM** es el sistema de mapeo de datos de **Zynvix**, diseñado para gestionar modelos de datos en Haxe que se compilen a interacciones con bases de datos relacionales (ORM, e.g., PostgreSQL, MySQL) y NoSQL (ODM, e.g., MongoDB). Proporciona una interfaz unificada, tipo-segura y optimizada para múltiples *targets* (Node.js, Java, PHP, Python, C#), integrándose con otras herramientas de **Zynvix** como **ZynvixRouter** y **ZynvixAdmin**.

## Diseño y objetivos
- **Unificación:** Abstrae las diferencias entre bases de datos relacionales y NoSQL.
- **Tipo-seguridad:** Usa el sistema de tipos de Haxe para validar consultas en tiempo de compilación.
- **Flexibilidad:** Genera código optimizado para cada *target* y base de datos.
- **Integración:** Comparte modelos con **ZynvixTemplates** y soporta **ZynvixAdmin** para CRUD automático.

## Implementación desde cero

### Requisitos
- **Haxe:** Versión 4.3+.
- **Librerías Haxe:** `tink_macro` (macros), `haxe.ds` (estructuras de datos), `tink_sql` (consultas SQL).
- **Dependencias por *target*:**
  - Node.js: `pg` (PostgreSQL), `mongodb` (MongoDB).
  - Java: `java.sql` (JDBC), `mongo-java-driver`.
  - PHP: `pdo` (SQL), `mongodb`.
  - Python: `psycopg2` (PostgreSQL), `pymongo`.
  - C#: `System.Data.SqlClient`, `MongoDB.Driver`.
- **Herramientas externas:** `haxe.macro` para procesamiento en tiempo de compilación.

### Estructura del proyecto
```
zynvix/
├── src/zynvix/orm/
│   ├── Model.hx            # Clase base para modelos
│   ├── Query.hx            # Sistema de consultas
│   ├── Migration.hx        # Gestión de migraciones
│   ├── Connector.hx        # Interfaz para conectores
│   ├── connectors/         # Implementaciones por target
│   │   ├── NodePostgres.hx # Conector PostgreSQL para Node.js
│   │   ├── JavaJDBC.hx     # Conector JDBC para Java
│   │   ├── MongoDB.hx      # Conector MongoDB genérico
│   ├── Schema.hx           # Metadatos de esquemas
```

### Pasos de implementación

1. **Definir la clase base `Model`:**
   - Crea una clase abstracta para representar modelos de datos.
   - Usa anotaciones (`@:model`, `@:field`, `@:relation`) para definir estructura y constraints.

   ```haxe
   // src/zynvix/orm/Model.hx
   package zynvix.orm;

   import haxe.macro.Expr;
   import haxe.macro.Context;

   @:model
   abstract class Model {
     static var schema:Map<String, Dynamic> = new Map();

     macro public static function define(expr:Expr):Expr {
       var fields = Context.getBuildFields();
       var tableName = Context.getLocalClass().get().name.toLowerCase();
       schema.set("table", tableName);
       for (field in fields) {
         for (meta in field.meta) {
           if (meta.name == ":field") {
             var params = {name: field.name, type: field.kind, constraints: meta.params};
             schema.set(field.name, params);
           }
         }
       }
       return macro {};
     }
   }
   ```

2. **Macros para procesar modelos:**
   - Usa `tink_macro` para parsear anotaciones y generar metadatos.
   - Soporta constraints como `primaryKey`, `unique`, `maxLength`.

   ```haxe
   // src/zynvix/orm/Model.hx
   macro public static function define(expr:Expr):Expr {
     var fields = Context.getBuildFields();
     var schemaDef = {fields: [], table: Context.getLocalClass().get().name.toLowerCase()};
     for (field in fields) {
       for (meta in field.meta) {
         if (meta.name == ":field") {
           var constraints = {primaryKey: false, unique: false, maxLength: null};
           for (param in meta.params) {
             switch param {
               case macro primaryKey = true: constraints.primaryKey = true;
               case macro unique = true: constraints.unique = true;
               case macro maxLength = $v: constraints.maxLength = v;
             }
           }
           schemaDef.fields.push({name: field.name, constraints: constraints});
         }
       }
     }
     schema.set(schemaDef.table, schemaDef);
     return macro {};
   }
   ```

3. **Conector abstracto:**
   - Define una interfaz para conectores de bases de datos.
   - Implementa conectores específicos por *target* y base de datos.

   ```haxe
   // src/zynvix/orm/Connector.hx
   interface Connector {
     function connect(config:Dynamic):Void;
     function query(sql:String, params:Array<Dynamic>):Dynamic;
   }

   // src/zynvix/orm/connectors/NodePostgres.hx
   class NodePostgres implements Connector {
     var client:Dynamic;
     public function connect(config:Dynamic):Void {
       client = js.node.Pg.connect(config);
     }
     public function query(sql:String, params:Array<Dynamic>):Dynamic {
       return client.query(sql, params);
     }
   }
   ```

4. **Sistema de consultas (`Query`):**
   - Implementa métodos tipo-seguros para `find`, `filter`, `create`, etc.
   - Usa el AST de Haxe para generar consultas optimizadas.

   ```haxe
   // src/zynvix/orm/Query.hx
   class Query<T:Model> {
     public static function find(cls:Class<T>, id:Int):T {
       var schema = cls.schema;
       var sql = 'SELECT * FROM ${schema.table} WHERE id = $id';
       var result = ZynvixORM.connector.query(sql, [id]);
       return cast result;
     }

     public static function filter(cls:Class<T>, predicate:Expr):Array<T> {
       // Convertir predicate a SQL/NoSQL
       var sql = 'SELECT * FROM ${cls.schema.table} WHERE ...';
       return cast ZynvixORM.connector.query(sql, []);
     }
   }
   ```

5. **Sistema de migraciones:**
   - Compara esquemas actuales con anteriores (en `zynvix_migrations.json`).
   - Genera scripts SQL/NoSQL para crear/actualizar tablas/colecciones.

   ```haxe
   // src/zynvix/orm/Migration.hx
   class Migration {
     public static function generate(model:Class<Model>):String {
       var schema = model.schema;
       var sql = 'CREATE TABLE ${schema.table} (';
       for (field in schema.fields) {
         sql += '${field.name} ${getType(field)}';
         if (field.constraints.primaryKey) sql += ' PRIMARY KEY';
         if (field.constraints.unique) sql += ' UNIQUE';
         sql += ',';
       }
       sql += ');';
       return sql;
     }

     static function getType(field:Dynamic):String {
       return switch (field.type) {
         case TInt: "INTEGER";
         case TString: 'VARCHAR(${field.constraints.maxLength ?? 255})';
         default: "TEXT";
       }
     }
   }
   ```

### Mejoras propuestas
- **Caching:** Implementa un caché en memoria para consultas frecuentes, usando `haxe.ds.Map`.
- **Lazy loading:** Soporta carga diferida para relaciones (e.g., `user.posts`).
- **Query builder:** Añade un DSL para consultas complejas (e.g., `Query.from(User).where(u -> u.age > 18).join(Post)`).
- **Extensibilidad:** Permite plugins para nuevas bases de datos (e.g., Redis).

### Integración con el ecosistema
- **ZynvixRouter:** Proporciona modelos para consultas en controladores.
- **ZynvixTemplates:** Comparte modelos para renderizado.
- **ZynvixAdmin:** Usa modelos para generar interfaces CRUD.
- **ZynvixCLI:** Ejecuta migraciones con `zynvix migrate`.

### Mejores prácticas
- Usa macros para minimizar código repetitivo y garantizar consistencia.
- Valida tipos en tiempo de compilación para consultas.
- Prueba conectores en todos los *targets* y bases de datos soportadas.
- Documenta cada modelo con comentarios para claridad.