# 📜 History View Wireframe Concept

This screen will be accessed either via the History icon (D2) in the bottom navigation bar or by tapping the "View History" link (C5) on an individual child's card.

## 1. Header and Navigation

| Element | Description | Notes |
| :--- | :--- | :--- |
| **A1: Back Button** | Icon (e.g., Chevron pointing left). | Allows return to the Dashboard. |
| **A2: Screen Title** | Text: "**Transaction History**" | Clear title. |
| **A3: Filter/Sort Icon** | Small icon (e.g., Funnel/Filter icon). | Accesses the filtering and sorting controls (Section 2). |

## 2. Filtering Controls (Accessed via A3)

These controls should ideally appear in a collapsible panel or an overlay screen to maximize space for the table.

### 2.1 Account Owner Filter

| Element | Description | Notes |
| :--- | :--- | :--- |
| **B1: Account Owner Filter** | Dropdown labeled "Filter by Account Owner". | Options: **All Accounts** (Default), Maayan, Tomer, Or. *Note: If accessed from C5 on the Dashboard, this will be pre-filtered.* |

### 2.2 Transaction Type Filter

| Element | Description | Notes |
| :--- | :--- | :--- |
| **B2: Type Filter** | Multi-select checkbox/tag list labeled "Transaction Type". | Options (must be selectable independently): **Deposits** (all), **Withdrawals**, **Allowance**, **Interest**, **Bonus**, **Manual Deposit**, **Manual Withdrawal**. |
| **B3: Filter Presets** | Option to quickly select broad categories. | Options: **All Deposits**, **All Withdrawals**, **All Transactions** (Default). |

### 2.3 Date Range Filter

| Element | Description | Notes |
| :--- | :--- | :--- |
| **B4: Date Range Selector** | Two input fields: "Start Date" and "End Date". | Uses a calendar picker for date selection. Default: Last 90 days. |
| **B5: Apply Filters** | Button to confirm selection. | Applies the chosen filters to the table (Section 3). |

## 3. Transaction Table (Main View)

The table occupies the largest area of the screen, displaying the historical data.

### 3.1 Table Header (Columns)

| Column | Content | Notes |
| :--- | :--- | :--- |
| **C1: Date/Time** | Date and time stamp of the transaction. | Sortable (Newest to Oldest/Oldest to Newest). |
| **C2: Owner** | The account holder's name (Maayan, Tomer, Or). |
| **C3: Type** | Specific type: Allowance, Bonus, Interest, Manual Deposit, Withdrawal. |
| **C4: Amount (ILS)** | The value of the transaction. | Uses Green for Deposits (+ILS), Red for Withdrawals (-ILS). |
| **C5: New Balance (ILS)** | The account balance *after* the transaction occurred. | Essential for tracing history. |

### 3.2 Data Rows

* Each row represents one transaction, ordered by C1.
* The table should be scrollable.

## 4. Navigation (Bottom Bar)

The persistent navigation bar (Dashboard, History, Settings) remains at the bottom of the screen.

---

## 💡 Flow Example: Checking Or's Bonuses

1. Parent taps the **A3: Filter Icon** on the History View.
2. Parent sets **B1: Account Owner Filter** to 'Or'.
3. Parent selects only the **Bonus** checkbox under **B2: Type Filter**.
4. Parent taps **B5: Apply Filters**.
5. The **Transaction Table (3.1)** refreshes to show only the rows where **Owner** is 'Or' and **Type** is 'Bonus' (e.g., four rows per year).