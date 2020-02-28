*! version 0.2 28Feb2020
* Programmed by Gustavo Iglésias
* Dependencies: Python 3 (requests, pandas, ttkthemes)


program define bpstatdlg

version 16

syntax, [frame(string) replace]

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

// call python function (this will import the data to the newly created frame)
python clear 
python: main("`filename'", "`frame'", "`replace'")

cap frame change `frame'

if !_rc {

	local labdate: variable label date
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
	order date
	label var date "`labdate'"
	label data "BPSTAT - $S_TIME - $S_DATE"
	qui compress
	qui tsset date
}

end


version 16
python:

import time
import tkinter as tk
from tkinter import ttk
from tkinter import messagebox
import threading
from ttkthemes import themed_tk as tk_t
import requests
import pandas as pd
from sfi import Frame
from sfi import FrameError


def domainselmsgbox():
    """
    Shows message box with Selection Error when the user clicks on some button
    without selecting a domain
    """
    messagebox.showerror(title='Selection Error', message='Please select one domain')


def seriesselmsgbox():
    """
    Shows message box with Selection Error when the user clicks on some button
    without selecting at least one series
    """
    messagebox.showerror(title='Selection Error', message='Please select at least one series')


def get_geometry(*, height, width, relx, rely, relwidth, relheight):
    """
    Creates the geometry values for a Tk() app. As the geometry method for the app
    only allows absolute values, the function produces those arguments based on the
    relative position, height and width provided
    @height - screen height  (pixels)
    @width - screen width  (pixels)
    @relx - relative position of x on the screen
    @rely - relative position of y on the screen
    @relwidth- relative width
    @relheight- relative height
    """
    geom_width = int(width * relwidth)
    geom_heigt = int(height * relheight)
    geom_x = int(width * relx)
    geom_y = int(height * rely)

    return f'{geom_width}x{geom_heigt}+{geom_x}+{geom_y}'


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


def get_mult_series(info: list):
    """
    Creates the dataset with the user chosen variables in Stata
    @info: list of tuples with information about the series
           - tuple: (variable name, domain id, series id, dataset id, series label)
    """
    # meta information (labels for variables)
    meta = {}
    # create DataFrame
    #print('Report:')
    for series in info:
        var_name, domain_id, series_id, dataset_id, series_label = series
        print('\n' + var_name)
        meta[var_name] = series_label
        try:
            df = df.merge(get_one_series(var_name, series_id, domain_id, dataset_id), how='outer', on='date')
            print('Series imported')
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
                print('Series imported')
    # create dataset in Stata
    try:
        stata_frame = Frame.create(FRAME)
    # To allow the user to choose other series while inside the app
    # Drops the series previously imported
    except FrameError:
        stata_frame = Frame.connect(FRAME)
        stata_frame.drop()
        stata_frame = Frame.create(FRAME)
    finally:
        stata_frame.setObsTotal(len(df))
        for item in df.columns:
            if str(df[item].dtype)[:3] == 'obj':
                stata_frame.addVarStr(item, 1)
                stata_frame.store(item, None, df[item])
                if item == 'date':
                    if LANG == 'EN':
                        stata_frame.setVarLabel(item, 'Date of Reference')
                    else:
                        stata_frame.setVarLabel(item, 'Data de Referência')
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


def get_info(series: str) -> zip:
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
    """
    if LANG == 'EN':
        info = pd.read_csv(FILE, usecols=['var', 'series_id', 'domain_id', 'dataset_id', 'series_label_en'])
        info = info.rename(columns={'series_label_en': 'series_label'})
    else:
        info = pd.read_csv(FILE, usecols=['var', 'series_id', 'domain_id', 'dataset_id', 'series_label_pt'])
        info = info.rename(columns={'series_label_pt': 'series_label'})
    # create dataset with chosen variables
    variables = pd.DataFrame({'var': [item.strip() for item in series.split()]})
    # get info on chosen variables by merging with info dataset
    merge = variables.merge(info, how='inner', on='var')
    # turn dataset into dict
    variables_info = merge.to_dict(orient='list')
    # return zip (later evaluated as list of tuples)
    return zip(variables_info['var'],
               variables_info['domain_id'],
               variables_info['series_id'],
               variables_info['dataset_id'],
               variables_info['series_label'])


def get_data(series: str):
    """
    gets data for the chosen series
    @series: space separated values
    """
    info = list(get_info(series))
    # print equivalent command using bpstatuse
    get_mult_series(info)
    print('\n')
    if LANG == 'PT':
        print(f'bpstatuse, vars({series}) frame({FRAME}) {REPLACE}')
    else:
        print(f'bpstatuse, vars({series}) frame({FRAME}) en {REPLACE}')
    ROOT.destroy()


def download_data(variables):
    """
    This function is an intermediate step to download the data on a different
    thread. When we download the data without threading, the progress bar does
    not show up.
    @variables: specified series
    """
    x = threading.Thread(target=get_data, args=(variables,))
    x.start()


def download_window(window, variables):
    """
    Creates the download window with the progress bar
    code - indicator's code
    master - parent window
    """
    sub_window = tk.Toplevel(window)
    sub_window.title('BPStat')
    geom = get_geometry(height=HEIGHT, width=WIDTH, relx=0.4, rely=0.45, relwidth=0.2, relheight=0.125)
    sub_window.geometry(geom)
    lbl = ttk.Label(sub_window, text='Importing data', font='times 14 bold')
    lbl.place(relx=0.3, rely=0.2, relwidth=0.4)
    progbar = ttk.Progressbar(sub_window, orient=tk.HORIZONTAL, length=200, mode='indeterminate')
    progbar.place(relx=0.1, rely=0.6, relwidth=0.8)
    progbar.start(15)
    download_data(variables)


def create_arg(window, lbox):
    """
    Creates the argument for function get_data, which is a string with name of the variables
    separated by spaces
    @window: TopLevel
    @lbox: ListBox with variables
    """
    varlist = [lbox.get(item).split(':', maxsplit=1)[0] for item in lbox.curselection()]
    if not varlist:
        seriesselmsgbox()
        return
    variables = ' '.join(varlist)
    download_window(window, variables)


def select_all(lbox):
    """
    selects all items in lbox
    """
    lbox.select_set(0, tk.END)


def clear_all(lbox):
    """
    clears all items in lbox
    """
    lbox.selection_clear(0, tk.END)


def update_lbox(lbox, info_list, var, ind):
    """
    Updates the listbox if the user enters any text in the search box
    @lbox: Listbox with variables
    @info_list: list of tuples with information about the variables
                tuple format: (variable, series label, series description)
    @var: variable that traces the term entered in the serach box
    @ind: index of the tuple
    """
    search_term = var.get()
    lbox.delete(0, tk.END)
    for item in info_list:
        row = item[0] + ": " + item[ind]
        if search_term.lower() in row.lower():
            lbox.insert(tk.END, row)


def series_listbox(window, var, info):
    """
    Creates the Listbox inside the series menu
    @window: series window
    @var: variable that stores the value based on the chosen radiobutton (1 - labels, 2 - Descriptions)
    @info: list of tuples with information about the series
    """
    index = var.get()
    # Listbox
    listBox = tk.Listbox(window, width=100, height=20, selectmode=tk.MULTIPLE, bd=4)
    listBox.place(relx=0.05, rely=0.22, relwidth=0.9, relheight=0.6)
    for item in info:
        listBox.insert(tk.END, item[0] + ": " + item[index])
    # Label search
    lblsearch = ttk.Label(window, text='Search', font='times 13 bold')
    lblsearch.place(relx=0.05, rely=0.18, relwidth=0.1, relheight=0.04)
    # Entries
    search_var = tk.StringVar()
    search_var.trace('w', lambda name, ind, mode: update_lbox(listBox, info, search_var, index))
    entry = ttk.Entry(window, textvariable=search_var, width=120)
    entry.place(relx=0.15, rely=0.18, relwidth=0.8, relheight=0.0325)
    update_lbox(listBox, info, search_var, index)
    # Buttons
    # Button to import the data for the selected series
    button1 = ttk.Button(window,
                         width=15,
                         text='Import Data',
                         command=lambda win=window,
                                        lbox=listBox: create_arg(win, lbox))
    button1.place(relx=0.8, rely=0.9, relwidth=0.15)
    # Button to select all series available in the menu
    button2 = ttk.Button(window,
                         width=15,
                         text='Select all',
                         command=lambda x=listBox: select_all(x))
    button2.place(relx=0.65, rely=0.1, relwidth=0.15)
    # Button to clear all selections
    button3 = ttk.Button(window,
                         width=17,
                         text='Clear selections',
                         command=lambda x=listBox: clear_all(x))
    button3.place(relx=0.81, rely=0.1, relwidth=0.165)
    # scrollbars
    scrolly = ttk.Scrollbar(window, orient=tk.VERTICAL, command=listBox.yview)
    scrolly.place(relx=0.95, rely=0.22, relwidth=0.025, relheight=0.6)
    scrollx = ttk.Scrollbar(window, orient=tk.HORIZONTAL, command=listBox.xview)
    scrollx.place(relx=0.05, rely=0.8, relwidth=0.9, relheight=0.025)
    listBox.config(yscrollcommand=scrolly.set)
    listBox.config(xscrollcommand=scrollx.set)


def series_radio_mode(window, freq_var, info_list):
    """
    Creates radio buttons to choose between series description or labels
    in the menu
    @window: series window
    @freq_var: variable that stores information about the periodicity of the series - the user is only
               allowed to choose series with the same frequency
    @info_list: list of tuples with information about the series
    """
    freq = freq_var.get()
    # filter series with the same frequency
    filtered_info = [item for item in info_list if item[0][4] == freq]
    # Choose appearance for series (1 - Labels, 2 - Description)
    mode_var = tk.IntVar()
    # Buttons
    buttonshort = ttk.Radiobutton(window,
                                  text='Label',
                                  value=1,
                                  variable=mode_var,
                                  command=lambda win=window,
                                                 var=mode_var,
                                                 info=filtered_info: series_listbox(win, var, info))
    buttonshort.place(relx=0.05, rely=0.87, relwidth=0.1)
    buttonlong = ttk.Radiobutton(window,
                                 text='Description',
                                 value=2,
                                 variable=mode_var,
                                 command=lambda win=window,
                                                var=mode_var,
                                                info=filtered_info: series_listbox(win, var, info))
    buttonlong.place(relx=0.16, rely=0.87, relwidth=0.12)
    # Default button - Labels
    buttonshort.invoke()


def get_freqs(freqs):
    """
    Returns a list of tuples with information about the frequencies to create the radio buttons
    @freqs: iterable containing the available frequencies for a domain
    """
    freqs_dict = {
        'D': 'Daily',
        'M': 'Monthly',
        'Q': 'Quarterly',
        'B': 'Biannual',
        'A': 'Annual'
    }
    return [(freqs_dict[item], item) for item in freqs_dict if item in freqs]  # To preserve the order


def series_radio_freq(domain_label, series_info):
    """
    Creates the frequencies radio buttons for the chosen domain
    @domain_label: domain label
    @series_info: list of tuples with information about the series
    """
    series_window = tk.Toplevel(ROOT)
    series_window.title('BPStat Series')
    geom = get_geometry(height=HEIGHT, width=WIDTH, relx=0.2, rely=0.2, relwidth=0.6, relheight=0.6)
    series_window.geometry(geom)
    # create list of unique domains and corresponding label
    info = list(series_info)
    # get frequencies available for the chosen domain (A, B, Q, M, D)
    freqs_letters = set(item[0][4] for item in info)
    freqs = get_freqs(freqs_letters)
    # Labels
    lbl1 = ttk.Label(series_window, text=domain_label, font='times 16 bold')
    lbl1.place(relx=0.025, rely=0.025, relheight=0.05)
    # Variable that tracks the frequency chosen
    freq = tk.StringVar()
    # Radio Buttons
    radio_buttons = []
    for i, text_value in enumerate(freqs):
        radiob = ttk.Radiobutton(series_window,
                                 text=text_value[0],
                                 value=text_value[1],
                                 variable=freq,
                                 command=lambda wind=series_window,
                                                freq_var=freq,
                                                info_list=info: series_radio_mode(wind,
                                                                                  freq_var,
                                                                                  info_list))
        radiob.place(relx=0.05 + i * 0.11, rely=0.1, relwidth=0.1)
        radio_buttons.append(radiob)
    # Default button
    radio_buttons[0].invoke()


def select_item(lb, dids, dlabels, info_df):
    """
    Selects the domain specified by the user
    @lb: domains Listbox
    @dids: domain ids
    @dlabels: domain labels
    @info_df: Dataframe with information about the series
    """
    try:
        selected_item = lb.curselection()
        domain_id = dids[selected_item[0]]
        domain_label = dlabels[selected_item[0]]
    except IndexError:
        domainselmsgbox()
    else:
        # filter on the specified domain
        filtered_df = info_df[info_df['domain_id'] == domain_id]
        variables = filtered_df['var'].tolist()
        variables_desc = filtered_df['series_desc'].tolist()
        variables_labels = filtered_df['series_label'].tolist()
        series_info = zip(variables, variables_labels, variables_desc)
        series_radio_freq(domain_label, series_info)


def domain_listbox(df):
    """
    Main window to select domains
    @df: DataFrame with information about the variables
    """
    global ROOT
    ROOT = tk_t.ThemedTk()
    ROOT.get_themes()
    ROOT.set_theme('radiance')  # to use this theme, we have to use ttk
    ROOT.title('BPStat')
    # create list of unique domains and corresponding label
    domains = df.drop_duplicates(subset='domain_id')
    domains_id = domains['domain_id'].to_list()
    domains_label = domains['comp_label'].to_list()
    # Labels
    lbl1 = ttk.Label(ROOT, text='Select one domain', font='times 16 bold')
    lbl1.place(relx=0.025, rely=0.025)
    # Listbox
    listBox = tk.Listbox(ROOT, width=100, height=20, selectmode=tk.SINGLE, bd=4)
    listBox.place(relx=0.05, rely=0.15, relwidth=0.9, relheight=0.7)
    for item in domains_label:
        listBox.insert(tk.END, item)
    # Buttons
    button1 = ttk.Button(ROOT,
                         width=15,
                         text='Select',
                         command=lambda lb=listBox,
                                        dids=domains_id,
                                        dlabels=domains_label,
                                        info_df=df: select_item(lb, dids, dlabels, info_df))
    button1.place(relx=0.8, rely=0.9, relwidth=0.15)
    # scrollbars
    scrolly = ttk.Scrollbar(ROOT, orient=tk.VERTICAL, command=listBox.yview)
    scrolly.place(relx=0.95, rely=0.15, relwidth=0.025, relheight=0.7)
    scrollx = ttk.Scrollbar(ROOT, orient=tk.HORIZONTAL, command=listBox.xview)
    scrollx.place(relx=0.05, rely=0.85, relwidth=0.9, relheight=0.025)
    listBox.config(yscrollcommand=scrolly.set)
    listBox.config(xscrollcommand=scrollx.set)
    # run app
    geom = get_geometry(height=HEIGHT, width=WIDTH, relx=0.2, rely=0.2, relwidth=0.6, relheight=0.6)
    ROOT.geometry(geom)
    ROOT.mainloop()


def read_file(language, window):
    """
    Creates the Dataframe with information about the series
    @language - variable that tracks the language selected by the user
    @window - language window
    """
    global LANG
    if language.get() == 'EN':
        menu_file = pd.read_csv(FILE,
                                usecols=['var', 'domain_id', 'series_label_en', 'series_desc_en', 'comp_label_en'])
        menu_file = menu_file.rename(columns={'series_desc_en': 'series_desc',
                                              'comp_label_en': 'comp_label',
                                              'series_label_en': 'series_label'})
        LANG = 'EN'
    else:
        menu_file = pd.read_csv(FILE,
                                usecols=['var', 'domain_id', 'series_label_pt', 'series_desc_pt', 'comp_label_pt'])
        menu_file = menu_file.rename(columns={'series_desc_pt': 'series_desc',
                                              'comp_label_pt': 'comp_label',
                                              'series_label_pt': 'series_label'})
        LANG = 'PT'
    window.destroy()
    domain_listbox(menu_file)


def select_lang():
    """
    Window to select language for the domains and series labels and descriptions
    """
    global HEIGHT, WIDTH
    # Language window
    lang = tk_t.ThemedTk()
    lang.title('BPStat')
    lang.get_themes()
    lang.set_theme('radiance')  # to use this theme, we have to use ttk
    # Radio button
    language = tk.StringVar(lang)
    radio1 = ttk.Radiobutton(lang, text='PT', value='PT', var=language)
    radio1.place(relx=0.2, rely=0.2, relwidth=0.15)
    radio2 = ttk.Radiobutton(lang, text='EN', value='EN', var=language)
    radio2.place(relx=0.65, rely=0.2, relwidth=0.15)
    radio2.invoke()
    # Buttons to continue
    langbutton = ttk.Button(lang,
                            text='Continue',
                            width=10,
                            command=lambda lang_var=language,
                                           lang_window=lang: read_file(lang_var, lang_window))
    langbutton.place(relx=0.3, rely=0.6, relwidth=0.4)
    # set geometry in relative terms
    HEIGHT = lang.winfo_screenheight()
    WIDTH = lang.winfo_screenwidth()
    geom = get_geometry(height=HEIGHT, width=WIDTH, relx=0.4, rely=0.45, relwidth=0.2, relheight=0.125)
    lang.geometry(geom)
    lang.mainloop()


def main(file: str, frame: str, replace: str):
    """
    Main program
    """
    global FILE, FRAME, REPLACE
    FRAME = frame
    FILE = file
    REPLACE = replace
    select_lang()

	

end 

