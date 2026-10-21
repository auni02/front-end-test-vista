# Vista (Flutter frontend)

This is the Flutter app for the Vista full-stack technical test. It lets you browse companies and their services, add new companies, and add services to a company. It talks to the backend in the **back-end-test-vista** repo.

It uses `http` for API calls and `provider` for state management.

## What you need

- Flutter 3.47 or newer
- The backend running. Follow the README in **back-end-test-vista**. By default the app expects it at `http://localhost:3000`.
- Chrome, the easiest way to run it. It also runs on macOS, Android and iOS.

## Running it

```bash
flutter pub get
flutter run -d chrome
```

If your backend is somewhere other than `http://localhost:3000`, pass its address when you run the app:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:4000
```

A couple of things to know for other devices:

- **Android emulator:** `localhost` points at the emulator itself, so use `--dart-define=API_BASE_URL=http://10.0.2.2:3000`.
- **Real phone:** use your computer's local IP address, e.g. `http://192.168.1.10:3000`, and make sure both are on the same Wi-Fi.

To run the tests (model parsing, plus the screens rendered at phone and desktop sizes with form validation checks):

```bash
flutter test
```

## Screens

**Company list.** This is the home screen. Every company appears as a card in the pink carousel, with its name, registration number and the names of its services. Tap a card to see that company's services, with descriptions and prices, in the section below. The refresh button (or pulling down on a phone) reloads the list. "Add service" below the carousel opens the service form with that company already picked.

**Create company.** A form with name and registration number. Both are required. If the registration number already exists, the backend's message is shown so you know why it wasn't saved.

**Create service.** A form with a company dropdown, name, description and price. Every field is required, and the price has to be a number greater than 0. If there are no companies yet, the screen asks you to create one first.

## Loading and errors

- While companies are loading, a pulsing pink sphere is shown instead of an empty screen.
- If the backend can't be reached, you get a friendly message and a "Try again" button rather than a blank page.
- Form buttons show a spinner while saving, and the fields are disabled so nothing gets submitted twice.
- Errors from the API (like a duplicate registration number, or validation errors) are shown in a snackbar, using the message the backend sent back.

## Design

The look is inspired by fashion editorial sites: a white page, black wide type (Unbounded and Lexend Exa), a chunky pink logo (Bagel Fat One), and a dusty pink band where the companies sit in a carousel. Pick a company in the carousel and its services appear below it.

A few small animations bring it to life:

- Glossy pink and chrome spheres float gently over the headline and the cards
- Company cards and service cards fade and slide in one after another
- The selected company card grows and brightens; the services below cross-fade when you switch
- Pill buttons darken and nudge their arrow on hover, and squish when pressed
- Service cards lift on hover
- Screens slide up softly when opened

It's responsive. On phones the navigation collapses into a menu, the carousel scrolls with a swipe, and services stack in one column. On wider screens you get arrow buttons on the carousel, two or three columns of services, and the forms sit beside their heading instead of below it.

## How the code is organised

```
lib/
  main.dart                     App entry point; sets up the provider and theme
  config.dart                   Backend URL (overridable with --dart-define)
  models/                       Company and Service, with fromJson
  services/api_service.dart     All HTTP calls; turns API errors into readable messages
  providers/company_provider.dart  Shared state: companies, loading, error
  screens/                      The three screens
  widgets/                      Company and service cards, pill buttons, top bar,
                                animations, shared form layout
  theme/app_theme.dart          Colours, fonts and component styles
```

The screens never call the API directly. They ask `CompanyProvider`, which calls `ApiService`, updates its list, and notifies the screens to rebuild. So when you add a company or a service, the list screen updates straight away without another network request.
# front-end-test-vista
