import pandas as pd
import numpy as np
import plotly.express as px


def my_bar_plot(
    df: pd.DataFrame, x_col: str, y_col: float, flag: bool = True
) -> px.bar:

    df_agg = df.groupby(x_col, as_index=False)[y_col].sum()

    if flag:
        flag_region = df_agg.loc[df_agg[y_col].idxmax(), x_col]
        df_agg["highlight"] = np.where(
            df_agg[x_col] == flag_region,
            f"Highest {y_col.capitalize()}",
            f"Other {y_col.capitalize()}",
        )
        colorizer = {
            f"Highest {y_col.capitalize()}": "#3B6EAD",
            f"Other {y_col.capitalize()}": "#D9D9D9",
        }
    else:
        flag_region = df_agg.loc[df_agg[y_col].idxmin(), x_col]
        df_agg["highlight"] = np.where(
            df_agg[x_col] == flag_region,
            f"Lowest {y_col.capitalize()}",
            f"Other {y_col.capitalize()}",
        )
        colorizer = {
            f"Lowest {y_col.capitalize()}": "#3B6EAD",
            f"Other {y_col.capitalize()}": "#D9D9D9",
        }

    fig = px.bar(
        df_agg,
        x=x_col,
        y=y_col,
        color="highlight",
        title=f"Total {y_col.capitalize()} by {x_col.capitalize()}",
        color_discrete_map=colorizer,
    )

    fig.update_traces(textposition="outside")

    fig.update_layout(
        xaxis_title=x_col.capitalize(),
        yaxis_title=y_col.capitalize(),
        legend_title="",
    )

    return fig


def csv_downloader(url: str, name: str, path: str) -> pd.DataFrame:
    """
    Download a CSV from a url, save it locally, and return it as a DataFrame.

    Parameters
    ----------
    url : str
        Source path or url to the CSV file.
    name : str
        Output file name (e.g., "data.csv").
    path : str
        Directory to save the file.

    Returns
    -------
    pd.DataFrame
        Loaded dataset.

        Example
    -------
    >>> df = csv_downloader(
    ...     url="https://example.com/data.csv",
    ...     name="data",
    ...     path="./data"
    ... )
    >>> df.head()
    """
    df = pd.read_csv(url)
    df.to_csv(f"{path}/{name}.csv", index=False)
    print(f"{name} saved in {path} | shape: {df.shape}")
    return df


def json_downloader(url: str, name: str, path: str):
    js = pd.read_json(url)


#


def naming(df):
    if df["RFM_Score"] >= 9:
        return "Can't Loose Them"
    elif (df["RFM_Score"] >= 8) and (df["RFM_Score"] < 9):
        return "Champions"
    elif (df["RFM_Score"] >= 7) and (df["RFM_Score"] < 8):
        return "Loyal/Commited"
    elif (df["RFM_Score"] >= 6) and (df["RFM_Score"] < 7):
        return "Potential"
    elif (df["RFM_Score"] >= 5) and (df["RFM_Score"] < 6):
        return "Promising"
    elif (df["RFM_Score"] >= 4) and (df["RFM_Score"] < 5):
        return "Requires Attention"
    else:
        return "Demands Activation"
