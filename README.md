# ShopSphere

A polished e-commerce Android app built with **Flutter** and **Supabase**.
Developed by **Ayush**.

ShopSphere pairs a warm, editorial storefront with a pragmatic architecture:
Provider for state, repository abstractions for data, Supabase Auth and
PostgreSQL for the live backend, and an explicitly labelled offline demo mode so
the app can be explored without any credentials.

<p align="center">
  <img src="assets/branding/app_icon.png" alt="ShopSphere app icon" width="140" />
</p>

## Highlights

- **Curated storefront** — categories, featured picks, new arrivals and a
  promotional banner on a scrollable home dashboard.
- **Catalogue browsing** — 2-column product grid, category filters, debounced
  search, recent-search history and empty/error/loading states.
- **Product details** — large imagery, rating, stock awareness, quantity
  selector and add-to-bag.
- **Persistent bag** — slide-up bag sheet, quantity changes, stock clamping,
  subtotal and free-shipping progress, all restored from `SharedPreferences`.
- **Authentication** — email/password sign-in and sign-up through Supabase Auth,
  plus a seeded offline demo account.
- **Account screen** — profile summary, bag shortcut, backend status and
  sign-out.
- **Thoughtful UI** — custom DMSerif/Poppins typography, sage-and-cream palette,
  branded launcher icon and splash background, responsive layout.
- **Live ↔ demo switching** — Supabase repositories are used automatically when
  credentials are provided; otherwise the app runs the same flows against a
  local sample catalogue.

## Demo account (offline mode)

The app starts in demo mode when no Supabase credentials are supplied.

| Email | Password |
| --- | --- |
| `demo@shopsphere.app` | `demo1234` |

You can also create a new demo account from the sign-up screen; it is stored on
the device only.

## Getting started

Requirements: Flutter 3.44+ (Dart 3.12+), Android SDK, and a device or emulator.

```sh
cd shopsphere
flutter pub get
flutter run
```

That launches ShopSphere in offline demo mode — no backend setup required.

### Connect a live Supabase project

1. Create a project at [supabase.com](https://supabase.com).
2. Open the **SQL Editor**, paste the contents of [`supabase_setup.sql`](supabase_setup.sql)
   and run it. This creates the schema, Row Level Security policies, profile
   trigger and the 8-category / 16-product sample catalogue.
3. In **Authentication → Providers → Email**, enable email sign-ups. Disable
   email confirmation if you want sign-up to sign the user in immediately.
4. Run the app with your project URL and **publishable/anon** key:

```sh
flutter run \
  --dart-define=SUPABASE_URL=https://<project-ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<publishable-or-anon-key>
```

`SUPABASE_PUBLISHABLE_KEY` is accepted as an alternative key name. When the app
detects valid credentials it uses `SupabaseAuthRepository` and
`SupabaseProductRepository`; the in-app demo banner disappears.

> **Security:** never ship a service-role key in the app. Only the
> publishable/anon key belongs in the client. Credentials are passed at build
> time via `--dart-define`, so no keys are committed to source control.

## Building a release APK

```sh
flutter build apk --release
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`. To embed
live credentials in the artefact, add the same `--dart-define` flags to the build
command.

## Testing

```sh
flutter analyze   # No issues found
flutter test      # 40 tests passing
```

Coverage includes validators and formatters, model serialisation, the demo
repositories, all three providers (auth, catalogue, bag), the login flow and the
product card widget.

## Architecture

```
lib/
├── main.dart                     # Bootstrap, backend selection, providers
├── app.dart                      # MaterialApp, routes, theming
├── core/
│   ├── constants/                # App config, colour palette, icon map
│   ├── services/                 # Supabase, auth, catalogue, local storage
│   ├── theme/                    # Material 3 theme
│   └── utils/                    # Validators, formatters, error mapping
├── models/                       # Category, Product, AppUser, BagItem
├── providers/                    # AuthProvider, ProductProvider, BagProvider
├── routes/                       # Named routes and typed arguments
├── screens/                      # Splash, auth, home, listing, details, account
└── widgets/                      # Reusable UI components
```

**Data flow:** screens read from `ChangeNotifier` providers, providers talk to
repository interfaces, and repositories are swapped between Supabase and demo
implementations in `main.dart`. This keeps widgets free of backend details and
makes every layer testable without network access.

**Database:** `categories` and `products` are publicly readable with RLS
enabled; only the service role can modify them. `profiles` is scoped to
`auth.uid()` and populated by a trigger on `auth.users`. The product query joins
`categories(name)` for denormalised display data and sorts newest first.

**Resilience:** duplicate/out-of-order listing requests are discarded with a
request-ID guard, searches are debounced, and every async screen exposes loading,
empty and retry states. Errors are translated into friendly copy by
`error_mapper.dart`.

## Assignment checklist

| Requirement | Implementation |
| --- | --- |
| Flutter app with clean UI | Material 3 theme, custom fonts, branded icon/splash |
| Supabase integration | Auth + PostgreSQL catalogue via `supabase_flutter` |
| Authentication | Sign-in, sign-up, session restore, sign-out |
| Product listing | Grid, category filter, debounced search, history |
| Product details | Imagery, description, rating, stock, quantity, add to bag |
| State management | `provider` with repository pattern |
| Persistence | Supabase session + local bag and search history |
| Security | Anon key only, RLS policies, secrets via `--dart-define` |
| Testing | Unit, provider and widget tests (40) |
| Documentation | This README + idempotent SQL setup script |

## Notes and limitations

- The bag and search history are device-local by design; orders and checkout are
  outside the assignment scope.
- Demo accounts are hashed and stored locally with `SharedPreferences`; they are
  a convenience for reviewers, not a production auth mechanism.
- Product imagery is loaded from Unsplash with `cached_network_image`; a neutral
  placeholder is shown when a device is offline.
- The live Supabase path is configuration-driven. Run the SQL script and supply
  credentials to use it; otherwise the same UI runs against `DemoData`.

## License

Developed by Ayush. Sample product photography belongs to Unsplash
contributors.
