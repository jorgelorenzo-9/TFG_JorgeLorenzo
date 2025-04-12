def ugr_load_data(month: str, weekNum: int):
    import pandas as pd

    if month not in ["march", "april", "may", "june", "july", "august"]:
        print("Invalid month")
        return

    columns = ["Date", "Bitrate", "Packet rate"]
    try:
        df = pd.read_csv('ugr16/'+month+'_week' +
                         str(weekNum)+'_csv/BPSyPPS.txt', sep=',', names=columns) #Ruta de la base de datos
    except FileNotFoundError:
        print("File not found")
        return
    df["Date"] = pd.to_datetime(df["Date"], unit='s') + pd.Timedelta(hours=2)

    return df


def ugr_concat_data(data1, data2):
    import pandas as pd
    data1Idx = len(data1)-1
    data2Idx = 0

    if data1["Date"][data1Idx] >= data2["Date"][data2Idx]:
        data1 = data1.copy()

    while data1["Date"][data1Idx] >= data2["Date"][data2Idx]:
        data2Idx += 1

    while data2Idx >= 0:
        if data1["Date"][data1Idx] == data2["Date"][data2Idx]:
            data1.loc[data1Idx, "Bitrate"] += data2.loc[data2Idx, "Bitrate"]
            data1.loc[data1Idx,
                      "Packet rate"] += data2.loc[data2Idx, "Packet rate"]
            data1Idx -= 1
            data2Idx -= 1
        elif data1["Date"][data1Idx] > data2["Date"][data2Idx]:
            data1Idx -= 1
        else:
            data2Idx -= 1

    data2 = data2[data2["Date"] > data1["Date"].iloc[-1]]

    df = pd.concat([data1, data2], ignore_index=True)

    return df


def ugr_concat_data_list(dataList):
    if len(dataList) == 0:
        return
    import pandas as pd
    df = dataList[0]
    for i in range(1, len(dataList)):
        df = ugr_concat_data(df, dataList[i])
    return df


def smooth(a, WSZ):
    if WSZ == 1:
        return a
    if WSZ % 2 == 0:
        WSZ += 1
    if WSZ > len(a):
        WSZ = len(a)
        if WSZ % 2 == 0:
            WSZ -= 1
    import numpy as np
    out0 = np.convolve(a, np.ones(WSZ, dtype=int), 'valid')/WSZ
    r = np.arange(1, WSZ-1, 2)
    start = np.cumsum(a[:WSZ-1])[::2]/r
    stop = (np.cumsum(a[:-WSZ:-1])[::2]/r)[::-1]
    return np.concatenate((start, out0, stop))


def ugr_get_first_n_days(df, n):
    import pandas as pd
    df = df[df["Date"] < df["Date"][0] + pd.Timedelta(days=n)]
    df.reset_index(drop=True, inplace=True)
    return df


def ugr_get_last_n_days(df, n):
    import pandas as pd
    df = df[df["Date"] > df["Date"][len(df)-1] - pd.Timedelta(days=n)]
    df.reset_index(drop=True, inplace=True)
    return df


def ugr_crop_few_minutes(df, minutesLeft, minutesRight=None):
    import pandas as pd
    if minutesRight == None:
        minutesRight = minutesLeft
    df = df[df["Date"] > df["Date"][0] + pd.Timedelta(minutes=minutesLeft)]
    df.reset_index(drop=True, inplace=True)
    df = df[df["Date"] < df["Date"][len(df)-1] - pd.Timedelta(minutes=minutesRight)]
    df.reset_index(drop=True, inplace=True)
    return df

def ugr_get_few_minutes(df, offset, minutes):
    import pandas as pd
    first_time = df["Date"].iloc[0]
    df = df[df["Date"] > df["Date"][0] + pd.Timedelta(minutes=offset)]
    df.reset_index(drop=True, inplace=True)
    df = df[df["Date"] < df["Date"][0] + pd.Timedelta(minutes=minutes)]
    df.reset_index(drop=True, inplace=True)
    return df

def ugr_group_n_points(df, n):
    import pandas as pd
    pd.options.mode.chained_assignment = None
    date = df["Date"][::n].reset_index(drop=True, inplace=False)
    df.drop(["Date"], axis=1, inplace=True)
    df = df.groupby(df.index // n).sum()
    df["Date"] = date
    return df

def ugr_simple_plot(df, smoothingWindow=60*10+1, plotColumns=["Bitrate", "Packet rate"], separateWeeks=True):
    import matplotlib.pyplot as plt
    import matplotlib.dates as mdates
    import pandas as pd
    import numpy as np
    from datetime import datetime

    colorPalette = ["#165091", "#E16E0D", "#26890C", "#1368CE",
                    "#D62728", "#8C564B", "#E377C2", "#7F7F7F", "#BCBD22", "#17BECF"]

    if smoothingWindow % 2 == 0:
        smoothingWindow += 1

    plt.rcParams['axes.grid'] = True

    if separateWeeks:
        if type(df) is list:
            weeksArr = [[g for n, g in dff.groupby(
                pd.Grouper(key='Date', freq='W')) if len(g) > 0] for dff in df]
            [week.reset_index(drop=True, inplace=True) for weeks in weeksArr for week in weeks ]
        else:
            weeksArr = [[g for n, g in df.groupby(
                pd.Grouper(key='Date', freq='W')) if len(g) > 0]]
            [week.reset_index(drop=True, inplace=True) for weeks in weeksArr for week in weeks ]
    else:
        if type(df) is list:
            weeksArr = [df]
        else:
            weeksArr = [[df]]

    axCount = len(plotColumns)*len(weeksArr[0])

    fig, axs = plt.subplots(axCount, 1, figsize=(16, 9))
    if axCount == 1:
        axs = [axs]
    plt.subplots_adjust(left=0.1, bottom=0.25)

    for weekIdx in range(len(weeksArr[0])):
        weekArr = [w[weekIdx] for w in weeksArr]
        for plotColIdx in range(len(plotColumns)):
            plotCol = plotColumns[plotColIdx]
            for ax in axs[plotColIdx*len(weeksArr[0])+weekIdx::axCount]:
                for i, week in enumerate(weekArr):
                    color = colorPalette.pop(0)
                    colorPalette.append(color)
                    ax.plot(week["Date"], smooth(week[plotCol],
                            smoothingWindow), label=plotCol, color=color)
                ax.set_ylabel(plotCol)
                ax.set_xlabel("Date" + " (week "+str(week["Date"][0].week)+")")
                ax.xaxis.set_major_formatter(
                    mdates.DateFormatter('%Y/%m/%d %A'))
                ax.xaxis.set_major_locator(mdates.DayLocator(interval=1))
                startWeek = datetime.strptime(
                    str(week["Date"][0].year) + " " + str(week["Date"][0].week-1) + ' 0', "%Y %W %w")
                endWeek = datetime.strptime(
                    str(week["Date"][0].year) + " " + str(week["Date"][0].week) + ' 0', "%Y %W %w")
                ax.set_xbound(pd.to_datetime(startWeek)+pd.Timedelta(days=1),
                              pd.to_datetime(endWeek)+pd.Timedelta(days=1))
                ax.legend()
                ax.ticklabel_format(axis='y', style='sci', scilimits=(8, 4))

    fig.tight_layout()
    return plt


def ugr_detect_periodicity_sf(df, T0, t1, paramMeasure="Bitrate"):
    # Detect periodicity using SF algorithm
    import numpy as np
    import pandas as pd
    from math import floor, ceil
    from datetime import timedelta
    from statistics import mean

    sp, nsp = 0, 0
    Ni = floor((7/8)*(T0/t1))
    Nf = ceil((7/6)*(T0/t1))
    print("(Ni, Nf) = ", (Ni, Nf))

    Sf = np.zeros(Nf-Ni)
    for n in range(Ni, Nf):
        for i in range(0, n):
            if (df[paramMeasure][n+i] <= df[paramMeasure][i] and df[paramMeasure][n+i] >= df[paramMeasure][i+1]) or (df[paramMeasure][n+i] >= df[paramMeasure][i] and df[paramMeasure][n+i] <= df[paramMeasure][i+1]):
                sp += 1
            else:
                nsp += 1

        Sf[n-Ni] = (sp - nsp)/n
    print(Sf)
    if max(Sf) >= 0.0:
        m = np.argmax(Sf)
        T = (m + 0.5)*t1
        return T
    return


def ugr_seasonal_decompose(df, paramMeasure="Bitrate"):
    from statsmodels.tsa.seasonal import seasonal_decompose
    result = seasonal_decompose(
        x=df[paramMeasure], model='multiplicative', period=86400, extrapolate_trend='freq')
    return result

def ugr_seasonal_decompose_2(df, paramMeasure="Bitrate"):
    from statsmodels.tsa.seasonal import seasonal_decompose, DecomposeResult
    import numpy as np
    result = seasonal_decompose(x=df[paramMeasure], model='multiplicative', period=86400*7, extrapolate_trend='freq')
    res = seasonal_decompose(
        x=result.resid,
        model='multiplicative', period=86400, extrapolate_trend='freq')
    return DecomposeResult(observed=res.observed,  seasonal=np.array([res.seasonal, result.seasonal]), trend=np.array([res.trend, result.trend]), resid=res.resid)

# Takes way too long. Not good. Need to reduce dimensionality
def ugr_seasonal_decompose_stl(df, paramMeasure="Bitrate"):
    from statsmodels.tsa.seasonal import STL
    result = STL(df[paramMeasure], period=86400, robust=False).fit()

# Tarda muchisimo (e.g. no acaba nunca)
def ugr_seasonal_decompose_mstl(df, paramMeasure="Bitrate"):
    from statsmodels.tsa.seasonal import MSTL
    stl_kwargs = {"seasonal_deg": 0}
    model = MSTL(df[paramMeasure], periods=(86400, 86400 * 7), stl_kwargs=stl_kwargs)
    res = model.fit()
    return res


def ugr_seasonal_plot(df, result, smoothingWindow = 60*10+1, separateWeeks=True):
    import matplotlib.pyplot as plt
    import matplotlib.dates as mdates
    import pandas as pd
    import numpy as np
    from datetime import datetime
    plt.rcParams['axes.grid'] = True

    fig, axs = plt.subplots(2+result.seasonal.ndim+result.trend.ndim, 1, sharex=True, figsize=(16, 10))

    if smoothingWindow % 2 == 0:
        smoothingWindow += 1

    colorPalette = ["#165091", "#E16E0D", "#26890C", "#1368CE",
                    "#D62728", "#8C564B", "#E377C2", "#7F7F7F", "#BCBD22", "#17BECF"]

    plotCols = [("Observed", result.observed)]
    if result.trend.ndim == 2:
        plotCols.append(("Trend 1d", result.trend[0]))
        plotCols.append(("Trend 1w", result.trend[1]))
    else:
        plotCols.append(("Trend", result.trend))
    if result.seasonal.ndim == 2:
        plotCols.append(("Seasonal 1d", result.seasonal[0]))
        plotCols.append(("Seasonal 1w", result.seasonal[1]))
    else:
        plotCols.append(("Seasonal", result.seasonal))
    plotCols.append(("Residue", result.resid))

    for ax in axs:
        color = colorPalette.pop(0)
        colorPalette.append(color)
        plotCol = plotCols.pop(0)
        ax.plot(df["Date"], smooth(plotCol[1], smoothingWindow),
                label=plotCol[0], color=color)
        ax.set_ylabel(plotCol[0])
        ax.set_xlabel("Date")
        ax.xaxis.set_major_formatter(mdates.DateFormatter('%Y/%m/%d %A'))
        ax.xaxis.set_major_locator(mdates.DayLocator(interval=1))
        ax.legend()
        # ax.ticklabel_format(axis='y', style='sci', scilimits=(8, 4))

    plt.xticks(rotation=45, ha="right", rotation_mode="anchor")

    fig.tight_layout()
    return plt
