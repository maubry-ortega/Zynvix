# Documentación Técnica de las Herramientas del Ecosistema Zynvix

## Introducción

**Zynvix** es un framework web de pila completa construido sobre Haxe, diseñado para unificar el desarrollo web en múltiples plataformas (Node.js, Java, PHP, Python, C#) y frontend (JavaScript/TypeScript). Al instalar **Zynvix** con `haxelib install zynvix`, se incluyen todas las herramientas del ecosistema, que trabajan juntas para ofrecer una experiencia de desarrollo fluida, consistente y escalable. Esta documentación detalla la implementación técnica y el funcionamiento de cada herramienta, enfocándose en su diseño, integración y mejores prácticas para desarrolladores que deseen contribuir o personalizar el ecosistema.

### Filosofía del Ecosistema
- **Unificación:** Todas las herramientas comparten un código base en Haxe, compilando a múltiples targets para garantizar consistencia.
- **Integración:** Las herramientas están diseñadas para interactuar sin fricciones, formando un ecosistema cohesivo.
- **Simplicidad:** Inspiradas en la facilidad de Django, pero potenciadas por el tipado estático de Haxe.
- **Flexibilidad:** Optimizadas para entornos heterogéneos, desde prototipos hasta aplicaciones empresariales.

### Instalación
Al instalar **Zynvix**, todas las herramientas se configuran automáticamente:
```bash
haxelib install zynvix
zynvix init miapp
```
Esto crea un proyecto con todas las herramientas preconfiguradas en `zynvix.json`.

## Herramienta 1: ZynvixORM (Object-Relational Mapping)

### Propósito
**ZynvixORM** es el sistema de mapeo objeto-relacional que permite definir modelos de datos en Haxe, generando código optimizado para bases de datos (PostgreSQL, MySQL, MongoDB) y targets (Node.js, Java, etc.).

### Implementación Técnica
- **Base:** Clases Haxe con anotaciones (`@:model`, `@:field`) procesadas por macros Haxe.
- **Macros:** Generan código específico para cada target (e.g., JDBC para Java, Sequelize para Node.js).
- **Soporte de bases de datos:** Usa conectores nativos por target, con un núcleo abstracto en Haxe para consultas unificadas.
- **Migraciones:** Un sistema basado en diffs de esquemas genera scripts SQL/NoSQL para cada base de datos.

#### Código de ejemplo (definición de modelo)
```haxe
@:model
class User {
  @:field(id, primaryKey=true, autoIncrement=true)
  public var id: Int;
  @:field(username, unique=true, maxLength=50)
  public var username: String;
  @:field(email, unique=true)
  public var email: String;
}
```

#### Implementación del núcleo
1. **Definición de modelos:**
   - Usa una macro Haxe para parsear anotaciones (`@:field`) y generar metadatos.
   - Ejemplo: `@:field(username, unique=true)` crea índices únicos en la base de datos.
2. **Generación de código:**
   - Macro compila a conectores específicos (e.g., `pg` para Node.js, `java.sql` para Java).
   - Usa un AST (Abstract Syntax Tree) para generar consultas tipo-seguras.
3. **Migraciones:**
   - Compara modelos actuales con el estado previo (almacenado en `zynvix_migrations.json`).
   - Genera scripts SQL/NoSQL ejecutados con `zynvix migrate`.

#### Funcionalidad
- **Consultas:** `ZynvixORM.find(User, 1)`, `ZynvixORM.filter(User, u -> u.username == "alice")`.
- **Relaciones:** Soporta uno-a-muchos y muchos-a-muchos mediante `@:relation`.
- **Validaciones:** Usa el sistema de tipos de Haxe para validar datos en tiempo de compilación.

**Mejores prácticas para desarrollo:**
- Implementa conectores modulares para nuevos targets (e.g., añadir soporte para SQLite).
- Usa macros para minimizar código repetitivo.
- Prueba migraciones en entornos de desarrollo antes de producción.

## Herramienta 2: ZynvixRouter (Sistema de Ruteo)

### Propósito
**ZynvixRouter** mapea URLs a controladores, generando código para frameworks web nativos en cada target (e.g., Express para Node.js, Spring para Java).

### Implementación Técnica
- **Base:** Clases Haxe con anotaciones (`@:controller`, `@:route`) procesadas por macros.
- **Macros:** Generan código de ruteo específico (e.g., `app.get()` para Express, `@GetMapping` para Spring).
- **Soporte HTTP:** Maneja GET, POST, PUT, DELETE, con parámetros de ruta y cuerpo.

#### Código de ejemplo
```haxe
@:controller
class UserController {
  @:route("GET", "/users/:id")
  public static function getUser(id: Int): Response {
    var user = ZynvixORM.find(User, id);
    return Response.json(user);
  }
}
```

#### Implementación del núcleo
1. **Definición de rutas:**
   - Macro parsea `@:route` para extraer método HTTP y patrón de URL.
   - Valida parámetros con el sistema de tipos de Haxe.
2. **Generación de código:**
   - Compila rutas a frameworks nativos (e.g., `express.Router` para Node.js).
   - Usa un middleware Haxe para manejar solicitudes/respuestas de forma unificada.
3. **Integración con ZynvixORM:**
   - Controladores acceden directamente a modelos para consultas.

#### Funcionalidad
- **Parámetros dinámicos:** Soporta rutas como `/users/:id`.
- **Respuestas:** Clase `Response` unifica JSON, HTML y errores HTTP.
- **Escalabilidad:** Soporta rutas para microservicios con `zynvix compile --service`.

**Mejores prácticas para desarrollo:**
- Mantén controladores ligeros, delegando lógica compleja a servicios.
- Usa interfaces Haxe para definir contratos de API.
- Prueba rutas en múltiples targets para garantizar consistencia.

## Herramienta 3: ZynvixTemplates (Sistema de Plantillas)

### Propósito
**ZynvixTemplates** permite crear plantillas para renderizado en servidor (SSR) y cliente (CSR), compiladas a JavaScript/TypeScript, compartiendo modelos con el backend.

### Implementación Técnica
- **Base:** Clases Haxe con anotaciones (`@:template`, `@:component`) procesadas por macros.
- **Macros:** Generan código JavaScript para renderizado, con soporte para React/Vue si se configura.
- **Modelos compartidos:** Usa los mismos modelos de ZynvixORM para consistencia.

#### Código de ejemplo
```haxe
@:template
class UserProfile {
  public static function render(user: User): String {
    return '<div>
      <h1>Bienvenido, ${user.username}</h1>
      <p>Email: ${user.email}</p>
    </div>';
  }
}
```

#### Implementación del núcleo
1. **Definición de plantillas:**
   - Macro parsea `@:template` para generar funciones de renderizado.
   - Soporta interpolación de variables y lógica condicional.
2. **Generación de código:**
   - Compila a JavaScript puro o frameworks como React (`React.createElement`).
   - Genera esquemas TypeScript para validaciones en frontend.
3. **Integración con ZynvixORM:**
   - Modelos definidos con `@:model` son accesibles en plantillas.

#### Funcionalidad
- **SSR/CSR:** Compila para renderizado en servidor o cliente.
- **Componentes:** Soporta componentes reutilizables con `@:component`.
- **Validaciones:** Usa tipos Haxe para validar datos en frontend.

**Mejores prácticas para desarrollo:**
- Diseña plantillas modulares para reutilización.
- Prueba SSR y CSR en entornos de desarrollo.
- Integra con bundlers como Vite para flujos frontend modernos.

## Herramienta 4: ZynvixCLI (Interfaz de Línea de Comandos)

### Propósito
**ZynvixCLI** automatiza la creación, compilación y gestión de proyectos, proporcionando una experiencia de desarrollo fluida.

### Implementación Técnica
- **Base:** Script Haxe compilado a un ejecutable independiente usando `haxe --main CLI --neko`.
- **Comandos:** Procesados con una librería de parsing de argumentos (e.g., `tink_cli`).
- **Integración:** Interactúa con ZynvixORM, ZynvixRouter y ZynvixTemplates.

#### Comandos principales
```bash
zynvix init <proyecto>        # Crea un nuevo proyecto
zynvix compile --target <target>  # Compila a Node.js, Java, etc.
zynvix migrate                # Aplica migraciones de base de datos
zynvix test                   # Ejecuta pruebas unitarias
zynvix generate model <nombre>  # Genera un modelo base
```

#### Implementación del núcleo
1. **Estructura de comandos:**
   - Usa un sistema de plugins para añadir comandos (e.g., `generate`, `compile`).
   - Macro valida configuraciones en `zynvix.json`.
2. **Compilación:**
   - Invoca el compilador Haxe con flags específicos por target.
   - Genera configuraciones para frameworks nativos (e.g., `package.json` para Node.js).
3. **Integración:**
   - Lee `zynvix.json` para configuraciones de base de datos y targets.
   - Ejecuta scripts de migración generados por ZynvixORM.

#### Funcionalidad
- **Automatización:** Genera estructuras de proyecto, modelos y controladores.
- **Flexibilidad:** Soporta múltiples targets con un solo comando.
- **Extensibilidad:** Permite plugins para comandos personalizados.

**Mejores prácticas para desarrollo:**
- Mantén comandos modulares y documentados.
- Valida entradas de usuario para evitar errores.
- Prueba la CLI en múltiples sistemas operativos.

## Herramienta 5: ZynvixAuth (Autenticación y Autorización)

### Propósito
**ZynvixAuth** proporciona autenticación y autorización seguras, integradas con ZynvixORM y ZynvixRouter.

### Implementación Técnica
- **Base:** Clases Haxe con APIs para autenticación (JWT, OAuth) y permisos.
- **Macros:** Generan código para bibliotecas nativas (e.g., `jsonwebtoken` para Node.js, Spring Security para Java).
- **Seguridad:** Usa el tipado estático de Haxe para validar tokens y permisos.

#### Código de ejemplo
```haxe
@:controller
class AuthController {
  @:route("POST", "/login")
  public static function login(data: {username: String, password: String}): Response {
    var user = ZynvixAuth.authenticate(data.username, data.password);
    return Response.json({token: user.token});
  }
}
```

#### Implementación del núcleo
1. **Autenticación:**
   - Implementa un servicio Haxe que valida credenciales contra ZynvixORM.
   - Genera tokens JWT con bibliotecas nativas por target.
2. **Autorización:**
   - Usa un sistema de roles definido en modelos (e.g., `@:role(admin)`).
   - Macro genera middleware para proteger rutas.
3. **Seguridad:**
   - Protege contra inyección SQL y XSS mediante validaciones de tipos.
   - Implementa rotación de tokens y sesiones seguras.

#### Funcionalidad
- **JWT/OAuth:** Soporte para autenticación basada en tokens.
- **Roles:** Permisos granulares para endpoints y acciones.
- **Integración:** Funciona con ZynvixRouter para proteger rutas.

**Mejores prácticas para desarrollo:**
- Usa bibliotecas seguras para hashing (e.g., bcrypt).
- Valida tokens en tiempo de compilación cuando sea posible.
- Prueba autenticación en entornos multi-target.

## Herramienta 6: ZynvixAdmin (Panel de Administración)

### Propósito
**ZynvixAdmin** genera un panel CRUD automático para modelos, similar al admin de Django, integrado con ZynvixORM y ZynvixTemplates.

### Implementación Técnica
- **Base:** Clases Haxe con anotaciones (`@:admin`) que generan interfaces CRUD.
- **Macros:** Compilan a HTML/JavaScript para frontend y lógica backend.
- **Integración:** Usa ZynvixORM para datos y ZynvixRouter para rutas.

#### Código de ejemplo
```haxe
@:admin
class UserAdmin {
  public static function customize() {
    // Añadir campos o acciones personalizadas
  }
}
```

#### Implementación del núcleo
1. **Generación de CRUD:**
   - Macro parsea `@:admin` y modelos para generar interfaces.
   - Crea endpoints automáticos (e.g., `/admin/users`).
2. **Frontend:**
   - Compila a HTML/JavaScript, con soporte opcional para frameworks como React.
   - Usa ZynvixTemplates para renderizado.
3. **Seguridad:**
   - Integra con ZynvixAuth para restringir acceso por roles.

#### Funcionalidad
- **CRUD automático:** Interfaces para crear, leer, actualizar y eliminar.
- **Personalización:** Permite vistas y acciones personalizadas.
- **Multiplataforma:** Funciona en todos los targets backend y frontend.

**Mejores prácticas para desarrollo:**
- Implementa plantillas modulares para el panel.
- Prueba el panel en navegadores y targets diferentes.
- Usa permisos estrictos para proteger el acceso.

## Integración del Ecosistema

- **Unificación:** Todas las herramientas usan el mismo código base Haxe, compilado a múltiples targets.
- **Configuración:** `zynvix.json` centraliza configuraciones de base de datos, targets y plugins.
- **Flujo de trabajo:**
  1. Crea un proyecto con `ZynvixCLI`.
  2. Define modelos con `ZynvixORM`.
  3. Crea controladores con `ZynvixRouter`.
  4. Diseña plantillas con `ZynvixTemplates`.
  5. Añade autenticación con `ZynvixAuth`.
  6. Personaliza el panel con `ZynvixAdmin`.

## Mejores prácticas generales

1. **Modularidad:** Diseña cada herramienta como un módulo independiente, pero integrable.
2. **Macros Haxe:** Usa macros para reducir código repetitivo y garantizar consistencia.
3. **Pruebas:** Escribe pruebas unitarias para cada herramienta, usando `zynvix test`.
4. **Documentación:** Incluye comentarios en el código y actualiza esta documentación.
5. **Multi-target:** Valida la compatibilidad de cada herramienta en todos los targets soportados.

## Contribuir

Contribuye al ecosistema **Zynvix** en [github.com/zynvix/zynvix](https://github.com/zynvix/zynvix). Crea plugins para nuevas bases de datos, targets o funcionalidades, y únete a la comunidad en [discord.gg/zynvix](https://discord.gg/zynvix).

## Autor

🧙 **VolleyDevByMaubry**  
Pionero en la convergencia del desarrollo web, **Zynvix** es una visión transformadora que fusiona la precisión de WebAssembly, la inteligencia de la IA y los paradigmas de la computación moderna para construir un ecosistema unificado, fluido y sin fronteras.

## Licencia

**Zynvix** está licenciado bajo la Licencia MIT. Consulta [LICENSE](https://zynvix.dev/license) para más detalles.