# Documentación Técnica: ZynvixAuth

## Propósito
**ZynvixAuth** proporciona autenticación y autorización seguras, integradas con **ZynvixORM** para gestión de usuarios y **ZynvixRouter** para proteger rutas, soportando JWT, OAuth y permisos basados en roles.

## Diseño y objetivos
- **Seguridad:** Implementa estándares como JWT y OAuth.
- **Tipo-seguridad:** Valida credenciales y permisos en tiempo de compilación.
- **Flexibilidad:** Soporta múltiples *targets* y métodos de autenticación.
- **Integración:** Conecta con **ZynvixRouter** y **ZynvixAdmin**.

## Implementación desde cero

### Requisitos
- **Haxe:** Versión 4.3+.
- **Librerías Haxe:** `tink_crypto` (hashing), `tink_json` (serialización).
- **Dependencias por *target*:** `jsonwebtoken` (Node.js), `spring-security` (Java), `firebase/php-jwt` (PHP).

### Estructura del proyecto
```
zynvix/
├── src/zynvix/auth/
│   ├── Auth.hx             # Lógica de autenticación
│   ├── Role.hx             # Gestión de permisos
│   ├── adapters/           # Adaptadores por target
│   │   ├── NodeJwt.hx      # JWT para Node.js
│   │   ├── JavaSpring.hx   # Spring Security para Java
```

### Pasos de implementación

1. **Clase `Auth`:**
   - Define métodos para autenticación y generación de tokens.

   ```haxe
   // src/zynvix/auth/Auth.hx
   package zynvix.auth;

   import zynvix.orm.ZynvixORM;

   class Auth {
     public static function authenticate(username:String, password:String):Dynamic {
       var user = ZynvixORM.find(User, u -> u.username == username);
       if (user == null || !tink.Crypto.verify(password, user.password)) {
         throw "Invalid credentials";
       }
       return {token: adapters.NodeJwt.generateToken(user)};
     }
   }
   ```

2. **Generación de tokens:**
   - Usa bibliotecas nativas por *target*.

   ```haxe
   // src/zynvix/auth/adapters/NodeJwt.hx
   package zynvix.auth.adapters;

   class NodeJwt {
     public static function generateToken(user:Dynamic):String {
       return js.node.JsonWebToken.sign({id: user.id, role: user.role}, "secret", {expiresIn: "1h"});
     }
     public static function verifyToken(token:String):Dynamic {
       return js.node.JsonWebToken.verify(token, "secret");
     }
   }
   ```

3. **Permisos basados en roles:**
   - Implementa un sistema de roles con middleware.

   ```haxe
   // src/zynvix/auth/Role.hx
   package zynvix.auth;

   class Role {
     public static function restrict(role:String, handler:Dynamic):Dynamic {
       return function(req:Dynamic, res:Dynamic) {
         var token = req.headers.authorization;
         var user = adapters.NodeJwt.verifyToken(token);
         if (user.role == role) handler(req, res);
         else res.status(403).send("Forbidden");
       }
     }
   }
   ```

### Mejoras propuestas
- **OAuth:** Añade soporte para proveedores como Google, GitHub.
- **MFA:** Implementa autenticación multifactor.
- **Token refresh:** Soporta tokens de refresco.
- **Audit logs:** Registra intentos de autenticación.

### Integración con el ecosistema
- **ZynvixORM:** Usa modelos de usuario.
- **ZynvixRouter:** Añade middleware de autenticación.
- **ZynvixAdmin:** Restringe acceso al panel.
- **ZynvixCLI:** Genera scaffolds de autenticación.

### Mejores prácticas
- Usa hashing seguro (e.g., bcrypt).
- Valida tokens en tiempo de compilación.
- Prueba autenticación en todos los *targets*.
- Documenta flujos de autenticación.