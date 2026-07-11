"""
Phase 1 raw data validation for the Olist E-Commerce Sales Analytics Dashboard.

Run this script from the project root:
    python Validation/phase_1_data_validation.py

The script validates raw CSV row counts, primary key candidates, foreign key coverage,
and category translation coverage before database schema design begins.
"""

from __future__ import annotations

import csv
from collections import Counter
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
RAW_DATA_DIR = PROJECT_ROOT / "Data" / "Raw"


FILES = {
    "customers": "olist_customers_dataset.csv",
    "orders": "olist_orders_dataset.csv",
    "order_items": "olist_order_items_dataset.csv",
    "order_payments": "olist_order_payments_dataset.csv",
    "order_reviews": "olist_order_reviews_dataset.csv",
    "products": "olist_products_dataset.csv",
    "sellers": "olist_sellers_dataset.csv",
    "geolocation": "olist_geolocation_dataset.csv",
    "category_translation": "product_category_name_translation.csv",
}


def read_rows(file_name: str) -> list[dict[str, str]]:
    path = RAW_DATA_DIR / file_name
    with path.open("r", encoding="utf-8-sig", newline="") as file:
        return list(csv.DictReader(file))


def value_set(rows: list[dict[str, str]], column: str) -> set[str]:
    return {row[column] for row in rows if row[column] != ""}


def duplicate_key_stats(rows: list[dict[str, str]], columns: list[str]) -> tuple[int, int]:
    keys = Counter(tuple(row[column] for column in columns) for row in rows)
    duplicate_keys = sum(1 for count in keys.values() if count > 1)
    extra_duplicate_rows = sum(count - 1 for count in keys.values() if count > 1)
    return duplicate_keys, extra_duplicate_rows


def print_section(title: str) -> None:
    print("\n" + title)
    print("=" * len(title))


def main() -> None:
    tables = {name: read_rows(file_name) for name, file_name in FILES.items()}

    print_section("Row Counts")
    for name, rows in tables.items():
        print(f"{name}: {len(rows):,}")

    print_section("Primary Key Candidate Checks")
    pk_checks = {
        "customers.customer_id": ("customers", ["customer_id"]),
        "orders.order_id": ("orders", ["order_id"]),
        "order_items.(order_id, order_item_id)": ("order_items", ["order_id", "order_item_id"]),
        "order_payments.(order_id, payment_sequential)": ("order_payments", ["order_id", "payment_sequential"]),
        "order_reviews.review_id": ("order_reviews", ["review_id"]),
        "products.product_id": ("products", ["product_id"]),
        "sellers.seller_id": ("sellers", ["seller_id"]),
        "category_translation.product_category_name": ("category_translation", ["product_category_name"]),
    }

    for label, (table_name, columns) in pk_checks.items():
        duplicate_keys, extra_duplicate_rows = duplicate_key_stats(tables[table_name], columns)
        print(
            f"{label}: duplicate keys={duplicate_keys:,}, "
            f"extra duplicate rows={extra_duplicate_rows:,}"
        )

    print_section("Foreign Key Coverage Checks")
    customers = value_set(tables["customers"], "customer_id")
    orders = value_set(tables["orders"], "order_id")
    products = value_set(tables["products"], "product_id")
    sellers = value_set(tables["sellers"], "seller_id")
    categories = value_set(tables["category_translation"], "product_category_name")

    fk_checks = {
        "orders.customer_id missing in customers": value_set(tables["orders"], "customer_id") - customers,
        "order_items.order_id missing in orders": value_set(tables["order_items"], "order_id") - orders,
        "order_payments.order_id missing in orders": value_set(tables["order_payments"], "order_id") - orders,
        "order_reviews.order_id missing in orders": value_set(tables["order_reviews"], "order_id") - orders,
        "order_items.product_id missing in products": value_set(tables["order_items"], "product_id") - products,
        "order_items.seller_id missing in sellers": value_set(tables["order_items"], "seller_id") - sellers,
        "products.product_category_name missing in category_translation": value_set(
            tables["products"], "product_category_name"
        ) - categories,
    }

    for label, missing_values in fk_checks.items():
        print(f"{label}: {len(missing_values):,}")
        if missing_values:
            preview = ", ".join(sorted(missing_values)[:10])
            print(f"  Values: {preview}")


if __name__ == "__main__":
    main()
