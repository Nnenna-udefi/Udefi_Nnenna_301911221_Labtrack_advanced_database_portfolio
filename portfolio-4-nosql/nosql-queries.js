// 1. Create Compound & Multi-Key Indexes
db.specimen_history.createIndex({ specimen_id: 1 }, { unique: true });
db.specimen_history.createIndex({ specimen_type: 1, status: 1 });
// Multi-key index on array elements
db.specimen_history.createIndex({ "history.performed_by": 1 }); 

// 2. Query Execution Analysis
db.specimen_history
  .find({ specimen_id: "SPCG000665" })
  .explain("executionStats")

// 3. Update Operation with BSON ISODate ($set + $push)
db.specimen_history.updateOne(
   { specimen_id: "SPCG000451" },
   {
      $set: { status: "COMPLETED" },
      $push: {
         history: {
            event: "COMPLETED",
            timestamp: "2026-06-01T10:00:00Z",
            performed_by: "STF003",
            notes: "Analysis completed successfully"
         }
      }
   }
);

// 4. Advanced Aggregation: Unwinding embedded history to measure staff productivity
db.specimen_history.aggregate([
   { $unwind: "$history" },
   { 
      $group: {
         _id: "$history.performed_by",
         total_events_handled: { $sum: 1 },
         event_types: { $addToSet: "$history.event" }
      }
   },
   { $sort: { total_events_handled: -1 } }
]);

// 5. Filter based on id
db.specimen_history
   .findOne({specimen_id: SPCG000451});