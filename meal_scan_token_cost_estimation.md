# Meal Scan Token & Cost Estimation Guide

This guide outlines the estimated token usage and financial costs for scanning food meals in **NutriScan Calorie Tracker** across different AI cloud providers, including how Prompt/Context Caching affects cost.

---

## 1. Token Usage Breakdown (Per Scan)

Every meal scan transmits the system instructions, the user prompt/hint, the meal image, and receives a structured JSON response.

| Component | Tokens (Input) | Tokens (Output) | Details |
|---|---|---|---|
| **System Prompt** | ~275 | - | Clinician/Nutritionist rules and JSON output schema (~1,100 chars) |
| **User Prompt & Hint** | ~75 | - | User instructions + descriptive hint (e.g., "Chicken Salad") |
| **Meal Image (Gemini)** | ~258 | - | Flat rate token count used by Gemini 1.5/2.5/3.5 models |
| **Meal Image (Other APIs)** | ~85–255 | - | Low detail mode (85), high detail mode (255) for OpenAI/Claude/Grok |
| **JSON Response** | - | ~200 | Estimated nutrition data (name, calories, macros, notes) |

### Estimated Total Tokens Per Scan:
* **Gemini (Flash/Pro)**: **~800 tokens** total (600 input + 200 output)
* **OpenAI / Claude / Grok**: **~635 to 805 tokens** total (435–605 input + 200 output)

---

## 2. Financial Cost Estimate (USD)

Using standard public API pricing, here is the cost breakdown per single scan and for a batch of **1,000 scans** (roughly 3 meals logged daily for a year):

| AI Provider & Model | Cost per 1M Input | Cost per 1M Output | Cost per 1 Scan | Cost for 1,000 Scans |
|---|---|---|---|---|
| **Gemini 1.5/2.5 Flash** | $0.075 | $0.30 | **$0.00010** | **$0.10** (10 cents) |
| **GPT-4o-mini** | $0.15 | $0.60 | **$0.00019** | **$0.19** (19 cents) |
| **Grok Fast / Mini** | $0.60 | $2.40 | **$0.00078** | **$0.78** |
| **Claude 3.5 Haiku** | $0.80 | $4.00 | **$0.00120** | **$1.20** |
| **Grok Latest / Pro** | $2.00 | $10.00 | **$0.00300** | **$3.00** |
| **GPT-4o / Claude 3.5 Sonnet** | $3.00 | $15.00 | **$0.00450** | **$4.50** |

> [!TIP]
> **Gemini Flash** and **GPT-4o-mini** are the absolute cheapest options. **Grok Fast / Mini** is also a great mid-range budget option at just $0.78 per 1,000 scans.

---

## 3. The Impact of Prompt Caching

Prompt Caching allows cloud providers to store frequently used prefixes (like the static system prompt) in memory, so you only pay a fraction of the cost for repeated inputs.

### How it Behaves Across Providers:

1. **Anthropic (Claude) & OpenAI**:
   * **Automatic Cache Hit**: Any consecutive scans or re-evaluations made within **5 minutes** will match the system prompt prefix.
   * **Threshold**: Requires a minimum prefix size of **1,024 tokens**. Since our system prompt + image easily surpasses 1,000 tokens, caching will trigger automatically, reducing input cost by up to 50% for subsequent logs/re-evaluations.

2. **xAI (Grok)**:
   * **Automatic Cache Hit**: xAI API supports prompt caching for repeated prefixes.
   * **Threshold & Duration**: Similar to OpenAI/Claude, Grok automatically caches input prefixes (system prompt + schema) for consecutive requests made within a short window (~5 minutes). It bills cached input tokens at a discounted rate.

3. **Google Gemini**:
   * **No Cache Hit**: Gemini context caching requires a **minimum threshold of 32,768 tokens**. 
   * **Result**: Because our single meal scan prompt is only ~600 tokens, Gemini caching is never activated. You pay the full, standard (yet extremely cheap) rate for every request.

---

## 4. Summary & Recommendation

* **For Everyday Logging (Low Cost)**: **Gemini Flash** or **GPT-4o-mini** are highly recommended. They deliver near-instant results for fractions of a cent per scan.
* **For Grok Users**: **Grok Fast/Mini** offers excellent performance at a very competitive price ($0.78 for 1,000 scans).
* **For High Precision (Maximum Quality)**: **Claude 3.5 Sonnet** or **GPT-4o** should be used. While more expensive, they remain highly affordable at ~$4.50 per 1,000 logs.
