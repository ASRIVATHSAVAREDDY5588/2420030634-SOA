# 💰 System Architecture & SOA Design Document

## 1. Executive Architectural Overview

The **AI EXPENSE TRACKING** application is engineered based on **Service-Oriented Architecture (SOA)** and **Privacy-First Distributed System** patterns. Personal financial management requires zero latency, complete data privacy, high visual responsiveness, and trustworthy intelligent automation.

The system addresses critical challenges in modern consumer finance applications:
1. **Local Data Sovereignty:** Financial logs, bank statements, and personal transactions are stored strictly in the client-side local datastore. No cloud databases or third-party tracking services ever receive personal spending logs.
2. **Perimeter Proxy Isolation:** The Google Gemini API key is encapsulated in a dedicated server-side proxy boundary. The client never handles, bundles, or leaks API credentials.
3. **Graceful Fault Tolerance:** If remote AI services are unreachable, offline, or rate-limited, the system falls back to an embedded local financial analysis engine without service disruption.

---

## 2. Service-Oriented Decomposition

```mermaid
graph TB
    subgraph Client Application Layer
        UI[Modern Responsive Web & PWA Shell]
        SW[Service Worker: Cache-First Asset Engine]
        Command[Command Palette & Keyboard Shortcut Bus]
    end

    subgraph Perimeter & API Proxy Layer
        Server[Perimeter HTTP Server :3000<br/>Loopback Bound 127.0.0.1 & Strict CORS]
        AuthProxy[Gemini AI Encapsulation Proxy]
    end

    subgraph Autonomous Domain Services
        StorageSvc[STORAGE-SERVICE<br/>Local Data Store, Schema Validation & Backup]
        AiScanSvc[AI-RECEIPT-SCAN-SERVICE<br/>Multimodal Vision & JSON Normalizer]
        AnalyticsSvc[ANALYTICS-ENGINE-SERVICE<br/>Burn Rate, Pace Calculator & Fallback Logic]
        ExportSvc[EXPORT-SERVICE<br/>Dynamic On-Demand PDF & Excel Generators]
        GamifySvc[GAMIFICATION-SERVICE<br/>Streak Tracker, Quest Rules & Badge Evaluator]
        CategorySvc[CATEGORY-DETECTION-SERVICE<br/>Real-Time Keyword & Merchant Pattern Matcher]
    end

    subgraph External Intelligence Provider
        Gemini[Google Gemini 2.5 Flash API]
    end

    UI --> SW
    UI --> Command
    UI --> StorageSvc
    UI --> AnalyticsSvc
    UI --> ExportSvc
    UI --> GamifySvc
    UI --> CategorySvc

    UI -->|HTTPS /api/*| Server
    Server --> AuthProxy
    AuthProxy -->|gRPC/REST with Server API Key| Gemini
```

### SOA Principles Implemented:
- **Service Loose Coupling:** The frontend UI is decoupled from the AI processing engine. If the AI proxy endpoint is down, 100% of expense tracking, budget meters, and ledger operations remain functional.
- **Service Abstraction:** The client interacts with uniform contracts (`/api/scan-receipt`, `/api/spending-insights`, `/api/status`) without knowing model parameters or prompt engineering details.
- **Service Autonomy:** Each service (Storage, Analytics, Gamification, Export) owns its business logic and data structures independently.
- **Service Reusability:** The `categoryDetector` and `exportService` can be utilized across CLI, web, or mobile runtimes without modification.

---

## 3. Component Interaction & Sequence Diagrams

### 3.1 AI Receipt Scanning Pipeline (Zero Silent Saving Guard)

```mermaid
sequenceDiagram
    autonumber
    actor User as 👤 User
    participant UI as 📱 Transaction Modal
    participant Proxy as 🛡️ Server Proxy (:3000)
    participant Gemini as 🤖 Gemini 2.5 Flash
    participant Storage as 💾 Storage Service

    User->>UI: Uploads / Captures receipt photo
    UI->>Proxy: POST /api/scan-receipt (Base64 image + MIME)
    Proxy->>Proxy: Validate payload & check size limit (<= 15MB)
    Proxy->>Gemini: generateContent (Multimodal Vision + Strict JSON Schema)
    Gemini-->>Proxy: Returns extracted JSON (Merchant, Amount, Date, Category)
    Proxy-->>UI: HTTP 200 OK (Structured Receipt Data)
    UI->>UI: Pre-populates form fields with visual confirmation
    Note over UI,User: Safety Guard: Extracted details are NEVER silently saved.
    User->>UI: Reviews, modifies fields, and clicks 'Save Expense'
    UI->>Storage: saveTransaction(newTransaction)
    Storage-->>UI: Transaction saved & Gamification points updated
```

---

### 3.2 Spending Insights & Graceful Fallback Choreography

```mermaid
sequenceDiagram
    autonumber
    actor User as 👤 User
    participant Analytics as 📊 Analytics View
    participant ClientSvc as ⚙️ geminiService.ts
    participant Proxy as 🛡️ Server Proxy (:3000)
    participant LocalEngine as 🧠 Local Smart Analyzer

    User->>Analytics: Clicks 'Analyze My Spending' or Prompt Chip
    Analytics->>ClientSvc: getSpendingInsights(transactions, currency)
    ClientSvc->>Proxy: POST /api/spending-insights (Anonymized transaction list)
    
    alt Remote Gemini Available & Key Configured
        Proxy-->>ClientSvc: HTTP 200 OK with 3 Grounded Suggestions
        ClientSvc-->>Analytics: Displays AI Spending Coach observations
    else Remote AI Unavailable / Rate-Limited / Missing Key
        Proxy-->>ClientSvc: HTTP 401 / 503 structured notice
        ClientSvc->>LocalEngine: generateLocalInsights(transactions, currency)
        LocalEngine-->>ClientSvc: Instant deterministic grounded financial audit
        ClientSvc-->>Analytics: Displays local smart observations with zero downtime
    end
```

---

### 3.3 Verified Backup & Restore Flow (Safety Guard)

```mermaid
flowchart TD
    A[📁 User selects backup JSON file] --> B[Read file in memory]
    B --> C{validateBackupData: Check schema structure}
    C -- Invalid Schema / Missing Fields --> D[🚫 Reject Import: Show error banner<br/>Leave user's current data completely untouched]
    C -- Valid Schema --> E[Create atomic snapshot of current state]
    E --> F[Replace user profile & transactions in localStorage]
    F --> G[✅ HTTP / UI Reload: Fresh state rendered]
```

---

## 4. Security Architecture & Boundary Isolation

1. **Loopback IP Binding:**
   - The production server binds exclusively to `127.0.0.1:3000` (loopback) by default, preventing unintended exposure across local area networks.
2. **CORS Perimeter Control:**
   - Strict CORS origin whitelisting (`http://localhost:3000`, `http://127.0.0.1:3000`, `http://localhost:5173`).
3. **Zero Browser Key Exposure:**
   - The Google Gemini API key resides strictly in the root `.env` file on the server.
   - The Vite build configuration never includes API keys in client bundles.
4. **Local Data Sovereignty:**
   - All income, expenses, account balances, and notes persist strictly inside the user's browser `localStorage`.
   - Backup files are exported as verified JSON directly to the user's disk.

---

## 5. Entity Relationship & Data Model Specifications

```mermaid
erDiagram
    USER_PROFILE ||--o{ TRANSACTION : records
    USER_PROFILE ||--o{ ACCOUNT : owns
    USER_PROFILE ||--|| BUDGET_CONFIG : defines
    USER_PROFILE }o--o{ BADGE : unlocks

    USER_PROFILE {
        string name
        string email
        string avatar
        string currency
        number points
        number currentStreak
        number longestStreak
        string lastTransactionDate
        boolean hasCompletedTour
    }

    TRANSACTION {
        string id PK
        string type "income | expense"
        number amount
        string category
        string title
        string date "ISO8601"
        string notes
        string accountId FK
    }

    ACCOUNT {
        string id PK
        string name
        string type "bank | cash | credit | other"
        number balance
    }

    BUDGET_CONFIG {
        number amount
        string period "weekly | monthly | yearly"
        object categoryLimits
    }

    BADGE {
        string id PK
        string name
        string description
        string icon
    }
```

---

## 6. Progressive Web App (PWA) & Offline Capabilities

- **Service Worker Lifecycle:** Utilizes `vite-plugin-pwa` with Workbox to precache application assets (`index.html`, bundled JS, CSS, fonts, and icons).
- **Navigation Route Strategy:** Fallback to cached `index.html` on network disconnection, ensuring the entire web app works offline.
- **Dynamic Asset Chunking:** Large external dependencies (`xlsx`, `jspdf`, `jspdf-autotable`) are lazily loaded on demand when the user triggers an export, keeping initial bundle load under 200 KB gzipped.
