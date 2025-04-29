# 🌌 Cosmic Wisdom Contract

A decentralized system for recording and managing "cosmic insights"—discoveries that span the vast universe of knowledge domains. This contract enables stargazers (users) to submit, verify, revise, and manage insightful data in a structured and permissioned way on-chain.

---

## ✨ Features

- Record new cosmic insights with detailed metadata.
- Grant observation rights to specific observers.
- Validate insight attributes and domains.
- Transfer discovery credit to other stargazers.
- Edit or erase previously recorded insights.
- Secure and permissioned system with clear error signaling.

---

## 🛠 Tech Stack

- **Language:** Clarity (Stacks smart contracts)
- **Blockchain:** Stacks (built on Bitcoin)
- **Contract Architecture:** Modular, secure, and extensible

---

## 📚 Core Concepts

### Insight
A structured discovery with:
- Title
- Magnitude (importance)
- Observation notes
- Knowledge domains (max 10)

### Roles
- **Galaxy Overseer:** Central authority (set as `tx-sender`)
- **Stargazer:** Insight discoverer and contributor
- **Observer:** Granted access to observation notes

---

## 🔐 Security & Validation

- Only discoverers can revise or delete insights.
- All text fields are length-validated.
- Knowledge domains are strictly vetted.
- Unique identifiers assigned automatically via an internal counter.

---

## 📦 Contract Structure

### Key Maps & Variables

| Name | Description |
|------|-------------|
| `cosmic-insights-archive` | Stores all insights |
| `observation-privileges` | Access rights ledger |
| `universal-insight-counter` | Auto-incrementing ID system |

---

## ⚙️ Functions

### Public

- `document-cosmic-insight`: Adds a new insight
- `access-insight-notes`: Retrieves notes for an insight
- `verify-observer-credentials`: Checks access rights
- `count-insight-domains`: Counts domains associated with an insight
- `verify-title-compliance`: Validates title format
- `transfer-insight-attribution`: Reassigns discovery credit
- `revise-insight-record`: Edits an insight
- `erase-cosmic-insight`: Deletes an insight

### Private

- `insight-exists?`
- `is-original-discoverer?`
- `validate-textual-field`
- `validate-knowledge-domain?`
- `validate-all-knowledge-domains?`
- `increment-insight-counter`

---

## 🚀 Getting Started

### Requirements

- [Clarity tools](https://docs.stacks.co/write-smart-contracts/clarity-smart-contracts/overview)
- [Clarinet](https://docs.stacks.co/clarity-cli/clarinet)

### Build & Test

```bash
clarinet check
clarinet test
```

### Deploy

```bash
clarinet deploy
```

---

## 🧪 Example: Documenting an Insight

```clojure
(document-cosmic-insight 
  "Entropy Spiral" 
  u988 
  "Observed at the edge of a supercluster" 
  (list "physics" "cosmology" "philosophy")
)
```


---

## 🌠 Contributing

Pull requests and stargazers are welcome! For major changes, please open an issue first to discuss what you would like to change.
