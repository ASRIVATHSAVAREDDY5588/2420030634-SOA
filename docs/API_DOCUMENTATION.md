# 📡 REST API Documentation

The **AI EXPENSE TRACKING** application features a dedicated backend service running on Node.js that encapsulates Google Gemini AI integration and provides health and status contracts.

- **Base URL:** `http://127.0.0.1:3000`
- **Default Format:** `application/json`
- **Security:** Perimeter loopback binding (`127.0.0.1`) with origin-checked CORS.

---

## 📑 Summary of Endpoints

| Category | Method | Endpoint | Access Level | Description |
| :--- | :--- | :--- | :--- | :--- |
| **System** | `GET` | `/api/status` | Public / Local | Returns service health, configured AI model, and API key presence. |
| **Receipt OCR** | `POST` | `/api/scan-receipt` | Public / Local | Extracts merchant, total amount, date, and category from a receipt image. |
| **Analytics AI** | `POST` | `/api/spending-insights` | Public / Local | Generates 3 personalized, grounded spending recommendations. |
| **Static Shell** | `GET` | `/` | Public / Local | Delivers the responsive Single Page Application and offline PWA shell. |

---

## 🔍 Detailed Endpoint Specifications

### 1. Service Health & Status Check

Retrieves the runtime status of the server and confirms whether Google Gemini credentials are active.

- **Endpoint:** `GET /api/status`
- **Headers:** None required

#### Success Response (`HTTP 200 OK`):
```json
{
  "status": "ok",
  "app": "AI EXPENSE TRACKING",
  "hasGeminiKey": true,
  "model": "gemini-2.5-flash"
}
```

#### cURL Example:
```bash
curl -X GET http://127.0.0.1:3000/api/status
```

---

### 2. AI Receipt Scanning (OCR & Feature Extraction)

Accepts an image of a receipt in base64 encoding and utilizes Google Gemini Multimodal Vision to extract transaction fields.

- **Endpoint:** `POST /api/scan-receipt`
- **Headers:** `Content-Type: application/json`

#### Request Payload:
```json
{
  "base64Image": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==",
  "mimeType": "image/jpeg"
}
```

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `base64Image` | `string` | **Yes** | Base64-encoded image data string (max 15 MB). |
| `mimeType` | `string` | No | Image MIME type (`image/jpeg`, `image/png`, `image/webp`). Defaults to `image/jpeg`. |

#### Success Response (`HTTP 200 OK`):
```json
{
  "success": true,
  "data": {
    "title": "Starbucks Coffee",
    "amount": 250.00,
    "date": "2026-10-28",
    "category": "Food"
  }
}
```

#### Error Responses:
- **`HTTP 400 Bad Request`**:
  ```json
  {
    "success": false,
    "error": "Missing base64Image in request body."
  }
  ```
- **`HTTP 500 Internal Server Error`**:
  ```json
  {
    "success": false,
    "error": "Failed to parse receipt image."
  }
  ```

#### cURL Example:
```bash
curl -X POST http://127.0.0.1:3000/api/scan-receipt \
  -H "Content-Type: application/json" \
  -d '{"base64Image":"...base64...","mimeType":"image/jpeg"}'
```

---

### 3. AI Spending Insights Generation

Analyzes an array of recent transaction records and returns 3 grounded, actionable budgeting observations.

- **Endpoint:** `POST /api/spending-insights`
- **Headers:** `Content-Type: application/json`

#### Request Payload:
```json
{
  "transactions": [
    {
      "id": "tx_1",
      "type": "expense",
      "amount": 1200,
      "category": "Food",
      "title": "Supermarket Groceries",
      "date": "2026-10-28T12:00:00.000Z",
      "account": "Bank Account"
    },
    {
      "id": "tx_2",
      "type": "income",
      "amount": 45000,
      "category": "Salary",
      "title": "Monthly Paycheck",
      "date": "2026-10-25T09:00:00.000Z",
      "account": "Bank Account"
    }
  ]
}
```

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `transactions` | `Array<Transaction>` | **Yes** | List of recorded transaction objects. |

#### Success Response (`HTTP 200 OK`):
```json
{
  "success": true,
  "insights": "• **Top Category Impact:** Your highest expense area is **Food** (₹1,200), accounting for 100% of recorded expenses.\n\n• **Strong Savings Ratio:** You are retaining **97%** of your total income. Excellent cashflow surplus.\n\n• **Budgeting Tip:** Set a monthly category cap on dining out to preserve your surplus."
}
```

#### Error Handling & Structured Notifications:
- **`HTTP 401 Unauthorized`** (Invalid or Missing API Key):
  ```json
  {
    "success": false,
    "error": "Invalid Google Gemini API key. Note: Google Gemini API keys from Google AI Studio typically start with \"AIzaSy...\". Please verify your key at https://aistudio.google.com/ and update your .env file."
  }
  ```

#### cURL Example:
```bash
curl -X POST http://127.0.0.1:3000/api/spending-insights \
  -H "Content-Type: application/json" \
  -d '{"transactions":[{"id":"1","title":"Cafe","amount":150,"type":"expense","category":"Food","date":"2026-10-28"}]}'
```

---

## 🛡️ Error Contract Schema

All server API errors adhere to a consistent error schema:

```typescript
interface ApiErrorResponse {
  success: false;
  error: string;
}
```

When client-side code (`services/geminiService.ts`) detects a non-200 response from `/api/spending-insights`, it automatically invokes the local deterministic financial analyzer, guaranteeing zero downtime.
