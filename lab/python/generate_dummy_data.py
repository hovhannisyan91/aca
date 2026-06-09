from pathlib import Path

import numpy as np
import pandas as pd


def main() -> None:
    np.random.seed(42)

    n = 300

    df = pd.DataFrame(
        {
            "customer_id": range(1, n + 1),
            "age": np.random.randint(18, 70, size=n),
            "region": np.random.choice(["North", "South", "East", "West"], size=n),
            "segment": np.random.choice(
                ["Low Value", "Medium Value", "High Value"],
                size=n,
                p=[0.45, 0.35, 0.20],
            ),
        }
    )

    df["income"] = 15000 + df["age"] * 850 + np.random.normal(0, 10000, size=n)

    segment_spend_multiplier = {
        "Low Value": 0.025,
        "Medium Value": 0.040,
        "High Value": 0.060,
    }

    df["monthly_spend"] = df.apply(
        lambda row: row["income"] * segment_spend_multiplier[row["segment"]],
        axis=1,
    )
    df["monthly_spend"] = df["monthly_spend"] + np.random.normal(0, 150, size=n)

    df["income"] = df["income"].clip(lower=10000).round(0)
    df["monthly_spend"] = df["monthly_spend"].clip(lower=50).round(0)

    output_path = Path(__file__).parent / "data" / "dummy_data.csv"
    df.to_csv(output_path, index=False)

    print(df.head())
    print(f"\nSaved {len(df)} rows to {output_path}")


if __name__ == "__main__":
    main()
