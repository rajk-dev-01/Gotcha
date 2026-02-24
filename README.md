## Gotcha – Intelligent Receipt Scanner & Organizer

Smart iOS app that scans, understands, and organizes receipts using on‑device OCR and OpenAI‑powered parsing.

---

### Overview

Modern consumers and professionals accumulate a large volume of receipts across online and offline purchases, making it difficult to track expenses, warranties, and proof of purchase over time. **Gotcha** streamlines this by turning raw receipt images into structured, searchable records.

The app combines **camera scanning / photo import**, **Apple Vision OCR**, and **OpenAI‑powered extraction** to automatically pull out key fields like store name, date, total amount, and more. This makes Gotcha useful for **personal finance tracking, expense reporting, and record-keeping** in domains such as freelance work, small businesses, and everyday household budgeting.

---

### Features

- **Camera-based document scanning**  
  Uses VisionKit’s `VNDocumentCameraViewController` for high-quality receipt capture.

- **Photo library import**  
  Select existing receipt photos using `PhotosUI` and process them just like scanned documents.

- **On-device OCR**  
  Uses Apple Vision to extract raw text from receipt images with high accuracy.

- **AI-powered field extraction**  
  Sends OCR text to the OpenAI Chat Completions API to extract:
  - Store name  
  - Date  
  - Total amount  
  - Address  
  - Payment method  
  - Customer name  
  - Phone number  
  - Receipt ID  
  - Tracking information

- **Structured receipt storage**  
  Persists data in Core Data (`ReceiptItem` entity) including the original image.

- **Fast, debounced search**  
  Search receipts by name with a debounced query for smooth UX.

- **Detail view with zoom**  
  View all extracted fields and open the original image in a zoomable full-screen viewer.

- **Modern SwiftUI UI**  
  Gradient background, glassmorphism-inspired cards, and a clean, portfolio-ready interface.

- **MVVM architecture**  
  Clear separation of Views, ViewModels, and Models to keep logic testable and maintainable.

---

### Tech Stack

- **Languages**
  - Swift

- **Frameworks**
  - SwiftUI  
  - UIKit (for camera/document scanner integration)  
  - Core Data  
  - Vision (OCR)  
  - VisionKit (Document Scanner)  
  - PhotosUI

- **Libraries / Services**
  - OpenAI Chat Completions API (via `URLSession`)

- **Tools**
  - Xcode  
  - Git / GitHub (`rajk-dev-01/Gotcha`)  
  - Xcode build configurations using `.xcconfig` for secrets management

---

### Architecture / Workflow

Gotcha follows a **MVVM** architecture with a clear separation of concerns:

- **Views (`Gotcha/Views`)**  
  SwiftUI screens and UI components (`ResultView`, `SaveAsView`, `DetailsView`, `ContentView`, scanner/picker views, theming).

- **ViewModels (`Gotcha/ViewModels`)**  
  `ResultViewModel`, `SaveAsViewModel`, `DetailsViewModel` – handle presentation logic, state management, navigation flags, and coordination between views and models.

- **Models (`Gotcha/Models`)**  
  - `ReceiptRepository` – persistence layer for Core Data (`ReceiptItem`)  
  - `OpenAIService` – encapsulates the OpenAI API integration and prompt construction  
  - `OCRHelper` – encapsulates Vision OCR logic  
  - Core Data model (`Gotcha.xcdatamodeld`) with `ReceiptItem` entity

**High-level data flow:**

1. **Capture / Import**  
   User taps “Add New Receipt” → chooses **Camera** (VisionKit) or **Photo Library** (PhotosUI).

2. **OCR**  
   The chosen image is passed to `OCRHelper`, which uses Vision text recognition to produce raw text.

3. **AI Extraction**  
   OCR text is sent to `OpenAIService`, which returns a strict JSON object with all key receipt fields.

4. **Review & Save**  
   `SaveAsViewModel` populates the form fields, allows manual corrections, and then saves via `ReceiptRepository` into Core Data.

5. **Search & Browse**  
   `ResultViewModel` exposes debounced search text; `FilteredReceiptsList` uses Core Data `@FetchRequest` to show filtered results.

6. **Detail & Zoom**  
   Tapping an item opens `DetailsView`, which shows both structured data and a zoomable full-screen image.

---

### Installation and Setup

#### Prerequisites

- macOS with a recent version compatible with **Xcode 16+**
- **Xcode 16+**
- iOS device or simulator (iOS 18+ recommended)
- An **OpenAI API key** with access to the Chat Completions API

#### 1. Clone the repository

```bash
git clone https://github.com/rajk-dev-01/Gotcha.git
cd Gotcha
```

*(Adjust path if your remote repo name differs.)*

#### 2. Configure OpenAI API key

1. In the repo, you’ll find an example config:

   - `Gotcha/Secerts-Example.xcconfig`

2. Create a real secrets file alongside it:

   ```text
   Secrets.xcconfig
   ```

3. Edit `Secrets.xcconfig` and set your key:

   ```text
   OPENAI_API_KEY = sk-...your_key_here...
   ```

4. Ensure the project’s build configuration is using `Secrets.xcconfig` (already referenced in the `.xcodeproj`).

The `Receipt-Finder-Info.plist` reads `OPENAI_API_KEY` from the build settings, which is provided by `Secrets.xcconfig`.

#### 3. Open in Xcode

- Open `Gotcha.xcodeproj` in Xcode.
- Select the **Gotcha** app scheme.
- Choose an iOS Simulator (or a physical device).

#### 4. Build & Run

- Press **Cmd + R** to build and run the app.

---

### Usage

Once the app is running:

1. **Home / Receipts List**  
   You land on `ResultView`, which shows your stored receipts (initially empty) and a search bar at the top.

2. **Add a Receipt**  
   Tap **“Add New Receipt”**.  
   Choose:
   - **Open Camera** – Scan a physical receipt using the device camera.  
   - **Add from Library** – Pick an existing photo of a receipt.

3. **OCR & AI Parsing**  
   After capturing/selecting an image, you’re taken to **Verify Details** (`SaveAsView`).  
   The app:
   - Runs **OCR** on the image.  
   - Sends the recognized text to **OpenAI** for field extraction.  
   The fields (store, date, total, etc.) auto-populate for review.

4. **Review & Save**  
   Optionally edit any field (e.g., correct store name or total).  
   Tap **“Save Receipt”** to persist it in Core Data.

5. **Search**  
   Back on the main list, use the search bar to filter receipts by name; input is debounced for smoother performance.

6. **View Details**  
   Tap any receipt to open `DetailsView`.  
   See all fields plus the original receipt image.  
   Tap the image to open a **zoomable full-screen view** for closer inspection.

---

### Project Structure

```text
Gotcha/
  Views/
    Gotcha.swift                 // App entry point (@main) + RootView
    ContentView.swift            // Welcome screen, optional entry UX
    ResultView.swift             // Receipt list + search + add flow
    SaveAsView.swift             // Verify & save receipt details
    DetailsView.swift            // Receipt details view
    DocumentScannerView.swift    // VisionKit document scanner wrapper
    ChoosePhoto.swift            // PhotosUI picker wrapper
    ZoomableFullScreenImage.swift// Full-screen zoomable image view
    AppTheme.swift               // Colors, gradients, shared styling

  ViewModels/
    ResultViewModel.swift        // Search, selection, navigation for list
    SaveAsViewModel.swift        // OCR + AI pipeline, form state, save logic
    DetailsViewModel.swift       // Detail screen state & image handling

  Models/
    ReceiptRepository.swift      // Core Data persistence for ReceiptItem
    OpenAI.swift                 // OpenAIService for receipt parsing
    OCR.swift                    // OCRHelper for Vision text extraction

Persistence.swift                // Core Data stack (NSPersistentContainer)
Gotcha.xcdatamodeld/             // Core Data model (ReceiptItem entity)
Receipt-Finder-Info.plist        // Info.plist with OPENAI_API_KEY reference
Secrets.xcconfig (local)         // Not committed; holds OPENAI_API_KEY
Secerts-Example.xcconfig         // Example config checked into the repo
```

---

### Key Learnings / Challenges

- **Integrating multiple Apple frameworks**  
  Combined **Vision, VisionKit, PhotosUI, Core Data, and SwiftUI** in a cohesive workflow, handling data and UI boundaries cleanly.

- **Designing a clean MVVM architecture for SwiftUI**  
  Extracted responsibilities into dedicated `ViewModel` classes, isolating business logic from UI code and keeping the Views easy to reason about.

- **Robust AI integration**  
  - Designed a **prompt + `response_format: json_object`** workflow to ensure reliable structured outputs from the OpenAI API.  
  - Implemented error handling and safe parsing pathways for network/API failures.

- **User experience for scanning flows**  
  - Managed navigation between camera/photo picker, analysis screen, and list views without blocking UI.  
  - Implemented **debounced search** for a responsive, professional feel.

### Contact Information

- **Name**: Raj K  
- **Email**: `rajk.dev01@gmail.com`  
- **LinkedIn**: `www.linkedin.com/in/rajk01`  
- **GitHub**: [`github.com/rajk-dev-01`](https://github.com/rajk-dev-01)  

---

### License

```text
Copyright (c) 2025 Raj K
All rights reserved.
```

