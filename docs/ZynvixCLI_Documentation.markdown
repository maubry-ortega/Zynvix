# Documentación Técnica: ZynvixCLI

## Propósito
**ZynvixCLI** es la interfaz de línea de comandos de **Zynvix**, diseñada para automatizar la creación, compilación y gestión de proyectos, integrándose con todas las herramientas del ecosistema.

## Diseño y objetivos
- **Automatización:** Simplifica tareas repetitivas como inicialización y compilación.
- **Flexibilidad:** Soporta múltiples *targets* y configuraciones.
- **Extensibilidad:** Permite plugins para comandos personalizados.
- **Integración:** Conecta con **ZynvixORM**, **ZynvixRouter**, **ZynvixTemplates**, **ZynvixAuth**, y **ZynvixAdmin**.

## Implementación desde cero

### Requisitos
- **Haxe:** Versión 4.3+.
- **Librerías Haxe:** `tink_cli` (parsing de comandos), `haxe.io` (manejo de archivos).
- **Dependencias externas:** Compilador Haxe para generar ejecutables.

### Estructura del proyecto
```
zynvix/
├── src/zynvix/cli/
│   ├── CLI.hx              # Punto de entrada
│   ├── commands/           # Comandos específicos
│   │   ├── Init.hx         # Inicialización de proyectos
│   │   ├── Compile.hx      # Compilación por target
│   │   ├── Migrate.hx      # Migraciones
│   │   ├── Generate.hx     # Generación de scaffolds
```

### Pasos de implementación

1. **Punto de entrada:**
   - Crea un script Haxe compilado a Neko o Node.js.

   ```haxe
   // src/zynvix/cli/CLI.hx
   package zynvix.cli;

   import tink.cli.*;

   class CLI {
     static function main() {
       Cli.process(Sys.args(), new Commands()).run();
     }
   }
   ```

2. **Definir comandos:**
   - Usa `tink_cli` para comandos como `init`, `compile`, `migrate`.

   ```haxe
   // src/zynvix/cli/commands/Init.hx
   package zynvix.cli.commands;

   class Init {
     public static function run(projectName:String):Void {
       sys.FileSystem.createDirectory(projectName);
       sys.io.File.saveContent('$projectName/zynvix.json', haxe.Json.stringify({
         database: {type: "postgresql", connection: ""},
         targets: ["nodejs"]
       }));
       // Crear src/, models/, controllers/, templates/
     }
   }
   ```

3. **Compilación por *target*:**
   - Invoca el compilador Haxe con flags específicos.

   ```haxe
   // src/zynvix/cli/commands/Compile.hx
   package zynvix.cli.commands;

   class Compile {
     public static function run(target:String):Void {
       var flags = ['--main', 'Main', '--$target', 'build'];
       Sys.command('haxe', flags);
     }
   }
   ```

4. **Gestión de configuraciones:**
   - Lee `zynvix.json` para bases de datos y *targets*.

   ```haxe
   // src/zynvix/cli/Commands.hx
   package zynvix.cli;

   import tink.cli.*;

   class Commands {
     @:command
     public function init(project:String) Init.run(project);

     @:command
     public function compile(target:String) Compile.run(target);

     @:command
     public function migrate() {
       zynvix.orm.Migration.run();
     }
   }
   ```

### Mejoras propuestas
- **Plugins:** Implementa un sistema de plugins para comandos personalizados.
- **Validación:** Añade validación estricta de argumentos.
- **Progresión:** Muestra barras de progreso para compilaciones largas.
- **Logs:** Usa un sistema de logging configurable.

### Integración con el ecosistema
- **ZynvixORM:** Ejecuta migraciones.
- **ZynvixRouter/Templates:** Compila código.
- **ZynvixAuth/Admin:** Genera scaffolds.

### Mejores prácticas
- Diseña comandos modulares.
- Valida entradas de usuario.
- Prueba la CLI en Linux, macOS y Windows.
- Documenta cada comando con ayuda integrada (`zynvix --help`).