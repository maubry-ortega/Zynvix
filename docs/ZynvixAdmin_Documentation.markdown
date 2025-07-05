# Documentación Técnica: ZynvixAdmin

## Propósito
**ZynvixAdmin** genera un panel CRUD automático para modelos, integrado con **ZynvixORM**, **ZynvixRouter**, **ZynvixTemplates**, y **ZynvixAuth**, ofreciendo una interfaz administrativa similar a Django.

## Diseño y objetivos
- **Automatización:** Genera interfaces CRUD sin configuración manual.
- **Personalización:** Permite vistas y acciones personalizadas.
- **Seguridad:** Restringe acceso con **ZynvixAuth**.
- **Integración:** Usa modelos y plantillas del ecosistema.

## Implementación desde cero

### Requisitos
- **Haxe:** Versión 4.3+.
- **Librerías Haxe:** `tink_macro` (macros), `haxe.Template` (renderizado).
- **Dependencias externas:** `bootstrap` (CSS para frontend).

### Estructura del proyecto
```
zynvix/
├── src/zynvix/admin/
│   ├── Admin.hx            # Lógica del panel
│   ├── views/              # Plantillas HTML
│   │   ├── ListView.hx     # Vista de lista
│   │   ├── FormView.hx     # Vista de formulario
```

### Pasos de implementación

1. **Clase `Admin`:**
   - Define una clase para generar interfaces CRUD.

   ```haxe
   // src/zynvix/admin/Admin.hx
   package zynvix.admin;

   import haxe.macro.Expr;
   import haxe.macro.Context;

   class Admin {
     macro public static function register(expr:Expr):Expr {
       var model = Context.getType(expr);
       // Generar rutas: /admin/model/list, /admin/model/create
       return macro {};
     }
   }
   ```

2. **Macros para CRUD:**
   - Procesa `@:admin` para generar endpoints y vistas.

   ```haxe
   // src/zynvix/admin/Admin.hx
   macro public static function register(expr:Expr):Expr {
     var model = Context.getType(expr);
     var modelName = model.toString().split(".").pop().toLowerCase();
     // Generar rutas
     zynvix.router.Router.registerRoute("GET", '/admin/$modelName/list', views.ListView.render.bind(model));
     zynvix.router.Router.registerRoute("GET", '/admin/$modelName/create', views.FormView.render.bind(model));
     return macro {};
   }
   ```

3. **Vistas HTML:**
   - Usa **ZynvixTemplates** para renderizar interfaces.

   ```haxe
   // src/zynvix/admin/views/ListView.hx
   package zynvix.admin.views;

   import zynvix.orm.ZynvixORM;

   @:template
   class ListView {
     public static function render(model:Class<Dynamic>, items:Array<Dynamic>):String {
       var html = '<table class="table"><thead><tr>';
       for (field in model.schema.fields) {
         html += '<th>${field.name}</th>';
       }
       html += '</tr></thead><tbody>';
       for (item in items) {
         html += '<tr>';
         for (field in model.schema.fields) {
           html += '<td>${Reflect.field(item, field.name)}</td>';
         }
         html += '</tr>';
       }
       html += '</tbody></table>';
       return html;
     }
   }
   ```

### Mejoras propuestas
- **Filtros:** Añade filtros dinámicos en vistas de lista.
- **Acciones masivas:** Soporta acciones como eliminar múltiples registros.
- **Customización:** Permite plantillas personalizadas por modelo.
- **Accesibilidad:** Usa ARIA para interfaces accesibles.

### Integración con el ecosistema
- **ZynvixORM:** Usa modelos para datos.
- **ZynvixRouter:** Registra rutas `/admin/*`.
- **ZynvixTemplates:** Renderiza vistas.
- **ZynvixAuth:** Restringe acceso con roles.
- **ZynvixCLI:** Genera scaffolds para el panel.

### Mejores prácticas
- Genera vistas modulares para personalización.
- Prueba el panel en navegadores y *targets*.
- Usa **ZynvixAuth** para seguridad estricta.
- Documenta personalizaciones con ejemplos.