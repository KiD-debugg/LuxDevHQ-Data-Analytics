"""
Kiosk Manager - Capstone Project
================================

A command-line management system for a small Nairobi kiosk. It tracks stock,
records sales, reports on the day's trading, and keeps all data saved
between runs.

Author  : Benjamin Ochieng (group capstone; team roles in README.txt)
Scope   : Built using Session 1-6 skills only (variables, conditionals,
          loops, functions, dict/list/tuple/set, strings and file handling).

Data structures
---------------
inventory      dict   {product_name: {"price": int, "quantity": int}}
sales_log      list   one tuple per sale: (item, quantity, unit_price, total)
products_sold  set    unique product names sold during this session

Files (created in the folder the program is run from)
-----------------------------------------------------
inventory.txt    Current stock, one product per line: name,price,quantity.
                 Overwritten on exit so the next run starts where this ended.
sales_log.txt    Permanent sales history: item,quantity,unit_price,total.
                 Appended to on exit so previous sessions are never lost.
restock_alerts.txt
                 Products at or below the low-stock threshold, written on
                 exit as a shopping list for the wholesaler.
"""

import os  # Only used for os.path.exists() when checking for the save file.

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
# Keeping file names and business rules in one place means a change only has
# to be made once, instead of hunting through the functions below.
INVENTORY_FILE = "inventory.txt"
SALES_LOG_FILE = "sales_log.txt"
ALERTS_FILE = "restock_alerts.txt"

# A product at or below this quantity is flagged as low stock.
LOW_STOCK_THRESHOLD = 5

# Starting stock used the very first time the program runs (no save file yet).
# Prices are in Kenya shillings (KES) and are illustrative.
DEFAULT_INVENTORY = {
    "Bread": {"price": 65, "quantity": 20},
    "Milk": {"price": 60, "quantity": 30},
    "Sugar": {"price": 180, "quantity": 15},
    "Maize Flour": {"price": 140, "quantity": 12},
    "Cooking Oil": {"price": 180, "quantity": 10},
    "Eggs": {"price": 20, "quantity": 60},
}


# ---------------------------------------------------------------------------
# Input helpers
# ---------------------------------------------------------------------------
# Every piece of user input passes through one of these functions. Validating
# in one place keeps the feature functions short and means a typo can never
# crash the program.

def clean_name(raw_text):
    """Return a name in a consistent format: trimmed and Title Case.

    Commas are replaced with spaces because the save files use commas as
    separators. A comma inside a product name would corrupt the file on the
    next load.
    """
    return raw_text.replace(",", " ").strip().title()


def is_whole_number(text):
    """Return True if text is made up only of digits (e.g. '25').

    isdecimal() is used rather than isdigit() because isdigit() also accepts
    characters such as '²', which int() cannot convert and would crash on.
    """
    return text.isdecimal()


def ask_for_text(prompt):
    """Keep asking until the user types something other than blank space."""
    while True:
        answer = clean_name(input(prompt))
        if answer != "":
            return answer
        print("  Input cannot be empty. Please try again.")


def ask_for_positive_int(prompt):
    """Keep asking until the user enters a whole number greater than zero."""
    while True:
        answer = input(prompt).strip()
        if is_whole_number(answer) and int(answer) > 0:
            return int(answer)
        print("  Please enter a whole number greater than zero.")


# ---------------------------------------------------------------------------
# File handling
# ---------------------------------------------------------------------------

def load_inventory(filename):
    """Load stock from a save file, or fall back to the default inventory.

    Each line is expected as: name,price,quantity
    Malformed lines are skipped and counted rather than stopping the load,
    so one bad line cannot lock the owner out of their whole inventory.
    """
    if not os.path.exists(filename):
        print("  No save file found. Starting with the default inventory.")
        # Copy each inner dict so edits during this session never alter the
        # DEFAULT_INVENTORY constant itself.
        return {name: dict(details) for name, details in
                DEFAULT_INVENTORY.items()}

    inventory = {}
    skipped_lines = 0

    with open(filename, "r") as file:
        for line in file:
            parts = line.strip().split(",")

            # A valid line has exactly 3 fields, and the last two must be
            # whole numbers.
            if (len(parts) == 3 and parts[0].strip() != ""
                    and is_whole_number(parts[1].strip())
                    and is_whole_number(parts[2].strip())):
                name = clean_name(parts[0])
                inventory[name] = {
                    "price": int(parts[1]),
                    "quantity": int(parts[2]),
                }
            elif line.strip() != "":
                skipped_lines += 1

    if skipped_lines > 0:
        print(f"  Warning: {skipped_lines} unreadable line(s) in "
              f"{filename} were skipped.")

    if not inventory:
        print("  Save file held no usable stock. Using the default "
              "inventory.")
        return {name: dict(details) for name, details in
                DEFAULT_INVENTORY.items()}

    print(f"  Loaded {len(inventory)} product(s) from {filename}.")
    return inventory


def save_inventory(inventory, filename):
    """Overwrite the save file with the current stock levels."""
    with open(filename, "w") as file:
        for name, details in inventory.items():
            file.write(f"{name},{details['price']},{details['quantity']}\n")


def save_sales_log(sales_log, filename):
    """Append this session's sales to the history file.

    Append mode ("a") is deliberate: it adds to the existing history instead
    of overwriting it, giving a permanent record of every sale ever made.
    """
    if not sales_log:
        return  # Nothing was sold, so there is nothing to record.

    with open(filename, "a") as file:
        for item, quantity, unit_price, total in sales_log:
            file.write(f"{item},{quantity},{unit_price},{total}\n")


def save_restock_alerts(inventory, filename):
    """Write a plain-text shopping list of low-stock products."""
    low_stock = [(name, details["quantity"])
                 for name, details in inventory.items()
                 if details["quantity"] <= LOW_STOCK_THRESHOLD]

    with open(filename, "w") as file:
        file.write("RESTOCK ALERTS\n")
        file.write(f"Items with {LOW_STOCK_THRESHOLD} units or fewer left\n")
        file.write("-" * 34 + "\n")
        if not low_stock:
            file.write("All products are sufficiently stocked.\n")
        for name, quantity in sorted(low_stock):
            file.write(f"{name:<24}{quantity:>3} left\n")


# ---------------------------------------------------------------------------
# Inventory features
# ---------------------------------------------------------------------------

def view_stock(inventory):
    """Print the full inventory as an aligned table."""
    print("\n" + "=" * 52)
    print(f"{'Product':<24}{'Price (KES)':>12}{'Qty':>6}   Status")
    print("-" * 52)

    if not inventory:
        print("  The inventory is empty.")

    # sorted() gives a stable alphabetical order, which is easier to scan
    # than the order items happened to be added in.
    for name in sorted(inventory):
        price = inventory[name]["price"]
        quantity = inventory[name]["quantity"]

        if quantity == 0:
            status = "OUT OF STOCK"
        elif quantity <= LOW_STOCK_THRESHOLD:
            status = "Low stock"
        else:
            status = ""

        print(f"{name:<24}{price:>12,}{quantity:>6}   {status}")
    print("=" * 52)


def restock_product(inventory):
    """Add stock to an existing product, or create a brand new product."""
    name = ask_for_text("Product name: ")

    if name in inventory:
        added = ask_for_positive_int("Units to add: ")
        inventory[name]["quantity"] += added
        print(f"  Restocked {name}. New quantity: "
              f"{inventory[name]['quantity']}.")
    else:
        print(f"  '{name}' is not in the inventory yet. Adding it as a "
              f"new product.")
        price = ask_for_positive_int("Price per unit (KES): ")
        quantity = ask_for_positive_int("Starting quantity: ")
        inventory[name] = {"price": price, "quantity": quantity}
        print(f"  Added {name}: {quantity} units at KES {price:,} each.")


def search_products(inventory):
    """Find products whose name contains the text the user typed."""
    term = input("Search for: ").strip().lower()

    if term == "":
        print("  Please type at least part of a product name.")
        return

    # Lower-casing both sides makes the search case-insensitive, and the
    # `in` operator allows partial matches ("mai" finds "Maize Flour").
    matches = [name for name in inventory if term in name.lower()]

    if not matches:
        print(f"  No matches found for '{term}'.")
        return

    print(f"\n  {len(matches)} match(es) for '{term}':")
    for name in sorted(matches):
        price = inventory[name]["price"]
        quantity = inventory[name]["quantity"]
        print(f"  {name:<24}KES {price:>6,}   {quantity:>4} in stock")


# ---------------------------------------------------------------------------
# Sales features
# ---------------------------------------------------------------------------

def sell_product(inventory, sales_log, products_sold):
    """Record a sale, reducing stock only when enough units are available.

    sales_log and products_sold are modified in place, so the caller's
    session data stays up to date without having to return anything.
    """
    name = ask_for_text("Which product? ")

    if name not in inventory:
        print(f"  '{name}' was not found. Check the spelling or use "
              f"Search Products (option 5).")
        return

    available = inventory[name]["quantity"]
    if available == 0:
        print(f"  {name} is out of stock. Nothing was sold.")
        return

    units = ask_for_positive_int("How many units? ")

    # The stock check comes before any change is made, so a refused sale
    # leaves the inventory and the sales log exactly as they were.
    if units > available:
        print(f"  Not enough stock. Only {available} {name} available. "
              f"Nothing was sold.")
        return

    unit_price = inventory[name]["price"]
    total = units * unit_price

    inventory[name]["quantity"] -= units
    sales_log.append((name, units, unit_price, total))
    products_sold.add(name)

    print(f"  Sold {units} {name} for KES {total:,}.")
    if inventory[name]["quantity"] <= LOW_STOCK_THRESHOLD:
        print(f"  Heads up: only {inventory[name]['quantity']} {name} "
              f"left. Consider restocking.")


def sales_report(sales_log, products_sold):
    """Print every sale this session plus revenue and best-seller summary."""
    print("\n" + "=" * 58)
    print("SALES REPORT (this session)")
    print("=" * 58)

    if not sales_log:
        print("  No sales have been recorded yet.")
        print("=" * 58)
        return

    print(f"{'#':<4}{'Product':<22}{'Qty':>5}{'Unit (KES)':>13}"
          f"{'Total (KES)':>14}")
    print("-" * 58)

    total_revenue = 0                # Accumulator for session revenue.
    units_by_product = {}            # Running unit count per product.

    for number, (item, quantity, unit_price, total) in enumerate(
            sales_log, start=1):
        print(f"{number:<4}{item:<22}{quantity:>5}{unit_price:>13,}"
              f"{total:>14,}")
        total_revenue += total
        units_by_product[item] = units_by_product.get(item, 0) + quantity

    print("-" * 58)
    print(f"{'TOTAL REVENUE':<44}KES {total_revenue:>8,}")
    print(f"Unique products sold: {len(products_sold)} "
          f"({', '.join(sorted(products_sold))})")

    # Best seller is judged by units sold. Revenue would favour expensive
    # items, whereas units show what customers actually reach for. Ties are
    # reported together rather than picking one arbitrarily.
    top_units = max(units_by_product.values())
    best_sellers = [name for name, units in units_by_product.items()
                    if units == top_units]
    print(f"Best-selling product: {', '.join(sorted(best_sellers))} "
          f"({top_units} units)")
    print("=" * 58)


# ---------------------------------------------------------------------------
# Program flow
# ---------------------------------------------------------------------------

def show_welcome(kiosk_name, owner_name):
    """Print the welcome banner."""
    message = (f"Welcome to {kiosk_name}'s Kiosk Manager, "
               f"run by {owner_name}")
    print("\n" + "=" * len(message))
    print(message)
    print("=" * len(message))


def show_menu():
    """Print the main menu options."""
    print("\n===== MAIN MENU =====")
    print("1. View Stock")
    print("2. Add / Restock a Product")
    print("3. Sell a Product")
    print("4. View Sales Report")
    print("5. Search Products")
    print("6. Save Data and Exit")


def main():
    """Run the Kiosk Manager: set up, loop on the menu, save on exit."""
    #Setup 
    kiosk_name = ask_for_text("Enter the kiosk's name: ")
    owner_name = ask_for_text("Enter the owner's name: ")
    show_welcome(kiosk_name, owner_name)

    inventory = load_inventory(INVENTORY_FILE)
    sales_log = []         # Sales made in THIS session only.
    products_sold = set()  # Unique products sold in this session.

    #Menu loop
    while True:
        show_menu()
        choice = input("Enter your choice: ").strip()

        # Check the input is numeric BEFORE converting, so letters or an
        # empty entry produce a friendly message instead of a ValueError.
        if not is_whole_number(choice):
            print("  Invalid choice. Please enter a number from 1 to 6.")
            continue

        choice = int(choice)

        if choice == 1:
            view_stock(inventory)
        elif choice == 2:
            restock_product(inventory)
        elif choice == 3:
            sell_product(inventory, sales_log, products_sold)
        elif choice == 4:
            sales_report(sales_log, products_sold)
        elif choice == 5:
            search_products(inventory)
        elif choice == 6:
            break
        else:
            print("  Invalid choice. Please enter a number from 1 to 6.")

    #Save on exit
    save_inventory(inventory, INVENTORY_FILE)
    save_sales_log(sales_log, SALES_LOG_FILE)
    save_restock_alerts(inventory, ALERTS_FILE)
    print(f"\n  Data saved. Goodbye, {owner_name}!")


# Running main() only when the file is executed directly (not imported)
# lets the functions above be reused or tested without starting the menu.
if __name__ == "__main__":
    main()
