# Data Layer

Firestore models, repositories, services, and seed/bootstrap data.

Rules:
- Repositories own Firestore reads/writes.
- Services own domain workflows and transaction boundaries.
- Models own typed serialization.
- UI must not receive raw Firestore maps or snapshots.

For guidelines on how seed/bootstrap data must be generated, structured, and localized, see [Seed Data Generation Rules](file:///c:/Users/Admin/kivo_map/docs/seed_data_rules.md).
