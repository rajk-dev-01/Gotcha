
## Gotcha – Intelligent Receipt Scanner & Organizer

Smart iOS app that helps scan, understand, and organize receipts using on-device OCR and OpenAI for data extraction.

---

### Overview

While learning iOS development, I wanted to build something practical that solves a real-life problem. Many people collect a lot of receipts from both online and offline purchases, and it becomes difficult to track expenses, warranties, or proof of purchase over time. **Gotcha** helps by turning receipt images into structured and searchable records.

The app uses **camera scanning or photo import**, **Apple Vision OCR**, and **OpenAI-based extraction** to automatically pull important details such as store name, date, total amount, and other key information. This makes the app useful for **basic expense tracking, personal record keeping, and small-scale financial organization** for everyday use.

---

### Features

* **Camera-based document scanning**
  

* **Photo library import**


* **On-device OCR**


* **AI-powered field extraction**


* **Structured receipt storage**


* **Fast, debounced search**


* **Detail view with zoom**


* **Modern SwiftUI UI**


* **MVVM architecture**
  

---

### Tech Stack

* **Languages**

  * Swift

* **Frameworks**

  * SwiftUI
  * UIKit (used for camera/document scanner integration)
  * Core Data
  * Vision (OCR)
  * VisionKit (Document Scanner)
  * PhotosUI

* **Libraries / Services**

  * OpenAI Chat Completions API (integrated using `URLSession`)

---

### Installation and Setup

#### Prerequisites

* macOS compatible with **Xcode 16+**
* **Xcode 16+**
* iOS device or simulator (iOS 18+ recommended)
* An **OpenAI API key** with Chat Completions access

#### 1. Clone the repository

```bash
git clone https://github.com/rajk-dev-01/Gotcha.git
cd Gotcha
```

*(Adjust path if your remote repo name differs.)*

#### 2. Configure OpenAI API key

1. In the repo, you’ll find an example config:

   * `Gotcha/Secerts-Example.xcconfig`

2. Create a real secrets file alongside it:

   ```text
   Secrets.xcconfig
   ```

3. Edit `Secrets.xcconfig` and set your key:

   ```text
   OPENAI_API_KEY = sk-...your_key_here...
   ```

4. Make sure the project’s build configuration is using `Secrets.xcconfig` (already referenced in the `.xcodeproj`).

The `Receipt-Finder-Info.plist` reads `OPENAI_API_KEY` from the build settings, which comes from `Secrets.xcconfig`.

#### 3. Open in Xcode

* Open `Gotcha.xcodeproj` in Xcode.
* Select the **Gotcha** app scheme.
* Choose an iOS Simulator or a physical device.

#### 4. Build & Run

* Press **Cmd + R** to build and run the app.

---

### Key Learnings / Challenges

* **Integrating multiple Apple frameworks**
  Learned how to work with **Vision, VisionKit, PhotosUI, Core Data, and SwiftUI** together and connect the full workflow from scanning to storage.

* **Designing a clean MVVM architecture for SwiftUI**
  Implemented a simple MVVM structure by moving business logic into `ViewModel` classes to keep Views cleaner and easier to manage.

* **AI integration**

  * Designed prompts and used **`response_format: json_object`** to get structured responses from the OpenAI API.
  * Added basic error handling and safe parsing for network or API issues.

* **User experience for scanning flows**

  * Managed navigation between scanning, processing, and list screens without blocking the UI.
  * Implemented **debounced search** to keep the app responsive.

---

### Contact Information

* **Name**: Raj K
* **Email**: `rajk.dev01@gmail.com`
* **LinkedIn**:`www.linkedin.com/in/rajk01`
* **GitHub**: [`GitHub Profile`](https://github.com/rajk-dev-01)

---

### License

```text
Copyright (c) 2025 Raj K
All rights reserved.
```



