# Lib Folder Structure

This file explains what each folder inside `lib/` is for.
The goal is to keep the project easy to read, test, and grow.

## Why this structure exists

We split the app into layers so each part has one clear job:

- `core`: shared things used in many places
- `data`: getting and saving data
- `domain`: business rules and app logic
- `presentation`: screens, widgets, and state for the UI
- `injection`: connecting classes together with dependency injection

A simple way to remember it is:

- `presentation` shows data
- `domain` decides what should happen
- `data` talks to storage

## Main folders

### `lib/core`
Shared code that does not belong to one feature only.
Put only truly reusable code here.

Use this folder for:

- app constants
- shared error types
- common extensions
- theme setup
- small utility helpers

Avoid turning `core` into a dumping ground for random code.
If something belongs only to devices or maintenance, keep it inside that feature instead.

### `lib/data`
This layer is responsible for reading and writing data.
It knows about local database code like `drift`, and later it could also know about APIs.

Use this layer when you need to:

- load records from the database
- save or update records
- convert raw data into app-friendly objects

This layer should not contain screen widgets.

### `lib/domain`
This layer contains the app's business meaning.
It should stay clean and mostly independent from Flutter UI code.

Use this layer for:

- entities that describe important app objects
- repository contracts that define what the app needs
- use cases that perform one business action

This helps keep your app logic testable and easier to change later.

### `lib/presentation`
This is the UI layer.
It contains pages, widgets, and blocs/cubits for each feature.

Use this layer for:

- screens the user sees
- buttons, forms, cards, and feature widgets
- state handling for user interactions
- loading, success, empty, and error UI states

Try to keep heavy logic out of widgets.
If a widget is doing too much, move logic into a bloc, cubit, repository, or use case.

### `lib/injection`
This folder wires the app together.
It is where `get_it` and `injectable` setup should live.

Use this folder to:

- register repositories
- register data sources
- register blocs or use cases when needed
- keep app startup setup in one place

This keeps `main.dart` small and focused.

## Core

### `lib/core/constants`
Store fixed values that are reused in many places.
Examples:

- route names
- database table names
- default padding values
- app-wide text constants that are truly shared

Do not move feature-only labels here unless they are reused broadly.

### `lib/core/errors`
Store custom error and failure classes.
This gives the app a clear way to describe what went wrong.
Examples:

- database failure
- validation failure
- unexpected app error

### `lib/core/extensions`
Store Dart extension methods.
These help make code cleaner when you often repeat small transformations.
Examples:

- formatting a date
- checking if a string is blank
- mapping values into UI-friendly text

Keep extensions small and easy to understand.

### `lib/core/theme`
Store app theme setup.
Examples:

- app colors
- text styles
- theme data
- input decoration theme

This helps keep the UI consistent.
If this folder is missing, it is a good folder to add later when theme code starts growing.

### `lib/core/utils`
Store small generic helpers.
Use this only for helpers that are truly shared and do not fit better somewhere else.
Examples:

- date helper functions
- formatting helpers
- small validation helpers

If a helper belongs to only one feature, prefer placing it inside that feature.

## Data

### `lib/data/datasources`
This is the lowest-level data access code.
It talks directly to `drift`, local tables, or future APIs.

Examples:

- database DAO-style classes
- methods like `getDevices()`
- methods like `insertMaintenanceRecord()`

Keep this layer focused on raw access, not business decisions.

### `lib/data/models`
Store data-layer models and mapping code.
These models are often shaped around storage or JSON.
Examples:

- DTOs
- `freezed` models
- `json_serializable` classes
- conversion methods to domain entities

Try not to pass these models directly into widgets.
Map them to domain entities at the repository boundary when possible.

### `lib/data/repositories`
This folder contains repository implementations.
These classes connect the domain contracts to the actual data source code.

For example, a repository implementation might:

- call a drift datasource
- get raw models back
- convert them into domain entities
- return those entities to the rest of the app

This keeps the data details hidden from the UI.

## Domain

### `lib/domain/entities`
Entities are the main business objects of the app.
They should be plain Dart objects without Flutter widget code.
Examples:

- `Device`
- `MaintenanceTask`
- `ServiceSchedule`

These represent what the app cares about, not how the database stores it.

### `lib/domain/repositories`
This folder contains abstract contracts.
These contracts describe what the app needs to do, without saying how it is done.

Example idea:

- a `DeviceRepository` contract may define methods to load and save devices

Then the data layer provides the real implementation.

### `lib/domain/usecases`
Use cases represent one business action.
They are useful when a piece of logic is important enough to stand on its own.
Examples:

- get all devices
- add a new maintenance record
- mark a task as completed

A good use case usually has one clear purpose.

## Presentation

### `lib/presentation/devices`
All UI code related to the devices feature should live here.
This keeps the feature grouped together and easier to navigate.

#### `lib/presentation/devices/bloc`
Put `Bloc` or `Cubit` classes here.
They handle feature state and user-driven events.

Examples:

- loading devices
- filtering device lists
- handling add/edit flows

#### `lib/presentation/devices/pages`
Put full screens here.
Examples:

- devices list page
- device details page
- add device page

#### `lib/presentation/devices/widgets`
Put smaller widgets here that belong only to the devices feature.
Examples:

- device card
- device filter bar
- empty state widget

### `lib/presentation/maintenance`
All UI code related to maintenance should live here.
Keep the same structure as other features so the project stays predictable.

#### `lib/presentation/maintenance/bloc`
Put maintenance state handling here.
Examples:

- loading maintenance history
- creating records
- tracking save state

#### `lib/presentation/maintenance/pages`
Put maintenance screens here.
Examples:

- maintenance list page
- maintenance detail page
- create maintenance page

#### `lib/presentation/maintenance/widgets`
Put small maintenance-only widgets here.
Examples:

- maintenance item tile
- status badge
- form section widget

### `lib/presentation/home`
This folder contains home screen UI.
If the home feature grows bigger, it can follow the same `bloc`, `pages`, and `widgets` structure too.

## A simple dependency rule

Try to keep dependencies flowing like this:

- `presentation -> domain`
- `data -> domain`
- `core -> shared by all when appropriate`

That means:

- UI should not directly depend on database table details
- domain should not import Flutter widgets
- data should handle storage details
