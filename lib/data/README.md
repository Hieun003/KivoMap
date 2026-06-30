# Data Layer

Firestore models, repositories, services, and seed/bootstrap data.

Rules:
- Repositories own Firestore reads/writes.
- Services own domain workflows and transaction boundaries.
- Models own typed serialization.
- UI must not receive raw Firestore maps or snapshots.
