# Documentación Técnica: ZynvixTemplates

## Propósito
**ZynvixTemplates** es el sistema de plantillas de **Zynvix**, diseñado para renderizado en servidor (SSR) y cliente (CSR), compilado a JavaScript/TypeScript. Comparte modelos con **ZynvixORM** y se integra con **ZynvixRouter** para servir contenido dinámico.

## Diseño y objetivos
- **Unificación:** Usa modelos de **ZynvixORM** para consistencia.
- **Flexibilidad:** Soporta SSR, CSR y frameworks como React/Vue.
- **Tipo-seguridad:** Valida datos de renderizado en tiempo de compilación.
- **Integración:** Conecta con **ZynvixRouter** y **ZynvixAdmin**.

## Implementación desde cero

### Requisitos
- **Haxe:** Versión 4.3+.
- **Librerías Haxe:** `tink_macro` (macros), `haxe.Template` (renderizado).
- **Dependencias por *target*:** `react`, `vue` (opcional para frontend).

### Estructura del proyecto
```
zynvix/
├── src/zynvix/templates/
│   ├── Template.hx         # Clase base para plantillas
│   ├── Component.hx        # Componentes reutilizables
│   ├── renderers/          # Renderizadores por target
│   │   ├── JsRenderer.hx   # Renderizado JavaScript
│   │   ├── ReactRenderer.hx # Renderizado React
```

### Pasos de implementación

1. **Definir la clase `Template`:**
   - Crea una clase para manejar plantillas con anotaciones (`@:template`).

   ```haxe
   // src/zynvix/templates/Template.hx
   package zynvix.templates;

   import haxe.macro.Expr;
   import haxe.macro.Context;

   class Template {
     macro public static function render(expr:Expr):Expr {
       var code = Context.getBuildFields();
       // Generar función de renderizado
       return macro {};
     }
   }
   ```

2. **Macros para plantillas:**
   - Procesa `@:template` para generar funciones de renderizado.
   - Soporta interpolación y lógica condicional.

   ```haxe
   // src/zynvix/templates/Template.hx
   macro public static function render(expr:Expr):Expr {
     var code = Context.getBuildFields();
     for (field in code) {
       if (field.name == "render") {
         var body = field.expr;
         // Convertir a JavaScript o HTML
         return macro function(data:Dynamic):String {
           return haxe.Template.execute($body, data);
         };
       }
     }
     return macro {};
   }
   ```

3. **Renderizadores por *target*:**
   - Genera código para CSR/SSR.
   - Ejemplo para JavaScript:

   ```haxe
   // src/zynvix/templates/renderers/JsRenderer.hx
   package zynvix.templates.renderers;

   class JsRenderer {
     public static function render(template:String, data:Dynamic):String {
       return haxe.Template.execute(template, data);
     }
   }
   ```

4. **Componentes reutilizables:**
   - Implementa `@:component` para componentes al estilo React.

   ```haxe
   // src/zynvix/templates/Component.hx
   package zynvix.templates;

   @:component
   class UserCard {
     public static function render(user:Dynamic):String {
       return '<div class="user-card">${user.username}</div>';
     }
   }
   ```

### Mejoras propuestas
- **Directivas:** Añade directivas personalizadas (e.g., `@if`, `@loop`) para lógica avanzada.
- **Integración con bundlers:** Soporta Vite/Webpack para CSR.
- **Caching:** Implementa caché para plantillas compiladas.
- **TypeScript:** Genera definiciones TypeScript para componentes.

### Integración con el ecosistema
- **ZynvixORM:** Comparte modelos para renderizado.
- **ZynvixRouter:** Sirve plantillas en endpoints.
- **ZynvixAdmin:** Usa plantillas para interfaces CRUD.
- **ZynvixCLI:** Compila plantillas con `zynvix compile`.

### Mejores prácticas
- Diseña plantillas modulares y reutilizables.
- Valida datos de renderizado con tipos Haxe.
- Prueba SSR y CSR en entornos de desarrollo.
- Documenta componentes con ejemplos.