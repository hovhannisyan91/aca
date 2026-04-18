import pandas as pd
import numpy as np
import plotly.express as px

df = pd.read_csv(
    "../data/cohort/cohort_analysis.csv",
    parse_dates=["acquisition_date", "cancellation_month"],
)

# ---------------------------
# 1. Acquisition month
# ---------------------------
df["acquisition_month"] = df["acquisition_date"].dt.to_period("M")

# ---------------------------
# 2. Month churned
#    ONLY for users who actually churned
# ---------------------------
df["month_churned"] = np.where(
    df["cancellation_month"].notna(),
    (
        (df["cancellation_month"].dt.year - df["acquisition_date"].dt.year) * 12
        + (df["cancellation_month"].dt.month - df["acquisition_date"].dt.month)
    ),
    np.nan,
)

# keep only valid churn months within 1..12
df["month_churned"] = df["month_churned"].where(
    df["month_churned"].between(1, 12), np.nan
)

# ---------------------------
# 3. Cohort size
# ---------------------------
cohort_size = (
    df.groupby("acquisition_month").agg(new_users=("user_id", "count")).reset_index()
)

# ---------------------------
# 4. Count actual churn events only
# ---------------------------
cohort_churn = (
    df[df["month_churned"].notna()]
    .groupby(["acquisition_month", "month_churned"])
    .agg(users=("user_id", "count"))
    .reset_index()
)

cohort_churn["month_churned"] = cohort_churn["month_churned"].astype(int)

# ---------------------------
# 5. Create full tenure grid 1..12
# ---------------------------
max_month = 12
tenure_range = np.arange(1, max_month + 1)

full_index = pd.MultiIndex.from_product(
    [cohort_size["acquisition_month"].unique(), tenure_range],
    names=["acquisition_month", "month_churned"],
)

cohort_data = (
    cohort_churn.set_index(["acquisition_month", "month_churned"])
    .reindex(full_index, fill_value=0)
    .reset_index()
)

# ---------------------------
# 6. Add cohort size
# ---------------------------
cohort_data = cohort_data.merge(cohort_size, on="acquisition_month", how="left")

# ---------------------------
# 7. Cumulative churn
# ---------------------------
cohort_data = cohort_data.sort_values(["acquisition_month", "month_churned"])

cohort_data["cumulative_churn"] = cohort_data.groupby("acquisition_month")[
    "users"
].cumsum()

# ---------------------------
# 8. Active users and retention
# ---------------------------
cohort_data["active_users"] = cohort_data["new_users"] - cohort_data["cumulative_churn"]

cohort_data["retention_rate"] = cohort_data["active_users"] / cohort_data["new_users"]

cohort_data["acquisition_month"] = cohort_data["acquisition_month"].astype(str)

# ---------------------------
# 9. Pivot for heatmap
# ---------------------------
heatmap_data = cohort_data.pivot(
    index="acquisition_month",
    columns="month_churned",
    values="retention_rate",
)

# ---------------------------
# 10. Plot
# ---------------------------
fig = px.imshow(
    heatmap_data,
    aspect="auto",
    color_continuous_scale="Blues",
    text_auto=".1%",
    labels=dict(
        x="Months Since Acquisition", y="Acquisition Month", color="Retention Rate"
    ),
    title="Cohort Retention Heatmap",
)

fig.update_layout(
    xaxis_title="Months Since Acquisition",
    yaxis_title="Acquisition Month",
)

fig.show()
