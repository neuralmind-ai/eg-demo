# ADR 0001: Native, local Android foundation

Status: accepted for development; application ID is provisional before publication.

Use Kotlin, Compose/Material 3, one app module, ViewModel state, manual constructor
injection, and a repository wrapping Room. SDK 36, minimum SDK 28 (Android 9) keeps
initial compatibility/testing scope manageable; validate audience coverage before
release. Application ID: dev.local.notetaker. No backend or network permission.

Pin AGP 8.13.2, Gradle 8.13, Kotlin 2.2.10, and JDK 21. Use Compose BOM 2025.08.01
and Room 2.7.2. This deliberately uses a stable compatible baseline rather than
preview tooling. Upgrade separately after baseline tests pass.

The first slice supports creating and explicitly saving a text note, listing it,
and reopening it after relaunch. Save completion means the Room transaction
completed. Pending text is not durable until Save succeeds; the UI must say so.
Capture immutable save input and prevent concurrent saves. Autosave, search,
delete/undo, sync, export, and backup are later features. Keep backup disabled until
its privacy and restore behavior is explicitly designed. No destructive migrations.

Room schemas are checked in. Test real disk persistence, ViewModel failure/success,
and the Compose workflow. Activity recreation is distinct from process death.
