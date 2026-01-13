# ⚙️ Configuration Screen Wireframe Concept

This screen will be accessed via the Settings icon (D3) on the Dashboard's bottom navigation bar.

## 1. Header and Navigation

| Element | Description | Notes |
| :--- | :--- | :--- |
| **A1: Back Button** | Icon (e.g., Chevron pointing left). | Allows return to the Dashboard. |
| **A2: Screen Title** | Text: "**Karny Bank Settings & Configuration**" | Clear title. |

## 2. Configuration Parameters (Editable Fields)

This section contains all the variables that need to be adjustable by the parent.

### 2.1 Financial Rates

| Element | Description | Notes |
| :--- | :--- | :--- |
| **B1: Annual Interest Rate** | Input field labeled "Annual Interest Rate (%)". | Default: **2.8**. Must accept decimal values (e.g., 3.5). |
| **B2: Quarterly Bonus Rate** | Input field labeled "Quarterly No-Withdrawal Bonus (%)". | Default: **1.2**. Must accept decimal values. |
| **B3: Bonus Condition Info** | Small text below B2: *"Bonus is only applied if there are ZERO withdrawals in the calendar quarter."* | Clarifies the condition for the bonus rate. |

### 2.2 Allowance Schedule

| Element | Description | Notes |
| :--- | :--- | :--- |
| **C1: Weekly Allowance Day** | Dropdown/Selector labeled "Day for Weekly Allowance Deposit". | Default: **Sunday**. Options: Monday, Tuesday, etc. |
| **C2: Allowance Rule Info** | Small text below C1: *"Allowance equals child's age, updated automatically on their birthday."* | Confirms the calculation logic. |

## 3. Account-Specific Overrides (Optional Advanced Section)

| Element | Description | Notes |
| :--- | :--- | :--- |
| **D1: Section Title** | Text: "**Individual Account Overrides (Advanced)**" | Collapsible section header. |
| **D2: Override List** | A list of children's names. Tapping one opens a sub-menu to temporarily override B1/B2 for that child. | Currently optional, but designed for future proofing. |

## 4. Save and Information

| Element | Description | Notes |
| :--- | :--- | :--- |
| **E1: Warning Box** | Prominent box with essential information. | **Content:** *“Important: All changes made below will only take effect immediately and apply to all future transactions. Past balances and transactions are locked.”* |
| **E2: Save Button** | Large, distinct button: "**Save Changes**". | Must be inactive until changes are made. Tapping it triggers confirmation and update. |

---

## 💡 Flow Example: Changing the Interest Rate

1. Parent navigates to the **Configuration Screen** (D3).
2. Parent changes **B1: Annual Interest Rate** from *2.8* to *3.0*.
3. The **E2: Save Changes** button becomes active.
4. Parent taps **Save Changes**.
5. A confirmation message appears: *"Configuration Updated. The new 3.0% Annual Interest Rate is now active for all accounts."*
6. Parent is automatically navigated back to the Dashboard.