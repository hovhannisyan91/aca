
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

df["marital_status"] = np.random.choice(
    ["Single", "Married"], n_users, p=[0.6, 0.4]
)

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
    "Germany", "France", "Italy", "Spain", "Poland",
    "Netherlands", "Belgium", "Sweden", "Austria",
    "Switzerland", "Portugal", "Czech Republic",
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
# 7. COHORT EFFECT
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

# ---------------------------
# 8. HAZARD CURVES
# ---------------------------
def get_hazard_curve(cohort_type):
    if cohort_type == "bad":
        return [0.35, 0.25, 0.15, 0.10, 0.08, 0.07, 0.06, 0.05, 0.04, 0.03, 0.02, 0.02]
    elif cohort_type == "moderate":
        return [0.25, 0.20, 0.15, 0.12, 0.10, 0.08, 0.07, 0.06, 0.05, 0.04, 0.03, 0.02]
    else:
        return [0.10, 0.08, 0.07, 0.06, 0.05, 0.05, 0.04, 0.04, 0.03, 0.03, 0.02, 0.02]

# optional business adjustments
def adjust_hazard(hazards, row):
    hazards = np.array(hazards)

    # premium users churn less
    if row["plan_type"] == "Premium":
        hazards *= 0.7

    # paid users churn more
    if row["channel"] == "Paid Ads":
        hazards *= 1.2

    return np.clip(hazards, 0, 1)

# ---------------------------
# 9. SIMULATE TENURE
# ---------------------------
def simulate_tenure(row):
    hazards = get_hazard_curve(row["cohort_type"])
    hazards = adjust_hazard(hazards, row)

    for month in range(1, 13):
        if np.random.rand() < hazards[month - 1]:
            return month

    return None

df["tenure"] = df.apply(simulate_tenure, axis=1)

# ---------------------------
# 10. CANCELLATION DATE
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
# 11. OBSERVATION WINDOW (FULL 12 MONTHS)
# ---------------------------
max_observation = pd.to_datetime("2025-08-01")

df.loc[df["cancellation_month"] > max_observation, "cancellation_month"] = pd.NaT

# ---------------------------
# 12. FINAL CLEANING
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

# ---------------------------
# 13. SAVE
# ---------------------------
df.to_csv("data/cohort/cohort_analysis.csv", index=False)

