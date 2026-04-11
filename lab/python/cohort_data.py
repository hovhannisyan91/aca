import pandas as pd
import numpy as np

np.random.seed(42)

n_users = 12000

# ---------------------------
# 1. ACQUISITION
# ---------------------------
acquisition_dates = pd.date_range("2024-01-01", "2024-08-01", freq="MS")

df = pd.DataFrame(
    {
        "user_id": range(1, n_users + 1),
        "acquisition_date": np.random.choice(acquisition_dates, n_users),
    }
)

df["acquisition_month"] = df["acquisition_date"].dt.to_period("M")

# ---------------------------
# 2. DEMOGRAPHICS
# ---------------------------
df["gender"] = np.random.choice(["Male", "Female"], n_users)

df["marital_status"] = np.random.choice(["Single", "Married"], n_users, p=[0.6, 0.4])

df["age"] = np.random.normal(35, 10, n_users).astype(int)
df["age"] = df["age"].clip(18, 65)

df["income_segment"] = pd.cut(
    df["age"],
    bins=[18, 25, 35, 50, 65],
    labels=["Low", "Medium", "High", "Premium"],
)

# ---------------------------
# 3. COUNTRY
# ---------------------------
countries = [
    "Germany",
    "France",
    "Italy",
    "Spain",
    "Poland",
    "Netherlands",
    "Belgium",
    "Sweden",
    "Austria",
    "Switzerland",
    "Portugal",
    "Czech Republic",
]

df["country"] = np.random.choice(countries, n_users)

# ---------------------------
# 4. CHANNEL / CAMPAIGN
# ---------------------------
df["channel"] = np.random.choice(
    ["Organic", "Paid Ads", "Referral"],
    n_users,
    p=[0.4, 0.4, 0.2],
)

df["campaign_id"] = df["channel"] + "_" + np.random.choice(["A", "B", "C"], n_users)

# ---------------------------
# 5. DEVICE
# ---------------------------
df["device_type"] = np.random.choice(
    ["Android", "iOS", "Web"],
    n_users,
    p=[0.55, 0.30, 0.15],
)

# ---------------------------
# 6. PLAN TYPE
# ---------------------------
df["plan_type"] = np.where(
    df["income_segment"].isin(["High", "Premium"]),
    np.random.choice(["Standard", "Premium"], n_users),
    np.random.choice(["Basic", "Standard"], n_users),
)

# ---------------------------
# 7. COHORT EFFECT (STRONGER + REALISTIC)
# ---------------------------
cohort_behavior = {
    "2024-01": "good",
    "2024-02": "good",
    "2024-03": "bad",
    "2024-04": "bad",
    "2024-05": "moderate",
    "2024-06": "moderate",
    "2024-07": "good",
    "2024-08": "good",
}

df["cohort_type"] = df["acquisition_month"].astype(str).map(cohort_behavior)


def generate_tenure(row):
    ctype = row["cohort_type"]

    if ctype == "good":
        probs = [0.1, 0.2, 0.3, 0.4]
    elif ctype == "moderate":
        probs = [0.2, 0.3, 0.3, 0.2]
    else:
        probs = [0.4, 0.3, 0.2, 0.1]

    bucket = np.random.choice(["early", "mid", "late", "no_churn"], p=probs)

    if bucket == "early":
        return np.random.randint(1, 4)
    elif bucket == "mid":
        return np.random.randint(4, 8)
    elif bucket == "late":
        return np.random.randint(8, 13)
    else:
        return None


df["tenure"] = df.apply(generate_tenure, axis=1)

# ---------------------------
# 8. CANCELLATION MONTH
# ---------------------------
df["cancellation_month"] = df.apply(
    lambda row: (
        row["acquisition_date"] + pd.DateOffset(months=int(row["tenure"]))
        if pd.notnull(row["tenure"])
        else pd.NaT
    ),
    axis=1,
)

# ---------------------------
# 9. APPLY OBSERVATION WINDOW (CRITICAL FIX)
# ---------------------------
max_observation = pd.to_datetime("2024-12-01")

df.loc[df["cancellation_month"] > max_observation, "cancellation_month"] = pd.NaT

# ---------------------------
# 10. FINAL CLEANING
# ---------------------------
df = df.drop(columns=["cohort_type", "tenure", "acquisition_month"])

df = df[
    [
        "user_id",
        "acquisition_date",
        "cancellation_month",
        "gender",
        "marital_status",
        "age",
        "income_segment",
        "country",
        "channel",
        "campaign_id",
        "device_type",
        "plan_type",
    ]
]

print(df.head())


df.to_csv("data/cohort/cohort_analysis.csv", index=False)
