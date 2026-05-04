# RecipeBox – Offline‑First Recipe Browser

<p align="center">
  <img src="https://img.shields.io/badge/Swift-6.0-orange" alt="Swift 6">
  <img src="https://img.shields.io/badge/iOS-17.0+-blue" alt="iOS 17+">
  <img src="https://img.shields.io/badge/Xcode-16.2+-blueviolet" alt="Xcode 16.2+">
  <img src="https://img.shields.io/badge/Architecture-MVVM%20%2B%20async/await-success" alt="Architecture">
  <img src="https://img.shields.io/badge/Persistence-Core%20Data%20(local)-lightgrey" alt="Core Data">
  <img src="https://img.shields.io/badge/Test%20Coverage-92%25-brightgreen" alt="Coverage">
  <img src="https://img.shields.io/badge/Widget-Home%20Screen-red" alt="Widget">
</p>

**real‑time filtering, home‑screen widget, and a SwiftUI interface.**  
It fetches recipes from TheMealDB, caches them locally, and displays them
> **Why this project?**  
> – Shows complex Core Data relationships (One‑to‑many, Many‑to‑many).  
> – Background context saving with merge policy.  
> – Home Screen widget sharing data via App Groups.  
> – Comprehensive unit tests covering models, logic, networking, and persistence.
---

## 📱 Features

| Category            | Details |
|---------------------|---------|
| 🔍 Search & Fetch   | Search recipes from TheMealDB, save to Core Data, avoid duplicates. |
| 🗂 Filtering        | Filter by **category** (horizontal chip selector) and **text** (real‑time search). |
| 📋 Details          | Full recipe view: image, ingredients (with measures), instructions, source link. |
| 🧩 Relationships    | Recipe ↔ Ingredient (one‑to‑many, cascade delete). Recipe ↔ Category (many‑to‑many, nullify). |
| 💾 Persistence      | Core Data with App Group support for widget, background context saves, `NSPersistentContainer`. |
| 📡 Offline‑first    | All fetched recipes are cached locally. Works without network after first sync. |
| 🎨 Polished UI      | Warm gradient backgrounds, glass‑morphism cards, shimmer loading, hero image transitions, custom category chips. |
| 🧠 Ingredients      | Parses up to 20 ingredient/measure pairs from API, skipping empty ones. |
| 📲 Widget           | Medium & Small widgets show the latest saved recipe with image and category. |
| 🧪 Testing          | Extensive test suite: Core Data, relationships, migration, networking, ingredient parsing, widget provider. |

---

## 🧱 Architecture

```
┌──────────────────────────────────────────┐
│ SwiftUI Views │
│ ContentView, RecipeCard, DetailView … │
└────────────────┬─────────────────────────┘
│ @FetchRequest / Observable
┌────────────────▼─────────────────────────┐
│ Core Data Stack │
│ PersistenceController (App Group) │
│ Recipe, Ingredient, RecipeCategory │
└────────────────┬─────────────────────────┘
│ async/await
┌────────────────▼─────────────────────────┐
│ RecipeService │
│ Fetches from TheMealDB, decodes Meal │
└──────────────────────────────────────────┘
```

**Key Points:**
- Views use `@FetchRequest` directly, no custom view models required – Core Data drives the UI.
- Networking layer (`RecipeService`) returns simple structs; persistence logic is handled separately.
- Widget uses the same `PersistenceController` via App Group, reading the shared `.sqlite` file.
- No third‑party reactive frameworks – pure Swift Concurrency (`async/await`).

---

## 🛠 Tech Stack

| Layer            | Technology                          |
|------------------|-------------------------------------|
| UI               | SwiftUI (iOS 17+)                   |
| Persistence      | Core Data (SQLite) + App Group      |
| Networking       | URLSession, async/await, Codable    |
| Migration        | Core Data Manual Migration          |
| Widget           | WidgetKit, TimelineProvider         |
| Testing          | XCTest, in‑memory Core Data, Mock URLProtocol |
| Minimum Target   | iOS 17.0                            |
| Language         | Swift 6                             |

---

## 📂 Project Structure

```
RecipeBox/
├── App/
│ ├── RecipeBoxApp.swift # @main entry, environment setup
│ └── PersistenceController.swift # Core Data stack (local + App Group)
├── Model/
│ ├── Recipe+CoreDataClass.swift # NSManagedObject subclass (manual)
│ ├── Recipe+CoreDataProperties.swift # Attributes, relationships, computed lists
│ ├── Ingredient+CoreDataClass.swift
│ ├── Ingredient+CoreDataProperties.swift
│ ├── RecipeCategory+CoreDataClass.swift
│ ├── RecipeCategory+CoreDataProperties.swift
├── CoreData/
│ └── RecipeBox.xcdatamodeld # Data model 
├── Services/
│ ├── RecipeService.swift # TheMealDB API, Meal model + ingredients parsing
│ └── ImageCache.swift (optional)
├── Views/
│ ├── ContentView.swift # Search, category picker, grid container
│ ├── RecipeListContainer.swift # Dynamic predicate fetch wrapper
│ ├── RecipeCard.swift # Card with image, gradient, categories
│ ├── RecipeDetailView.swift # Full recipe detail
│ ├── CategoryPicker.swift # Horizontal category chips
│ ├── CategoryChip.swift # Styled chip (selected/unselected)
│ ├── ShimmerView.swift # Shimmer loading animation
│ └── CachedAsyncImage.swift # Robust async image loader
├── Widget/
│ ├── RecipeWidgetProvider.swift # TimelineProvider (fetches from shared store)
│ ├── RecipeWidgetEntryView.swift # Small & Medium widget views
│ └── Assets.xcassets # Widget assets
└── Tests/
├── CoreDataTests/
│ ├── RecipeEntityTests.swift
│ ├── RelationshipTests.swift
│ ├── BackgroundSaveTests.swift
│ └── MigrationTests.swift
├── Networking/
│ ├── RecipeServiceTests.swift
│ └── MockURLProtocol.swift
├── Logic/
│ ├── SaveMealsTests.swift
│ └── IngredientParsingTests.swift
└── Widget/
└── RecipeWidgetProviderTests.swift
```

## 📝 What’s tested
```
Core Data CRUD and default values.
Relationships (cascade delete for ingredients, nullify for categories).
Background context save and merge policy.
Networking (success, empty, network error).
Meal ingredient parsing (empty measures, partial data).
Duplicate recipe prevention.
Widget timeline (empty state and populated state).
```

## 📬 Contact
---
Chetan Purohit
iOS Developer
Chetan81289@outlook.com
** **
- Open to remote iOS contracts worldwide.
- The same app is also available in MVVM+Combine and TCA variants – ask for a demo.
---
