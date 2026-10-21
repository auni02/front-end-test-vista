# Vista (Flutter frontend)

This is the Flutter app for the Vista full-stack technical test. It lets you browse companies and their services, add new companies, and add services to a company. It talks to the backend in the **back-end-test-vista** repo.

It uses `http` for API calls and `provider` for state management.

## What you need

- Flutter 3.47 or newer
- The backend running. Follow the README in **back-end-test-vista**. By default the app expects it at `http://localhost:3000`.
- I use chrome to run it
  
## Running it

```bash
flutter pub get
flutter run -d chrome
```

If your backend is somewhere other than `http://localhost:3000`, pass its address when you run the app:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:4000
```

for phone:

- **Real phone:** use your computer's local IP address, e.g. `http://192.168.1.10:3000`, and make sure both are on the same Wi-Fi.

To run the tests:

```bash
flutter test
```

## Screens

**Company list.** This is the home screen. Every company appears as a card in the pink card, with its name, registration number and the names of its services. Tap a card to see that company's services, with descriptions and prices, in the section below. The refresh button (or pulling down on a phone) reloads the list. "Add service" below opens the service form with that company already picked.

**Create company.** A form with name and registration number. Both are required. If the registration number already exists, the backend's message is shown so you know why it wasn't saved.

**Create service.** A form with a company dropdown, name, description and price. Every field is required, and the price has to be a number greater than 0. If there are no companies yet, the screen asks you to create one first.

## Loading and errors

- If the backend can't be reached, you get a friendly message and a "Try again" button rather than a blank page.
- Form buttons show a spinner while saving, and the fields are disabled so nothing gets submitted twice.
- Errors from the API (like a duplicate registration number, or validation errors) are shown in a snackbar, using the message the backend sent back.

## Design

Since this is my assignment, the theme would be pink because I love pink.

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
