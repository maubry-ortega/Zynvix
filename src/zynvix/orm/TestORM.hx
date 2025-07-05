package zynvix.orm;

import zynvix.orm.models.User;
import zynvix.orm.ZynQuery;
import zynvix.orm.ZynvixORM;
import zynvix.orm.ZynModel;

class TestORM {
  static function main() {
    ZynModel.zynSchema.set("user", {
      table: "user",
      fields: [
        { name: "id", constraints: { primaryKey: true, unique: false, maxLength: null } },
        { name: "name", constraints: { primaryKey: false, unique: true, maxLength: 50 } },
        { name: "email", constraints: { primaryKey: false, unique: true, maxLength: null } },
        { name: "password", constraints: { primaryKey: false, unique: false, maxLength: null } }
      ]
    });

    ZynvixORM.zynInit({
      host: "localhost",
      user: "zynvix",
      password: "devpass",
      dbname: "zynvixdb",
      port: 5432
    });

    var user = {
      name: "python_dev",
      email: "python@example.com",
      password: "1234"
    };

    ZynQuery.zynCreate(User, user, function(u) {
      if (u == null)
        trace("❌ Zyn: No se pudo crear el usuario");
      else
        trace("✅ Zyn: Usuario creado: " + u.name);
    });
  }
}
