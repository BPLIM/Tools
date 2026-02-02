*! version 0.3 03Nov2020
* Programmed by Gustavo Iglésias
* Dependencies: Python 3 (requests and pandas)


program define bpstatuse

version 16

syntax, vars(string) [frame(string) replace en]

if "`en'" == "en" {
	local lg "EN"
}
else {
	local lg "PT"
}

if "`browse'" == "browse" {
	python: browse("`vars'")
}
else {
	// Get file path
	mata: st_local("filename", findfile("BPSTAT_INFO.zip"))
	// Change path for Python
	while strpos("`filename'", "\") {
		local filename = subinstr("`filename'", "\", "/", 1)
	}
	// Frame name
	if trim("`frame'") == "" {
		local frame "BPstatFrame"
	}
	// Check if frame exists
	qui frame list 
	foreach item in `r(frames)' {
		if "`item'" == "`frame'" {
			if "`replace'" == "replace" {
				frame change default 
				frame drop `frame'
				continue, break
			}
			else {
				di as error `"Frame `frame' already defined. Specify option "replace" to replace the existing frame or create a new frame with option "frame""'
				error 110
			}
		}
	}
	// create new frame
	frame create `frame'
	// call python function (this will import the data to the newly created frame)
	python: get_data("`vars'", "`filename'", "`lg'", "`frame'")

	cap frame change `frame'
	if !_rc {
		* Format date
		qui ds
		foreach var in `r(varlist)' {
			if "`var'" == "date" {
				continue
			}
			else {
				local per = substr("`var'", 5, 1)
				continue, break
			}
		}
		tempvar date
		qui gen `date' = date(date, "YMD")
		drop date
		rename `date' date
		// Daily data
		if "`per'" == "D" {
			format %tdCCYY!_NN!_DD date
		}
		// Annual data
		else if "`per'" == "A" {
			qui replace date = yofd(date)
		}
		// Monthly
		else if "`per'" == "M" {
			qui replace date = mofd(date)
			format %tmCCYY!_NN date
		}
		// Quarterly
		else if "`per'" == "Q" {
			qui replace date = qofd(date)
			format %tqCCYY!_!qq date
		}
		// Biannual
		else {
			qui replace date = hofd(date)
			format %thCCYY!_!hh date
		}
		
		if "`en'" == "en" {
			label var date "Date of Reference"
		}
		else {
			label var date "Data de Referência"		
		}
		order date
		label data "BPSTAT - $S_TIME - $S_DATE"
		qui compress
		qui tsset date
	}

}

end

version 16
python:
import time
import webbrowser
import requests
import pandas as pd
from sfi import Frame


def create_url(*, base_url: str = "https://bpstat.bportugal.pt/data/v1/",
               series_ids: int,
               domain: int,
               dataset: str) -> str:
    """
    Returns a url based on the base url
    @series_ids: the code of the series or the comma separated values of the codes
    @domain: domain id
    @dataset: dataset id
    """
    return base_url + f"domains/{domain}/datasets/{dataset}/?lang=EN&series_ids={series_ids}"


def get_json(url: str) -> dict:
    """
    Returns a json object based on a request to <url>
    """
    wait = 0
    while True:
        time.sleep(wait)
        response = requests.get(url)
        if response.status_code == 200:
            print(f'Successful request')
            return response.json()
        elif response.status_code == 429:
            wait += 0.5
            print(f'Requests limits exceeded: increasing the waiting time to {wait} seconds')
            continue
        else:
            print(f'Response status code: {response.status_code}')
            break


def get_one_series(series: str, series_id: int, domain_id: int, dataset_id: str) -> 'DataFrame':
    """
    Returns a pandas DataFrame for the specified series
    @series: name of the series
    @series_id: series numeric code
    @domain_id: domain numeric code
    @dataset_id: dataset string code
    """
    # get observations for the series (json file)
    series_url = create_url(series_ids=series_id, domain=domain_id, dataset=dataset_id)
    data = get_json(series_url)
    # return the dataset
    try:
        return pd.DataFrame({'date': data['dimension']['reference_date']['category']['index'],
                             series: data['value']})
    # get_json returned None
    except KeyError:
        pass


def get_mult_series(info: list) -> list:
    """
    Returns a pandas DataFrame for the multiple specified series in the piz object
    @info: list with information about the series
    """
    # meta information (labels for variables)
    meta = {}
    # create DataFrame
    #print('\nReport:')
    for index, series in enumerate(info):
        var_name, domain_id, series_id, dataset_id, series_label = series
        print('\n' + var_name)
        meta[var_name] = series_label
        try:
            df = df.merge(get_one_series(var_name, series_id, domain_id, dataset_id), how='outer', on='date')
            print(f'Series imported: {index+1} of {len(info)}')
            # get_one_series returned None
        except TypeError:
            print('Not able to import data for series')
        except NameError:
            df = get_one_series(var_name, series_id, domain_id, dataset_id)
            # get_one_series returned None
            if df is None:
                print('Not able to import data for series')
                del df
            else:
                print(f'Series imported: {index+1} of {len(info)}')
    # create dataset in Stata
    stata_frame = Frame.connect(FRAME)
    stata_frame.setObsTotal(len(df))
    for item in df.columns:
        if str(df[item].dtype)[:3] in ['str', 'obj']:
            stata_frame.addVarStr(item, 1)
            stata_frame.store(item, None, df[item])
            if item == 'date':
                stata_frame.setVarLabel(item, 'Date of Reference')
            else:
                stata_frame.setVarLabel(item, meta[item])
        elif str(df[item].dtype)[:3] == 'int':
            stata_frame.addVarLong(item)
            stata_frame.store(item, None, df[item])
            stata_frame.setVarLabel(item, meta[item])
        else:
            stata_frame.addVarDouble(item)
            stata_frame.store(item, None, df[item])
            stata_frame.setVarLabel(item, meta[item])
			

def get_info(series: str, file: str, lang: str = 'EN') -> zip:
    """
    Returns a zip object with the information about the specified series
    Each tuple corresponds to a variable
        - tuple format: (variable name, series id, domain id, dataset id, series label)
        - example for variable D010M88873: ('D010M88873',
                                             88873,
                                             10,
                                            '9a04dd6b16441184dd993a5015490e72',
                                            'Total revenue - State BO - M€')
    @series: a string - codes separated by spaces
    @file: zip file with information about the series
    @lang: language selected
    """
    if lang == 'EN':
        info = pd.read_csv(file, usecols=['var', 'series_id', 'domain_id', 'dataset_id', 'series_label_en'])
        info = info.rename(columns={'series_label_en': 'series_label'})
    else:
        info = pd.read_csv(file, usecols=['var', 'series_id', 'domain_id', 'dataset_id', 'series_label_pt'])
        info = info.rename(columns={'series_label_pt': 'series_label'})
    # create dataset with chosen variables
    variables = pd.DataFrame({'var': [item.strip() for item in series.split()]})
    # get info on chosen variables by merging with info dataset
    merge = variables.merge(info, how='inner', on='var')
    if not merge.shape[0]:
        return
    # turn dataset into dict
    variables_info = merge.to_dict(orient='list')
    # return zip (later evaluated as list of tuples)
    return zip(variables_info['var'],
               variables_info['domain_id'],
               variables_info['series_id'],
               variables_info['dataset_id'],
               variables_info['series_label'])


def get_data(series: str, file: str, lang: str, frame: str) -> 'DataFrame':
    """
    gets data for the chosen series
    @series: comma separated values
    @file: stata file with information about the series
    """
    global FRAME
    FRAME = frame
    # check for errors
    series_list = [item.strip() for item in series.split()]
    try:
        domains = [int(item[1:4]) for item in series_list]
    except ValueError:
        raise ValueError('Specified series do not exist')
    else:
        # domain must be the same for all specified series
        if len(set(domains)) > 1:
            raise ValueError("Specified series do not belong to the same domain")
        # periodicity must be the same for all the series
        freqs = [item[4] for item in series_list]
        if len(set(freqs)) > 1:
            raise ValueError("Specified series do not have the same periodicity")
    try:
        info = list(get_info(series, file, lang))
    except TypeError:
        raise ValueError('Specified series do not exist')
    else:
        get_mult_series(info)
		
		
def browse(series: str) -> None:
    """
    browse pages for the chosen series
    @series: comma separated values
    """
    series_list = [item.strip() for item in series.split()]
    try:
        domains = [int(item[1:4]) for item in series_list]
    except ValueError:
        raise ValueError('Specified series do not exist')
    else:
        for series in series_list:
            webbrowser.open_new_tab(
                f'https://bpstat.bportugal.pt/serie/{series[5:]}'
            )
	
	
end

