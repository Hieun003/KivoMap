# Feature Layer

Each feature follows MVVM:

```text
feature/
  view/
  view_model/
  widgets/
```

Rules:
- Views compose widgets and observe ViewModels.
- ViewModels coordinate state and user intents.
- Widgets are feature-scoped unless reused by multiple features.
- Features do not import each other's repositories or ViewModels directly.
