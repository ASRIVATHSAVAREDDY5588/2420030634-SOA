# 🎓 SOA Viva, Examination & Project Defense Guide

This guide is prepared for academic defense, viva examinations, and project demonstrations in **Service-Oriented Architecture (SOA)** courses (Project Code: **2420030634-SOA**, Batch **16**).

---

## ⏱️ Part 1: The 1-Minute Pitch Script

> **Delivery Cue:** Speak calmly, confidently, and clearly. Takes approximately 55 seconds.

"Good morning/afternoon, Sir/Ma'am.

Traditional expense trackers force users to manually enter every detail or demand full access to personal bank accounts, creating severe privacy risks and high user friction.

To solve this, we designed and developed **AI EXPENSE TRACKING**, an enterprise-grade **Service-Oriented Architecture (SOA)** application that combines **Local Data Sovereignty** with **Autonomous AI Services**.

Here is how our architecture works:
1. **Local Privacy Core:** All financial data, transactions, and account records reside entirely in the client-side datastore. No cloud databases ever receive personal financial records.
2. **AI Multimodal OCR Service:** When a user uploads a receipt image, our perimeter proxy routes it to **Google Gemini 2.5 Flash** using strict JSON schema extraction, populating the form for human review before saving.
3. **Decoupled AI Spending Coach with Graceful Fallback:** The application requests intelligent observations from Gemini. If external AI is offline or rate-limited, our system automatically falls back to an embedded deterministic analyzer with zero downtime.
4. **Power-User Productivity:** The platform includes an instant **Command Palette (`Ctrl+K`)**, smart category auto-detection, a universal **Bank CSV Importer**, multi-account tracking, and gamified budget progress.

Our solution adheres to core SOA principles: service abstraction, loose coupling, perimeter credential encapsulation, and offline-first PWA resiliency.

Thank you!"

---

## 💡 Part 2: High-Frequency SOA Viva Questions & Answers

### 1. Why did you choose Service-Oriented Architecture (SOA) for this application?
**Answer:**
SOA enables separation of concerns across autonomous services. By isolating the AI processing engine (`AI-RECEIPT-SCAN-SERVICE`, `ANALYTICS-ENGINE-SERVICE`) from the client presentation and storage domains (`STORAGE-SERVICE`, `EXPORT-SERVICE`), we achieve loose coupling. If the remote AI service experiences latency or downtime, the core expense ledger, budget calculations, and exports continue running without disruption.

---

### 2. How does your architecture enforce security and credential protection?
**Answer:**
We implement a **Perimeter API Proxy Layer**. The Google Gemini API key is never exposed to browser bundles, network traces, or public repositories. It is encapsulated strictly in the backend Node.js environment (`.env`). The backend server enforces loopback binding (`127.0.0.1:3000`) and strict CORS whitelisting, preventing unauthorized third-party origins from invoking our AI endpoints.

---

### 3. What is "Local Data Sovereignty" and why is it important here?
**Answer:**
Financial transactions represent highly sensitive personal data. Rather than sending user transaction logs to an unvetted central cloud database, our architecture treats the user's browser storage as the sovereign datastore. Transaction logs are stored in encrypted/validated `localStorage`, and backups are exported directly to the user's local disk as verified JSON files.

---

### 4. How does your system handle external service failures (e.g. Gemini API downtime)?
**Answer:**
We implement the **Graceful Degradation / Fallback Pattern**:
1. When requesting spending insights, the client calls `/api/spending-insights`.
2. If the server returns `HTTP 401` (invalid key) or `HTTP 503` (service unavailable), the client service catch-handler activates an embedded **Local Intelligent Spending Engine** (`services/geminiService.ts`).
3. This local engine computes category impact percentages, net savings ratios, and daily burn rates deterministically, presenting the user with grounded advice immediately.

---

### 5. What is the contract format between the client and backend?
**Answer:**
All service communications follow strict **RESTful contracts** formatted in JSON:
- `/api/status`: Delivers `{ status, app, hasGeminiKey, model }`.
- `/api/scan-receipt`: Accepts `{ base64Image, mimeType }` and responds with `{ success, data: { title, amount, date, category } }`.
- `/api/spending-insights`: Accepts `{ transactions: [...] }` and responds with `{ success, insights }`.
- Errors consistently return `{ success: false, error: "message" }`.

---

### 6. What is the difference between SOA and Microservices in your context?
**Answer:**
SOA is the architectural paradigm emphasizing coarse-grained business services communicating over standard protocols (HTTP/REST), service autonomy, and interoperability. Microservices is an implementation pattern within SOA emphasizing fine-grained, independently deployable components. Our application adopts SOA principles by dividing responsibilities into distinct domain boundaries: OCR Perception, Spending Intelligence, Storage Validation, and Document Generation.

---

### 7. How does the Universal CSV Importer work?
**Answer:**
The CSV Importer (`components/CsvImportModal.tsx`) acts as an ETL (Extract, Transform, Load) service:
1. **Extract:** Parses raw CSV text handling nested quotes and commas.
2. **Transform:** Inspects headers with fuzzy keyword matching to detect Date, Description, Amount, Category, and Transaction Type. It then passes merchant names into `categoryDetector.ts` to auto-tag categories (e.g., "Starbucks" -> Food).
3. **Load:** Validates records and bulk-inserts them into the active ledger with generated UUIDs.

---

### 8. Explain how the Command Palette (`Ctrl+K`) improves user efficiency.
**Answer:**
Inspired by modern productivity tools (like Linear and Raycast), the Command Palette (`components/CommandPalette.tsx`) acts as a centralized navigation and action broker. In one unified interface, users can search across historical transactions, execute commands (Add Expense, Add Income, Export Excel, Export PDF), or jump between tabs without touching the mouse.

---

### 9. How do you prevent accidental data corruption during JSON backup restores?
**Answer:**
We implement a **Validation Safety Guard** (`services/storageService.ts -> validateBackupData`). Before replacing any state, the system verifies:
1. Root JSON structure and expected version markers.
2. Presence and validity of user profile fields (name, currency, budget object).
3. Array integrity of transaction records (asserting positive numeric amounts, valid ISO dates, and known categories).
If validation fails, the import is aborted with an error banner, leaving the user's existing records completely intact.

---

### 10. How does the PWA (Progressive Web App) service worker function offline?
**Answer:**
Using `vite-plugin-pwa` and Workbox, the application generates a service worker (`sw.js`) that caches all static assets (`.js`, `.css`, `.html`, icons, web manifest) upon initial load with `skipWaiting` and `clientsClaim`. Subsequent requests bypass the network for static assets, enabling the application shell to load instantaneously even in complete airplane mode.

---

## 📚 Part 3: Key Terminology Glossary

| Term | Definition in this Project |
| :--- | :--- |
| **Service-Oriented Architecture (SOA)** | Design pattern where software functionality is provided as autonomous, loosely coupled services communicating via standard contracts. |
| **Loose Coupling** | Design where components know as little as possible about each other; frontend works seamlessly even if backend AI is down. |
| **Service Abstraction** | Hiding internal implementation details (e.g. prompt engineering and vision models) behind clean REST endpoints. |
| **Graceful Degradation** | Ability of a system to maintain partial functionality when external dependencies fail. |
| **Loopback Binding** | Binding the HTTP server exclusively to `127.0.0.1` so only the local machine can connect, avoiding local network exposure. |
| **CORS (Cross-Origin Resource Sharing)** | Browser security mechanism restricting which origins can make HTTP requests to the backend server. |
| **ETL (Extract, Transform, Load)** | Process utilized in the CSV importer to parse, clean, categorize, and store external financial records. |
| **PWA (Progressive Web App)** | Web application providing app-like experiences, installation capabilities, and offline functionality via Service Workers. |

---

## 🎯 Part 4: Demo Checklist for Evaluation

1. **Launch App:** Execute `run-app.cmd` (or `node server.js`) and open `http://127.0.0.1:3000`.
2. **Dashboard Overview:** Highlight Net Balance, Period Budget progress bar, and Safe Daily Spend allowance.
3. **Power-User Shortcuts:** Press **`Ctrl + K`** to open the Command Palette; search a command; press **`?`** to view the Shortcuts Modal.
4. **Fast Entry:** Press **`N`**; enter "Starbucks 150"; demonstrate **Smart Auto-Categorization** to Food; hit **`Ctrl + Enter`** to save.
5. **AI Spending Coach:** Navigate to Analytics; click an AI Prompt Chip (e.g. *Where can I cut costs?*); showcase the grounded bullet observations.
6. **Data Portability:** Open Profile; generate a PDF statement and Excel spreadsheet; demonstrate JSON backup download.
7. **Verification Script:** In a terminal, run `.\test-api.ps1` to demonstrate automated HTTP contract testing with green pass status.
