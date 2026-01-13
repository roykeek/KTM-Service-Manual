# 🖼️ Dashboard Wireframe Concept

This wireframe is based on a standard mobile phone portrait orientation.

## 1. Top Section (Header and Utility)

| Element | Description | Notes |
| :--- | :--- | :--- |
| **A1: App Logo & Name** | "Karny Bank" logo/icon. | Top Left. Branding element. |
| **A2: Exit Button** | Icon (e.g., Door or Logout symbol). | Top Right. Clear button to close the application or log out of the parent view. |
| **A3: Calculator Icon** | Small calculator icon. | Below A2. Tapping this opens a quick, floating calculator overlay. |

## 2. Main Action Area

This area provides the two most critical manual actions for the parent.

| Element | Description | Notes |
| :--- | :--- | :--- |
| **B1: Deposit Button** | Large, prominent button with text "Deposit Money". | Uses the **Success/Green** color scheme. Tapping this triggers the account/amount prompt. Includes the **Deposit Animation** upon confirmation. |
| **B2: Withdrawal Button** | Large, prominent button with text "Withdraw Money". | Uses the **Warning/Orange** color scheme. Tapping this triggers the account/amount prompt and the **Withdrawal Guardrail**. Includes the **Withdrawal Animation** upon confirmation. |

## 3. Account Overview (Cards)

This is the central information area, displaying key metrics for each child in clear, scrollable cards. Cards should fill the width of the screen.

### Card Structure (Repeated for Maayan, Tomer, and Or)

| Element | Description | Notes |
| :--- | :--- | :--- |
| **C1: Child's Name & Photo/Avatar** | Name is clearly visible. | Helps in quick identification. |
| **C2: Current Balance** | The total amount in the account (e.g., **1,560.00 ILS**). | **Largest, boldest text** on the card. Uses the **Soft Teal** accent color. |
| **C3: Last Deposit** | Date and Amount (e.g., Last Deposit: 14 ILS (Nov 24)). | Smaller text below the balance. |
| **C4: Last Withdrawal** | Date and Amount (e.g., Last Withdrawal: 20.00 ILS (Nov 15)). | Smaller text below C3. |
| **C5: View History Button** | Small link/button at the bottom of the card. | Tapping this navigates to the History View, pre-filtered for *that specific child*. |

## 4. Navigation (Bottom Bar)

A persistent navigation bar at the bottom for easy access to core features.

| Element | Description | Notes |
| :--- | :--- | :--- |
| **D1: Dashboard Icon** | Home/House icon. | Returns to the main screen. |
| **D2: History Icon** | List/Clock icon. | Navigates to the comprehensive **History View** (all accounts, default filter). |
| **D3: Settings Icon** | Gear/Cog icon. | For accessing the **Configuration** panel (to adjust interest, bonus, etc.). |

---

## 💡 Flow Example: Manual Deposit

1. Parent is on the **Dashboard**.
2. Parent taps the **B1: Deposit Button**.
3. **Overlay Prompt Appears:**
    * Dropdown Menu: Select Account Owner (Maayan, Tomer, Or).
    * Input Field: Enter Amount (ILS).
    * Buttons: Cancel / Confirm.
4. Parent selects 'Maayan' and enters '50.00'. Taps **Confirm**.
5. **Deposit Animation (5.2)** plays briefly on screen.
6. A success message appears, immediately followed by the **Financial Tip (3.3)** pop-up, which closes after 5 seconds or a tap.
7. Maayan's **C2: Current Balance** updates instantly on the dashboard.