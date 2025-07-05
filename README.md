# ZynvixORM

**ZynvixORM** es el motor ORM profesional del ecosistema **Zynvix**, creado en Haxe puro y compilado a Node.js. Permite definir modelos con macros, migrar bases de datos PostgreSQL y hacer consultas desde Haxe sin necesidad de SQL manual.

> _"Las estructuras no son límites, sino el contorno de nuestras ideas en expansión."_  
> — 🧙 VolleyDevByMaubry

---

## 🚀 Características

- 🔌 Conexión dinámica a PostgreSQL desde Node.js
- 🧠 Esquema con macros `@:field` y `@:model`
- ⚒️ Migración automática de modelos a tablas
- 📥 Soporte para creación (`insert`) y búsqueda (`find`)
- 🛡 Tipado estático desde Haxe → PostgreSQL

---

## 📦 Requisitos

- [Haxe](https://haxe.org/) 4.3 o superior
- [Node.js](https://nodejs.org/) 18+
- PostgreSQL
- Librería JS `pg` (para conexión):

```bash
npm install pg
```

---

## 🧪 Ejemplo de uso

```javascript
ZynvixORM.zynInit({
  host: "localhost",
  user: "zynvix",
  password: "devpass",
  dbname: "zynvixdb",
  port: 5432
});

ZynMigration.zynRun();

ZynQuery.zynCreate(User, {
  name: "alice",
  email: "alice@example.com",
  password: "1234"
}, function(user) {
  trace("✅ Usuario creado: " + user.name);

  ZynQuery.zynFind(User, user.id, function(found) {
    trace(found != null ? "🔍 Encontrado: " + found.name : "❌ No encontrado");
  });
});
```

---

## 🧙 Autor

**VolleyDevByMaubry**  
_"Las estructuras no son límites, sino el contorno de nuestras ideas en expansión."_

---

## 📁 Organización del módulo

| Archivo                | Propósito                                    |
|------------------------|----------------------------------------------|
| `ZynModel.hx`         | Macro base para registrar esquemas           |
| `ZynQuery.hx`         | Creación y búsqueda de modelos               |
| `ZynMigration.hx`     | Creación automática de tablas                |
| `ZynNodePostgres.hx`  | Conexión y ejecución de SQL vía `pg`         |
| `TestORM.hx`          | Script de prueba del sistema completo        |

---

## 📚 Más del ecosistema

- 📄 **Zynvix_Documentacion.markdown**: Filosofía general
- 📄 **Zynvix_Tools_Documentation.markdown**: Explicación técnica de herramientas

---

## 🧠 Frase destacada

_"Migrar es aceptar que la estructura de hoy no será la misma que la de mañana."_  
— sobre `ZynMigration.hx`

---

## 🧱 Próximos pasos

- Validaciones por tipo de campo
- Relaciones entre modelos
- Serialización JSON automática
- CLI para generación de migraciones y modelos
- Compatibilidad con SQLite

¡Este es solo el inicio de ZynvixORM!  
Tu magia apenas comienza 🧪✨