# Flutter Widget & Screen Guidelines

Rules for every agent building UI in this codebase. No exceptions unless a rule physically cannot apply.

---

## 1. const — First, Always

**Aggressively apply `const`.** When two widgets produce the same result, pick the one that supports a `const` constructor. When a value is known at compile time, mark it `const`.

```dart
// CORRECT
const SizedBox(height: 16.0)
const EdgeInsets.symmetric(horizontal: 16.0)
const Text('Label', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600))
const Divider(thickness: 1.0)
const Center(child: CircularProgressIndicator())

// WRONG — every one of these can be const
SizedBox(height: 16.0)
EdgeInsets.all(8.0)
BorderRadius.circular(12.0)   // use const BorderRadius.all(Radius.circular(12.0)) for fixed values
```

Every widget class must declare a `const` constructor:

```dart
class MyWidget extends StatelessWidget {
  const MyWidget({super.key, required this.title});
  final String title;
}
```

**Widget choice when equivalent:** prefer `DecoratedBox` over `Container` when you only need decoration (no constraints). Use `Container` only when you need both decoration and size constraints simultaneously.

---

## 2. Widget Classification

### Screen (entry point)

Screens are route targets. They own the scaffold setup and are responsible for scoping state to their subtree. They must not contain layout logic beyond routing to sub-widgets.

Rules for screens:
- Always `StatelessWidget` (or the framework equivalent for read-only state consumers). Never own mutable local state beyond controller lifecycle.
- Always use the project's standard scaffold wrapper, never raw `Scaffold`.
- Always use the project's standard app bar component (or a custom `PreferredSizeWidget`) as the `appBar` argument.
- Screens own the state management solution — they scope and provide state to their subtree.
- The screen's build output handles exactly three states: loading, error, and loaded.

**Composition over inheritance.** Build complex widgets by composing smaller ones. Never subclass a widget to extend its visual behaviour.

### Reusable Widget (lib/widgets/ or lib/core/widgets/)

A widget is reusable when it is used by more than one screen. Place it in the project's shared widgets directory.

Rules:
- Always `StatelessWidget`.
- Configure entirely via constructor parameters — never read state management directly inside shared widgets unless the widget is explicitly a "smart" connector widget.
- Parameters should be typed precisely: `String` not `dynamic`, `VoidCallback` not `Function`.
- Provide sensible defaults for optional parameters.

### Private Screen Widget (file-local)

When a widget is only used within a single screen or feature file, define it as a private class at the bottom of the same file with an underscore prefix.

```dart
class _HistoryStatsWidget extends StatelessWidget {
  const _HistoryStatsWidget({required this.offers});
  final List<LoanOffer> offers;
}
```

When to extract vs. inline in `build`: extract to a private class when the subtree has its own data (constructor params), exceeds ~10 lines of layout, or repeats. Otherwise inline is fine.

### Feature-Scoped Widgets

When a screen has distinct sections that each deserve their own file but are not reusable outside this feature, place them in a `widgets/` subdirectory inside the feature folder.

---

## 3. Screen Layout Pattern

Every screen body follows this structure:

```
StandardScaffold
  └─ appBar: StandardAppBar (or custom PreferredSizeWidget)
  └─ child:
       └─ [state management layer]
            ├─ Loading → const Center(child: LoadingIndicator())
            ├─ Error   → ErrorWidget(message: state.message)
            └─ Loaded  → content widget (scrollable or list)
```

The loaded content is one of:
- `SingleChildScrollView` → `Column` for forms and multi-section layouts.
- `ListView.builder` for homogeneous lists without dividers.
- `ListView.separated` for lists with dividers.
- `Column` + `Expanded(child: ListView)` when a header must stay fixed above a scrollable list.

Padding:
- Pass `padding: EdgeInsets.zero` to the scaffold when the child controls its own padding.
- Horizontal screen padding: `EdgeInsets.symmetric(horizontal: 16.0)`.
- `SingleChildScrollView` padding: `const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)`.
- `ListView` padding: `EdgeInsets.zero` (let items own their padding) or `const EdgeInsets.symmetric(horizontal: 16.0)`.

---

## 4. App Bars

Use the project's standard app bar component for all standard screens. When a screen needs a non-standard app bar, create a dedicated widget that implements `PreferredSizeWidget`.

Never build app bar logic directly inside a screen's `build` method.

---

## 5. Spacing

Use `SizedBox` for spacing between siblings. Never use `Padding` just for spacing between unrelated widgets.

```dart
// CORRECT
const SizedBox(height: 24.0)

// WRONG
Padding(padding: EdgeInsets.only(bottom: 24.0), child: ...)
```

Use `Column.spacing` when all children have the same gap:

```dart
Column(
  spacing: 16.0,
  children: [...],
)
```

Use `const SizedBox.shrink()` as the empty/null slot in conditional ternaries:

```dart
condition ? SomeWidget() : const SizedBox.shrink()
```

---

## 6. Conditional Widgets

Use spread-if for optional children in `Column`/`Row`/`children` lists:

```dart
children: [
  const AlwaysVisible(),
  if (showOptional) ...[
    const SizedBox(height: 8.0),
    const OptionalWidget(),
  ],
],
```

Never use `Visibility` or `Opacity` to hide/show widgets that have no animated need.

---

## 7. Navigation

All navigation goes through the project's centralized navigation class. Never call `Navigator.of(context)` or the routing framework directly from widget code — use the navigation abstraction.

```dart
// CORRECT — via centralized navigation class
navigator.push(TargetScreen.routePath);
navigator.pop();
navigator.go(TargetScreen.routePath);

// WRONG — direct framework calls in widget code
Navigator.of(context).push(...);
context.push(...);       // routing framework extension
```

**Exception:** dialog pop-with-result uses `Navigator.of(context).pop(result)` because dialog routes are not managed by the navigation abstraction.

Extract navigation calls to private methods when the handler does anything beyond a single call:

```dart
void _onSuccess() {
  navigator.go(HomeScreen.routePath);
}
```

---

## 8. Font Sizes

The project maintains a typed font size constants class. Use the theme's text style scale where the size is appropriate. When you need to override size or weight, reference the constants class — never inline a magic number.

```dart
// CORRECT
Text('Label', style: TextStyle(fontSize: AppFontSizes.label, fontWeight: FontWeight.w600))
Theme.of(context).textTheme.bodyMedium  // acceptable when theme scale is correct

// WRONG
Text('Label', style: TextStyle(fontSize: 14))  // magic number
```

Always supply `fontWeight` explicitly when using a custom `TextStyle`. Never rely on the default weight.

Set `height` (line height) on body text to between `1.4` and `1.6`:

```dart
TextStyle(fontSize: AppFontSizes.body, height: 1.5)
```

Always add `maxLines` and `overflow: TextOverflow.ellipsis` to any `Text` that could receive unbounded or user-generated content.

---

## 9. List Patterns

**With dividers:**
```dart
ListView.separated(
  padding: EdgeInsets.zero,
  itemCount: items.length,
  itemBuilder: (_, i) => ItemWidget(item: items[i]),
  separatorBuilder: (_, _) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 8.0),
    child: Divider(thickness: 1.0),
  ),
)
```

**Without dividers:**
```dart
ListView.builder(
  padding: const EdgeInsets.symmetric(horizontal: 16.0),
  itemCount: items.length,
  itemBuilder: (_, i) => ItemWidget(item: items[i]),
)
```

**Very long or infinite lists:** prefer `SliverList.builder` inside a `CustomScrollView`.

**Trailing spacer:**
```dart
itemCount: items.length + 1,
itemBuilder: (_, i) {
  if (i == items.length) return const SizedBox(height: 12.0);
  return ItemTile(item: items[i]);
},
```

---

## 10. Decoration

- Use `DecoratedBox` when you only need visual decoration with no size constraints.
- Use `Container` only when you need both `decoration` and `constraints`.

**Shadows:**
```dart
BoxShadow(
  color: const Color(0x1A000000),
  offset: const Offset(2, 4),
  blurRadius: 11,
  spreadRadius: 0,
)
```

---

## 11. Dialogs

Wrap every dialog in `Dialog` (not `AlertDialog`). Control dismissibility with `PopScope`:

```dart
PopScope(
  canPop: false,
  child: Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [...],
      ),
    ),
  ),
)
```

Extract `_onAction(BuildContext context)` methods for dialog button handlers.

---

## 12. Custom Painters

When a widget's visual cannot be built from standard Flutter widgets, use `CustomPaint` with a private `_XxxPainter`:

```dart
class _RadioButtonPainter extends CustomPainter {
  final bool isSelected;
  _RadioButtonPainter({required this.isSelected});

  @override
  void paint(Canvas canvas, Size size) { ... }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

---

## 13. Imports

Follow the project's established import style consistently. If the project uses a barrel import, use it for all project-internal imports. If the project uses individual imports, use them consistently — do not mix styles within a file.

Never import `dart:ui`, `flutter/material.dart`, or `flutter/widgets.dart` directly if they are re-exported by a barrel.

---

## 14. Naming

| Thing | Convention | Example |
|---|---|---|
| Screen | `XxxScreen` | `MedicationsListScreen` |
| View / Page | `XxxView`, `XxxPage` | `LoginView` |
| Public widget | `XxxWidget`, `XxxCard`, `XxxTile` | `AppErrorBanner` |
| Private (file-local) widget | `_XxxWidget` | `_TodaySummary` |
| Custom painter | `_XxxPainter` | `_RadioButtonPainter` |
| Custom app bar | `XxxAppBar` | `PlanManagementAppBar` |
| Design system base widget | `BaseXxx` | `BaseScaffold`, `BaseAppBar` |
| Action handler method | `_onVerb(...)` | `_onTap`, `_onSave` |

---

## 15. Tap Handling

Use `GestureDetector` for custom tap areas. Use `TextButton` / `ElevatedButton` / `IconButton` for standard interactive elements. Never use `InkWell` unless ripple feedback is explicitly required.

Extract all non-trivial tap handlers to private methods:

```dart
void _onTap(BuildContext context) {
  navigator.push(TargetScreen.routePath);
}
```

---

## 16. Colors

Always use the project's named color constants. Never use inline `Color(0xffXXXXXX)` unless the color is truly one-off and has no semantic equivalent in the project's color class. If you use a hex color more than once, it belongs in the color constants class.

---

## 17. Layout — Flex, Wrap, and Stack

- **`Expanded`** — child fills all remaining space along the main axis.
- **`Flexible`** — child can shrink but is not forced to fill. Never combine `Flexible` and `Expanded` in the same `Row` or `Column`.
- **`Wrap`** — use instead of `Row` when children might overflow.

Use `Stack` when widgets must overlap. Position children with `Positioned` (edge anchoring) or `Align` (alignment-based).

Use `OverlayPortal` for overlays (custom dropdowns, tooltips) to show UI above everything else without fighting z-order.

---

## 18. Performance

**Never perform expensive work inside `build()`.** Network calls, heavy computation, file I/O, and JSON parsing must not run in the build method.

**Offload heavy computation with `compute()`** to avoid blocking the UI thread.

**Avoid rebuilding large subtrees unnecessarily.** Extract stable parts of the tree into `const` widgets or private widget classes.

---

## 19. Accessibility

**Semantic labels** — wrap any non-text interactive or informational widget in `Semantics`:

```dart
Semantics(
  label: 'Profile picture of $userName',
  child: CircleAvatar(...),
)
```

Decorative icons that convey no information should be wrapped in `ExcludeSemantics`.

**Color contrast** — text must have a contrast ratio of at least **4.5:1** against its background (WCAG 2.1 AA).

**Dynamic text scaling** — always use `maxLines` + `overflow` on all `Text` widgets, and avoid fixed-height containers that clip scaled text.

---

## 20. What This File Does Not Cover

- State management
- Repository and data layer
- Dependency injection
- Routing configuration
- API calls and data models
- Form validation logic
