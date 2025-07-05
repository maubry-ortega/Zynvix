# Documentación del Framework Zynvix

## Introducción

Bienvenido a **Zynvix**, el framework web de próxima generación que redefine el desarrollo multiplataforma. Construido sobre Haxe, **Zynvix** permite escribir un solo código base que se compila sin esfuerzo a múltiples entornos backend (Node.js, Java, PHP, Python, C#) y frontend (JavaScript/TypeScript), garantizando consistencia, seguridad de tipos y una flexibilidad sin precedentes. Ya sea que estés creando un prototipo rápido o una aplicación empresarial escalable, **Zynvix** te empodera para desarrollar aplicaciones web robustas con facilidad y elegancia.

### Filosofía
- **Unificación:** Escribe un solo código, despliega en cualquier plataforma.
- **Consistencia:** Comparte modelos, validaciones y lógica entre frontend y backend.
- **Flexibilidad:** Optimiza para diferentes entornos sin reescribir código.
- **Simplicidad:** Inspirado en la facilidad de uso de Django, potenciado por la seguridad de tipos de Haxe.
- **Escalabilidad:** Diseñado para startups y empresas con soporte para microservicios y flujos de trabajo modernos.

## Instalación

### Requisitos previos
- **Haxe:** Versión 4.3 o superior (descarga desde [haxe.org](https://haxe.org)).
- **Node.js:** Para compilación al target Node.js (opcional, según el target).
- **Java JDK:** Para compilación al target Java (opcional).
- **Python, PHP o .NET:** Según los targets backend deseados.
- **Git:** Para clonar el repositorio de Zynvix.

### Pasos de instalación
1. **Instalar Haxe:**
   ```bash
   # En macOS/Linux
   brew install haxe
   # En Windows, descargar desde haxe.org
   ```

2. **Instalar la CLI de Zynvix:**
   ```bash
   haxelib install zynvix
   ```

3. **Crear un nuevo proyecto:**
   ```bash
   zynvix init miapp
   cd miapp
   ```

4. **Compilar para un target:**
   ```bash
   zynvix compile --target nodejs
   # O: zynvix compile --target java
   ```

5. **Ejecutar la aplicación:**
   ```bash
   node build/main.js  # Para target Node.js
   # O: java -jar build/main.jar  # Para target Java
   ```

## Estructura del proyecto

Un proyecto **Zynvix** sigue una estructura clara y modular:

```
miapp/
├── src/
│   ├── models/         # Modelos de datos (compartidos entre frontend y backend)
│   ├── controllers/    # Controladores para manejar solicitudes
│   ├── templates/      # Plantillas para frontend
│   ├── config.hx       # Configuración del proyecto
├── zynvix.json         # Configuraciones (base de datos, targets)
├── build/              # Salida compilada
└── tests/              # Pruebas unitarias
```

## Componentes principales

### 1. ZynvixORM (Mapeo Objeto-Relacional)
**ZynvixORM** es el núcleo del framework, permitiendo definir modelos de datos en Haxe que se compilan a interacciones con bases de datos en múltiples targets (PostgreSQL, MongoDB, etc.).

#### Definir un modelo
Los modelos se definen con clases Haxe y anotaciones.

```haxe
@:model
class User {
  @:field(id, primaryKey=true, autoIncrement=true)
  public var id: Int;
  @:field(username, unique=true, maxLength=50)
  public var username: String;
  @:field(email, unique=true)
  public var email: String;
  @:field(createdAt, default="CURRENT_TIMESTAMP")
  public var createdAt: Date;
}
```

#### Funcionalidades soportadas
- **Relaciones:** Uno-a-muchos, muchos-a-muchos.
- **Migraciones:** Actualizaciones automáticas de esquemas (`zynvix migrate`).
- **Consultas:** Consultas seguras con validación en tiempo de compilación.
- **Targets:** Genera código optimizado para PostgreSQL, MySQL, MongoDB, etc.

#### Ejemplo de consulta
```haxe
var user = ZynvixORM.find(User, 1);
var users = ZynvixORM.filter(User, u -> u.username == "alice");
```

**Mejores prácticas:**
- Usa nombres de campos descriptivos y anotaciones claras.
- Aprovecha el sistema de tipos de Haxe para garantizar integridad de datos.
- Ejecuta migraciones tras cambios en modelos: `zynvix migrate`.

### 2. Ruteo y controladores
**Zynvix** ofrece un sistema de ruteo para mapear URLs a controladores, soportando APIs RESTful y endpoints personalizados.

#### Definir un controlador
```haxe
@:controller
class UserController {
  @:route("GET", "/users/:id")
  public static function getUser(id: Int): Response {
    var user = ZynvixORM.find(User, id);
    return Response.json(user);
  }

  @:route("POST", "/users")
  public static function createUser(data: {username: String, email: String}): Response {
    var user = ZynvixORM.create(User, data);
    return Response.json(user, 201);
  }
}
```

#### Funcionalidades soportadas
- **Métodos HTTP:** GET, POST, PUT, DELETE, etc.
- **Parámetros:** Parámetros de ruta, consulta y cuerpo de solicitud.
- **Targets:** Compila a Express (Node.js), Spring (Java), Flask (Python), etc.

**Mejores prácticas:**
- Mantén los controladores ligeros, delegando lógica a servicios o modelos.
- Usa parámetros con tipos seguros para evitar errores en tiempo de ejecución.
- Organiza las rutas lógicamente (e.g., `/users/*` para endpoints de usuarios).

### 3. Plantillas (Frontend)
**Zynvix** incluye un sistema de plantillas para renderizado en servidor (SSR) y cliente (CSR), compilado a JavaScript/TypeScript.

#### Definir una plantilla
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

#### Funcionalidades soportadas
- **Modelos compartidos:** Usa el mismo modelo `User` para consultas backend y renderizado frontend.
- **SSR/CSR:** Compila plantillas para uso en servidor o cliente.
- **Integración:** Compatibilidad opcional con React o Vue.

**Mejores prácticas:**
- Mantén las plantillas modulares y reutilizables.
- Usa modelos compartidos para garantizar consistencia.
- Prueba las plantillas en modos SSR y CSR.

### 4. Zynvix CLI
La **Zynvix CLI** simplifica el desarrollo con comandos para configuración, compilación y gestión.

#### Comandos principales
- `zynvix init <proyecto>`: Crea un nuevo proyecto.
- `zynvix compile --target <target>`: Compila a Node.js, Java, etc.
- `zynvix migrate`: Aplica migraciones de base de datos.
- `zynvix test`: Ejecuta pruebas unitarias.
- `zynvix generate model <nombre>`: Genera un modelo base.

**Mejores prácticas:**
- Usa la CLI para automatizar tareas repetitivas.
- Especifica el target explícitamente (e.g., `--target nodejs`).
- Mantén `zynvix.json` actualizado con configuraciones.

### 5. Autenticación y autorización
**Zynvix** proporciona módulos integrados para gestión de usuarios y seguridad.

#### Funcionalidades
- **JWT/OAuth:** Autenticación basada en tokens.
- **Acceso basado en roles:** Permisos ligados a roles de usuario.
- **Seguridad:** Protección contra inyección SQL, XSS y CSRF.

#### Ejemplo
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

**Mejores prácticas:**
- Usa hash seguro para contraseñas (e.g., bcrypt).
- Valida todas las entradas con el sistema de tipos de Haxe.
- Rota tokens JWT regularmente.

### 6. Panel de administración
**Zynvix** genera un panel CRUD automático para modelos, similar al admin de Django.

#### Funcionalidades
- **CRUD automático:** Interfaces para crear, leer, actualizar y eliminar registros.
- **Personalizable:** Extiende con vistas y permisos personalizados.
- **Multiplataforma:** Compila a HTML/JavaScript para frontend, ejecuta lógica en backend.

#### Ejemplo
```haxe
@:admin
class UserAdmin {
  public static function customize() {
    // Añadir campos o acciones personalizadas
  }
}
```

**Mejores prácticas:**
- Restringe el acceso al panel con permisos basados en roles.
- Personaliza el panel para casos de uso específicos.
- Prueba el panel en múltiples navegadores.

## Mejores prácticas

1. **Organización del código:**
   - Agrupa modelos, controladores y plantillas en carpetas separadas.
   - Usa nombres descriptivos (e.g., `UserModel`, `UserController`).

2. **Seguridad de tipos:**
   - Aprovecha el tipado estático de Haxe para detectar errores en tiempo de compilación.
   - Define interfaces estrictas para entradas y salidas de API.

3. **Desarrollo multiplataforma:**
   - Prueba la compilación en múltiples targets desde el inicio.
   - Usa optimizaciones específicas por target solo cuando sea necesario.

4. **Pruebas:**
   - Escribe pruebas unitarias para modelos, controladores y plantillas.
   - Usa `zynvix test` para automatizar pruebas en todos los targets.

5. **Documentación:**
   - Documenta modelos y controladores con comentarios en línea.
   - Mantén un `README.md` en tu proyecto para colaboración en equipo.

## Tutorial rápido: 5 minutos para empezar

### Paso 1: Crear un proyecto
```bash
zynvix init miapp
cd miapp
```

### Paso 2: Definir un modelo
Edita `src/models/User.hx`:
```haxe
@:model
class User {
  @:field(id, primaryKey=true, autoIncrement=true)
  public var id: Int;
  @:field(username, unique=true, maxLength=50)
  public var username: String;
}
```

### Paso 3: Definir un controlador
Edita `src/controllers/UserController.hx`:
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

### Paso 4: Configurar la base de datos
Edita `zynvix.json`:
```json
{
  "database": {
    "type": "postgresql",
    "connection": "host=localhost user=admin password=secret dbname=miapp"
  },
  "targets": ["nodejs", "java"]
}
```

### Paso 5: Ejecutar migraciones
```bash
zynvix migrate
```

### Paso 6: Compilar y ejecutar
```bash
zynvix compile --target nodejs
node build/main.js
```

Visita `http://localhost:3000/users/1` para ver el resultado.

## Funcionalidades avanzadas

### Microservicios
**Zynvix** soporta microservicios compilando controladores como servicios independientes.
```bash
zynvix compile --target nodejs --service UserController
```

### Componentes frontend
Crea componentes reutilizables para aplicaciones SPA:
```haxe
@:component
class UserCard {
  public static function render(user: User): String {
    return '<div class="user-card">${user.username}</div>';
  }
}
```

### Despliegue
- **Docker:** Genera Dockerfiles con `zynvix generate docker`.
- **CI/CD:** Integra con GitHub Actions o Jenkins para builds automáticos.
- **Nube:** Despliega en AWS, Azure o GCP con configuraciones por target.

## Comunidad y soporte

- **GitHub:** [github.com/zynvix/zynvix](https://github.com/zynvix/zynvix)
- **Discord:** Únete a nuestra comunidad en [discord.gg/zynvix](https://discord.gg/zynvix)
- **Documentación:** [zynvix.dev/docs](https://zynvix.dev/docs)
- **Issues:** Reporta errores o solicita funcionalidades en GitHub.

## Contribuir

¡Te invitamos a contribuir! Haz un fork del repositorio, envía pull requests y únete a la comunidad **Zynvix** para dar forma al futuro del desarrollo web.

## Autor

🧙 **VolleyDevByMaubry**  
Forjando el futuro del desarrollo web con **Zynvix**, un framework que une la potencia de WebAssembly, la inteligencia de la IA y los principios de la computación moderna para crear aplicaciones sin límites, fluidas y visionarias.

## Licencia

**Zynvix** está licenciado bajo la Licencia MIT. Consulta [LICENSE](https://zynvix.dev/license) para más detalles.