import pandas as pd
import numpy as np
import plotly.express as px
from os.path import join
from datetime import date

def create_campaign(
    campaign_id: int = 1,
    campaign_name: str = "campaign_1",
    campaign_description: str = "",
    start_date=None,
    end_date=None,
) -> dict:
    campaign_day = date.today()
    return {
        "campaign_id": campaign_id,
        "campaign_name": campaign_name,
        "campaign_description": campaign_description,
        "start_date": start_date or campaign_day,
        "end_date": end_date or campaign_day,
    }

def csv_dowloader(csv_files:list, source:str, destination: str, type:str = 'csv')->list:
    """
    Read multiple `CSV` files from a source directory, save them to a destination
    directory in the selected format, and return them as a list of DataFrames.

    Parameters
    ----------
    csv_files : list
        A list of CSV file names without the `.csv` extension.
        Example: ["orders", "customers", "products"]

    source : str
        Path to the directory where the original CSV files are stored.

    destination : str
        Path to the directory where the converted files will be saved.

    type : str, default="csv"
        Output file format. Supported values are:
        - "csv"
        - "xlsx"
        - "parquet"

    Returns
    -------
    list
        A list containing all loaded DataFrames in the same order as `csv_files`.

    Examples
    --------
    >>> csv_files = ["orders", "customers", "products"]
    >>> source = "data/raw"
    >>> destination = "data/processed"
    >>> dfs = csv_dowloader(
    ...     csv_files=csv_files,
    ...     source=source,
    ...     destination=destination,
    ...     type="parquet"
    ... )
    """
    
    l = []
    for i in csv_files:
        print(f"trying to read: {i}")
        print(f"source: {source}")
        print(f"destination: {destination}")

        df = pd.read_csv(f"{join(source,i)}.csv")
        print(f"{i} shape: {df.shape}")
        
        print("appending to the list:")
        
        l.append(df)

        file_name = join(destination,f"{i}.{type}")
        print(file_name)
        if type == 'xlsx':
            df.to_excel(file_name,index= False)
        elif type == 'parquet':
            df.to_parquet(file_name, index= False)
        else:
            df.to_csv(file_name,index= False)
        print(10*"=")
    
    return l


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
    url : strx
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


def my_date_diff(
    df: pd.DataFrame, target_column: str, start_date: str, end_date: str, by: str = "M"
) -> pd.DataFrame:
    """
    Compute month difference between two datetime columns.

    Adds a 'month_diff' column to the DataFrame.

    Parameters
    ----------
    df : pd.DataFrame
    start_date : str
    end_date : str
    by : str, default 'M'

    Returns
    -------
    pd.DataFrame
    """

    if by == "M":
        df[target_column] = (df[end_date].dt.year - df[start_date].dt.year) * 12 + (
            df[end_date].dt.month - df[start_date].dt.month
        )
    elif by == "Y":
        df[target_column] = df[end_date].dt.year - df[start_date].dt.year
    else:
        print("Goodbye")

    return df


def rsquered(y, y_hat):

    rsquered = 1 - np.sum((y - y_hat) ** 2) / np.sum((y - y.mean()) ** 2)

    return rsquered


def rmse(y, y_hat):

    rmse = np.sqrt(np.mean((y - y_hat) ** 2))

    return rmse


if __name__ == "__main__":
    import pandas as pd
    import numpy as np

    np.random.seed(42)

    n = 10

    df = pd.DataFrame(
        {
            "start_date": pd.to_datetime("2024-01-01")
            + pd.to_timedelta(np.random.randint(0, 100, n), unit="D"),
            "end_date": pd.to_datetime("2024-01-01")
            + pd.to_timedelta(np.random.randint(50, 150, n), unit="D"),
        }
    )

    df = my_date_diff(
        df=df,
        target_column="target_column",
        start_date="start_date",
        end_date="end_date",
        by="Y",
    )
    print(df.head())
