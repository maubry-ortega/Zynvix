package zynvix.orm;

import zynvix.orm.models.User;
import zynvix.orm.ZynModel;
import zynvix.orm.ZynMigration;
import zynvix.orm.ZynQuery;
import zynvix.orm.ZynvixORM;

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

    ZynMigration.zynRun();

    var userData = {
      name: "alice",
      email: "alice@example.com",
      password: "1234"
    };

    ZynQuery.zynCreate(User, userData, function(user) {
      if (user == null) {
        trace("❌ Zyn: No se pudo crear el usuario");
        return;
      }

      trace("✅ Zyn: Created user: " + user.name);

      ZynQuery.zynFind(User, user.id, function(found) {
        if (found != null)
          trace("🔍 Zyn: Found: " + found.name);
        else
          trace("❌ Zyn: Not found");
      });
    });
  }
}
