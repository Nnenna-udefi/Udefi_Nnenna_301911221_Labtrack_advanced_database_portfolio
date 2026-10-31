// Use collMod to apply validation rules to the existing specimen_history collection

db.runCommand({
   collMod: "specimen_history",
   validator: {
      $jsonSchema: {
         bsonType: "object",
         required: ["specimen_id", "order_id", "specimen_type", "status", "history"],
         properties: {
            specimen_id: {
               bsonType: "string",
               description: "Must be a unique string starting with SPCG"
            },
            order_id: {
               bsonType: "int",
               description: "Must be an integer referencing the SQL order_id"
            },
            specimen_type: {
               enum: ["SERUM", "PLASMA", "URINE", "CERVICAL_SWAB", "URETHRAL_SWAB", "WHOLE_BLOOD"],
               description: "Must match a valid lab specimen type"
            },
            status: {
               enum: ["REGISTERED", "RECEIVED", "IN_ANALYSIS", "COMPLETED", "REJECTED"],
               description: "Current operational state of the specimen"
            },
            history: {
               bsonType: "array",
               description: "Embedded audit log tracking workflow execution",
               items: {
                  bsonType: "object",
                  required: ["event", "timestamp", "performed_by"],
                  properties: {
                     event: { bsonType: "string" },
                     timestamp: { bsonType: "date" },
                     performed_by: { bsonType: "string" },
                     notes: { bsonType: "string" }
                  }
               }
            }
         }
      }
   },
   validationLevel: "strict",
   validationAction: "error"
});