# 🏦 Karny Bank App Design Document

## 1. Introduction

### 1.1 Purpose
This document outlines the design, features, and technical specifications for the "Karny Bank" mobile banking application, designed to manage the weekly allowances, savings, and financial education for Maayan, Tomer, and Or.

### 1.2 Goals
* Provide a transparent and engaging platform for kids to track their money (deposits, withdrawals, and interest/bonuses).
* Automate complex calculations like weekly allowance and savings bonuses.
* Offer parents easy management and configuration options.
* Incorporate educational elements through financial tips.
* Ensure a user-friendly interface with light, appealing aesthetics.

## 2. Target Users

| User Group | Profile | Primary Needs |
| :--- | :--- | :--- |
| **Parent (Primary User)** | Manager and administrator of all accounts. | Easy configuration, manual transaction entry, and overview of all accounts. |
| **Kids (Secondary Users)** | Account holders and consumers of the app's main data. | Clear view of their current balance and transaction history. |

## 3. Functional Requirements and Logic

### 3.1 Account Management and Configuration

* **Currency:** All transactions and balances must be in **ILS (Israeli Shekel)**.
* **Account Holders:**
    * **Maayan:** Born 16 August, 2011. Allowance = **14 ILS** (age 14 in 2025).
    * **Tomer:** Born 28 April, 2014. Allowance = **11 ILS** (age 11 in 2025).
    * **Or:** Born 21 January, 2016. Allowance = **9 ILS** (age 9 in 2025).
* **Allowance Logic:** Weekly allowance is automatically deposited every week (e.g., every Sunday) and equals the child's current age. This value updates annually on their birthday.
* **Interest Rate:** Configurable (Default: **2.8%** per annum). Applied and compounded annually.
* **Bonus Rate:** Configurable (Default: **1.2%** of current balance).
    * **Bonus Logic:** Applied at the end of every quarter (e.g., March 31, June 30, September 30, December 31). A bonus is only given if there have been **NO withdrawals** in that specific quarter.

### 3.2 Transaction Features

* **Automatic Transactions:**
    * Weekly Allowance Deposit
    * Quarterly No-Withdrawal Bonus Deposit
    * Annual Interest Application
* **Manual Transactions (Parent Interface):**
    * **Manual Deposit/Withdrawal:**
        1. Parent taps the Deposit or Withdrawal button.
        2. A prompt appears asking: "**Select Account Owner**" (Dropdown: Maayan, Tomer, Or) and "**Enter Amount (ILS)**".
        3. The transaction is recorded and the balance is updated.
* **Withdrawal Guardrail:**
    * If **Withdrawal Amount > Current Balance**, display a message: *"Insufficient funds! The withdrawal of [Amount] ILS is larger than the current balance of [Balance] ILS."*
    * **Suggestion:** Offer a suggestion: *"Would you like to set a **goal** for this item, or reduce the withdrawal amount?"*

### 3.3 Financial Tip Integration

* After every successful **Manual Deposit**, a financial tip must be displayed.
* **Format:** Smart, humorous, and age-appropriate (e.g., *"Did you know? Saving money is like having a superpower, except instead of flying, you can buy awesome stuff later!"*).

## 4. User Interface (UI) Design

### 4.1 Color Palette and Aesthetics
* **Easy on the Eyes:** Use a light, soft palette with a main accent color (e.g., a calming blue or seafoam green) and secondary colors for positive/negative transactions.
* **Suggested Palette:**
    * **Background:** Off-White / Light Grey ($\#F8F8F8$)
    * **Accent Color (Primary):** Soft Teal / Light Blue ($\#4DB6AC$)
    * **Success (Deposit/Balance):** Light Green ($\#81C784$)
    * **Warning (Withdrawal/Error):** Soft Orange / Red ($\#FFB74D$)

### 4.2 Dashboard Layout

The dashboard is the main screen, designed for quick overview and action. 

| Component | Content | Design/Interaction Notes |
| :--- | :--- | :--- |
| **Header** | App Logo ("Karny Bank") and Title. |
| **Account Overview Cards** | A separate card for each child (Maayan, Tomer, Or). | Each card should prominently feature the child's name and avatar (if available). |
| **Card Details (per child)** | * **Current Balance (Large Font, Green/Teal)** * **Last Deposit** (Date and Amount) * **Last Withdrawal** (Date and Amount) | Use the accent color for the balance. Use small arrow icons to indicate transaction type. |
| **Action Buttons** | **Deposit Money** and **Withdraw Money** | Clear, distinct buttons to initiate manual transactions. |
| **Utility Bar** | **Small Calculator Icon** and **Exit Button** | Calculator pops up on the screen for quick calculations. Exit button closes/logs out of the app. |

### 4.3 History View (Transaction Table)

A separate screen accessible from the dashboard.

* **View:** Tabular format.
* **Columns:** **Date**, **Time**, **Account Owner**, **Transaction Type**, **Amount (ILS)**, **New Balance**.
* **Filtering Options (Must-haves):**
    * All Transactions
    * Deposits (Manual + Allowance + Interest + Bonus)
    * Withdrawals
    * Allowance
    * Interest
    * Bonus
    * **Date Range Selector**

## 5. User Experience (UX) and Animation

### 5.1 Animation Touches
Light and subtle animations should be used to enhance engagement without slowing down the app.

* **Dashboard:** Account cards gently slide into view upon app launch.
* **Button Taps:** Subtle ripple or color-change effect upon button press.

### 5.2 Transaction Animations (Crucial)

| Transaction Type | Animation/Feedback |
| :--- | :--- |
| **Manual Deposit** | A visual representation of money flowing *into* the account (e.g., coins flying up and collecting into the balance display). A positive sound/chime. |
| **Manual Withdrawal** | A visual representation of money flowing *out of* the account (e.g., coins tumbling down and away from the balance display). A subtle, neutral sound. |

## 6. Technical Specifications (Configuration)

The following parameters must be stored in a configuration file or database and be easily editable by the parent.

| Parameter | Default Value | Notes |
| :--- | :--- | :--- |
| Annual Interest Rate | $2.8\%$ | Applied annually. |
| Quarterly Bonus Rate | $1.2\%$ | Applied quarterly if no withdrawals occurred. |
| Weekly Allowance Day | Sunday | Configurable day of the week for automated deposit. |
| Transaction History Retention | Forever | All history must be kept for transparency and record-keeping. |