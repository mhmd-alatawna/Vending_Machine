# Vending Machine (MIPS32)

A console-based vending machine implemented in **MIPS 32** assembly. When run, the program displays a menu of products with prices and current quantities. The user selects an item and inserts coins (from a fixed set of denominations presented by the program) until the balance covers the price. The program then dispenses the item and returns any change.

## Features

* **Dynamic menu:** Only in-stock items are shown; any product with quantity **0** is hidden and cannot be selected.
* **Coin input:** User inserts coins by choosing from a fixed set of denominations, one coin at a time.
* **Change & validation:** Handles insufficient funds, exact payment, and returns change when applicable. Rejects invalid selections and prevents purchases if credit is insufficient.

## Manager Mode

* Accessible directly from the main menu.
* **PIN:** `1234`
* Allows the manager to **restock** products (update available quantities). After restocking, items reappear in the user menu if their quantity is greater than zero.

## How to Run

1. Open the source in a MIPS simulator (e.g., **MARS** or **QtSPIM**).
2. Assemble/build the program.
3. Run and follow the on-screen prompts:

   * Select a product.
   * Insert coins until the price is covered.
   * Receive the product and any change.
   * Use **Manager Mode** to restock when needed.

> Notes:
>
> * Coin denominations are fixed by the program and chosen via menu.
> * The program is defensive against edge cases (insufficient credit, out-of-stock items, and change handling).
