# Documentación Técnica: ZynvixRouter

## Propósito
**ZynvixRouter** es el sistema de ruteo de **Zynvix**, encargado de mapear URLs a controladores, generando código para frameworks web nativos (e.g., Express para Node.js, Spring para Java). Se integra con **ZynvixORM** para datos, **ZynvixAuth** para seguridad, y **ZynvixTemplates** para renderizado.

## Diseño y objetivos
- **Unificación:** Abstrae frameworks web para una API consistente.
- **Tipo-seguridad:** Valida parámetros de ruta en tiempo de compilación.
- **Flexibilidad:** Soporta REST, GraphQL y microservicios.
- **Integración:** Conecta con otras herramientas para un flujo completo.

## Implementación desde cero

### Requisitos
- **Haxe:** Versión 4.3+.
- **Librerías Haxe:** `tink_macro` (macros), `haxe.http` (manejo HTTP).
- **Dependencias por *target*:**
  - Node.js: `express`.
  - Java: `spring-web`.
  - PHP: `slim`.
  - Python: `flask`.
  - C#: `ASP.NET Core`.

### Estructura del proyecto
```
zynvix/
├── src/zynvix/router/
│   ├── Router.hx           # Clase base para rutas
│   ├── Response.hx         # Manejo de respuestas HTTP
│   ├── Request.hx          # Manejo de solicitudes HTTP
│   ├── adapters/           # Adaptadores por target
│   │   ├── NodeExpress.hx  # Adaptador para Express
│   │   ├── JavaSpring.hx   # Adaptador para Spring
```

### Pasos de implementación

1. **Definir la clase `Router`:**
   - Crea una clase para registrar rutas y controladores.
   - Usa anotaciones (`@:controller`, `@:route`).

   ```haxe
   // src/zynvix/router/Router.hx
   package zynvix.router;

   import haxe.macro.Expr;
   import haxe.macro.Context;

   class Router {
     static var routes:Map<String, Dynamic> = new Map();

     macro public static function register(expr:Expr):Expr {
       var fields = Context.getBuildFields();
       for (field in fields) {
         for (meta in field.meta) {
           if (meta.name == ":route") {
             var method = meta.params[0].toString();
             var path = meta.params[1].toString();
             routes.set('$method:$path', field);
           }
         }
       }
       return macro {};
     }
   }
   ```

2. **Macros para rutas:**
   - Procesa `@:route` para generar código nativo por *target*.
   - Valida parámetros de ruta con tipos Haxe.

   ```haxe
   // src/zynvix/router/Router.hx
   macro public static function register(expr:Expr):Expr {
     var fields = Context.getBuildFields();
     for (field in fields) {
       for (meta in field.meta) {
         if (meta.name == ":route") {
           var method = meta.params[0].toString();
           var path = meta.params[1].toString();
           var handler = field.name;
           // Generar código para target (e.g., Express, Spring)
           return macro zynvix.router.adapters.NodeExpress.addRoute($v{method}, $v{path}, $v{handler});
         }
       }
     }
     return macro {};
   }
   ```

3. **Adaptadores por *target*:**
   - Implementa adaptadores para frameworks nativos.
   - Ejemplo para Express (Node.js):

   ```haxe
   // src/zynvix/router/adapters/NodeExpress.hx
   package zynvix.router.adapters;

   class NodeExpress {
     static var app:Dynamic = js.node.Express();

     public static function init():Void {
       // Configurar middleware global
     }

     public static function addRoute(method:String, path:String, handler:Dynamic):Void {
       app.call(method.toLowerCase(), path, function(req:Dynamic, res:Dynamic) {
         var result = handler(req.params, req.query, req.body);
         res.status(result.status).send(result.body);
       });
     }
   }
   ```

4. **Clases `Request` y `Response`:**
   - Unifica manejo de solicitudes y respuestas HTTP.

   ```haxe
   // src/zynvix/router/Response.hx
   package zynvix.router;

   class Response {
     public static function json(data:Dynamic, status:Int = 200):Dynamic {
       return {status: status, body: haxe.Json.stringify(data)};
     }

     public static function html(content:String, status:Int = 200):Dynamic {
       return {status: status, body: content};
     }
   }

   // src/zynvix/router/Request.hx
   class Request {
     public var params:Dynamic;
     public var query:Dynamic;
     public var body:Dynamic;
     public function new(raw:Dynamic) {
       params = raw.params;
       query = raw.query;
       body = raw.body;
     }
   }
   ```

### Mejoras propuestas
- **Middleware:** Implementa un sistema de middleware Haxe para logging, autenticación, etc.
- **GraphQL:** Añade soporte para APIs GraphQL con un adaptador específico.
- **Caching:** Usa un caché para rutas frecuentes.
- **Rate limiting:** Integra límites de solicitudes por *target*.

### Integración con el ecosistema
- **ZynvixORM:** Controladores usan modelos para consultas.
- **ZynvixAuth:** Añade middleware de autenticación.
- **ZynvixTemplates:** Sirve plantillas en endpoints SSR.
- **ZynvixCLI:** Compila rutas con `zynvix compile`.

### Mejores prácticas
- Diseña controladores ligeros, delegando lógica a servicios.
- Usa interfaces Haxe para contratos de API.
- Prueba rutas en todos los *targets* soportados.
- Documenta endpoints con comentarios claros.