Yes — **the DAX measure is now correct**, but the screenshot reveals the real issue.

Your measure:

```DAX
MoM Revenue Growth % =
DIVIDE(
    AVERAGE(vw_powerbi_monthly_kpis[mom_growth_pct]),
    100
)
```

is doing the right conversion.

### The problem is the underlying data

From the table you showed earlier:

| Month   | Orders |    Revenue |
| ------- | -----: | ---------: |
| 2016-12 |      1 |      19.62 |
| 2017-01 |    789 | 137,188.49 |

So January 2017's MoM growth is enormous because you're comparing **₹19.62 of revenue from one order** with **₹137K the following month**.

That's why the chart is dominated by that single spike.

### I recommend we don't show that misleading spike

For a business dashboard, a 699,000%+ growth point caused by a month with only **1 order** isn't useful. It makes the entire chart unreadable.

Instead, let's create a **clean MoM Growth measure** that excludes a month when the previous month's order volume is extremely small.

But rather than arbitrarily hiding values, let's use the obvious data-quality condition: **don't calculate MoM growth when the previous month had fewer than 10 orders.**

Create this measure:

```DAX
MoM Revenue Growth % =
VAR CurrentMonth =
    MAX(vw_powerbi_monthly_kpis[purchase_month_number])
VAR CurrentYear =
    MAX(vw_powerbi_monthly_kpis[purchase_year])

VAR CurrentRevenue =
    MAX(vw_powerbi_monthly_kpis[gross_item_value])

VAR PreviousRevenue =
    CALCULATE(
        MAX(vw_powerbi_monthly_kpis[gross_item_value]),
        FILTER(
            ALL(vw_powerbi_monthly_kpis),
            vw_powerbi_monthly_kpis[purchase_year] * 12
                + vw_powerbi_monthly_kpis[purchase_month_number]
                =
                CurrentYear * 12
                + CurrentMonth - 1
        )
    )

VAR PreviousOrders =
    CALCULATE(
        MAX(vw_powerbi_monthly_kpis[orders]),
        FILTER(
            ALL(vw_powerbi_monthly_kpis),
            vw_powerbi_monthly_kpis[purchase_year] * 12
                + vw_powerbi_monthly_kpis[purchase_month_number]
                =
                CurrentYear * 12
                + CurrentMonth - 1
        )
    )

RETURN
IF(
    PreviousOrders < 10,
    BLANK(),
    DIVIDE(CurrentRevenue - PreviousRevenue, PreviousRevenue)
)
```

Format it as:

**Percentage → 2 decimal places**

---

### Why this is better

January 2017 becomes blank because:

```text
Previous month = December 2016
Previous orders = 1
```

So we don't present a misleading growth percentage.

The remaining months will show meaningful movements such as:

```text
       50% ──╮
       25% ─╮│ ╭──╮
        0% ─┼╯─╯  ╰──╮──
      -25% ─┤         ╰─
```

rather than:

```text
700,000%
     │
     │
     │
     │
     └──────────────────
```

### One important note

This is a **dashboard presentation/business-rule decision**, not a correction to your SQL data. We're not changing the underlying data; we're saying that MoM growth isn't meaningful when the comparison month has fewer than 10 orders.

I think that's much more defensible for a portfolio Power BI dashboard.

**Replace your current measure with the above one and keep it as the Y-axis.** Once the chart looks sensible, we'll move on to **Revenue by Order Status**.
