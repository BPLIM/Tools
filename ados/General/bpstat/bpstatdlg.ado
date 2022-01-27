*! version 0.4 27Jan2022
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
import webbrowser
import requests
import pandas as pd
from sfi import Frame
from sfi import FrameError


class SeriesWindow:

    def __init__(self, parent, file, domain_label, series_info, language, frame, replace):
        """Series window. Allows the user to choose BPstat series from 
        a previously specified domain

        Parameters
        ----------
        parent : tkinter.Tk()
            parent window
        file : str
            zip file with meta data on the series
        domain_label : str
            label of the domain specified by the user
        series_info : zip
            information about series, labels and descriptions
        language : str
            display language of series' labels and descriptions
        frame : str
            Stata frame
        replace : str
            replace option in Stata
        """
        self.parent = parent
        self.series_window = tk.Toplevel(self.parent)
        self.file = file
        self.domain_label = domain_label
        self.series_info = series_info
        self.language = language
        self.frame = frame
        self.replace = replace
    
        self.series_window.title(f'BPstat Series - {self.domain_label.split(" - ")[0]}')
        self.series_window.geometry(
            get_geometry(
                height=self.parent.winfo_screenheight(), 
                width=self.parent.winfo_screenwidth(), 
                relx=0.2, rely=0.2, relwidth=0.65, relheight=0.65
            )
        )
        # create list of unique domains and corresponding label
        self.info = list(self.series_info)
        # get frequencies available for the chosen domain (A, B, Q, M, D)
        freqs_letters = set(item[0][4] for item in self.info)
        freqs = SeriesWindow.get_freqs(freqs_letters)
        # Labels
        try:
            lbl1 = ttk.Label(
                self.series_window, 
                text=self.domain_label.split(" - ")[1], 
                font='times 12 bold'
            )
            lbl1.place(relx=0.025, rely=0.025, relheight=0.05)
        except IndexError:
            pass
        # Variable that tracks the frequency chosen
        self.freq = tk.StringVar()
        # Radio Buttons
        radio_buttons = []
        for i, text_value in enumerate(freqs):
            radiob = ttk.Radiobutton(
                self.series_window,
                text=text_value[0],
                value=text_value[1],
                variable=self.freq,
                command=self.series_radio_mode
            )
            radiob.place(relx=0.05 + i * 0.11, rely=0.1, relwidth=0.11)
            radio_buttons.append(radiob)
        # Default button
        radio_buttons[0].invoke()

    def series_radio_mode(self):
        """Creates radio buttons to choose between series description or labels
        in the menu
        """
        freq = self.freq.get()
        # filter series with the same frequency
        self.filtered_info = [item for item in self.info if item[0][4] == freq]
        # Choose appearance for series (1 - Labels, 2 - Description)
        self.mode_var = tk.IntVar()
        # Buttons
        buttonshort = ttk.Radiobutton(
            self.series_window,
            text='Label',
            value=1,
            variable=self.mode_var,
            command=self.series_listbox
        )
        buttonshort.place(relx=0.05, rely=0.87, relwidth=0.1)
        buttonlong = ttk.Radiobutton(
            self.series_window,
            text='Description',
            value=2,
            variable=self.mode_var,
            command=self.series_listbox
        )
        buttonlong.place(relx=0.16, rely=0.87, relwidth=0.15)
        # Default button - Labels
        buttonshort.invoke()

    def series_listbox(self):
        """Creates the listbox where the series are placed, along with the search
        bar for user input and four buttons
        """
        self.index = self.mode_var.get()
        # Listbox
        self.listBox = tk.Listbox(
            self.series_window, 
            width=100, 
            height=20, 
            selectmode=tk.MULTIPLE, 
            bd=4
        )
        self.listBox.place(relx=0.05, rely=0.24, relwidth=0.9, relheight=0.58)
        for item in self.filtered_info:
            self.listBox.insert(tk.END, item[0] + ": " + item[self.index])
        # Label search
        lblsearch = ttk.Label(
            self.series_window, 
            text='Search', 
            font='times 14 bold', 
            anchor=tk.NW
        )
        lblsearch.place(relx=0.05, rely=0.18, relwidth=0.1, relheight=0.05)
        # Entries
        self.search_var = tk.StringVar()
        self.search_var.trace('w', lambda name, ind, mode: self.update_lbox())
        entry = ttk.Entry(
            self.series_window, 
            textvariable=self.search_var, 
            width=120
        )
        entry.place(relx=0.15, rely=0.18, relwidth=0.8, relheight=0.05)
        #entry.config
        self.update_lbox()
        # Buttons
        # Button to import the data for the selected series
        button1 = ttk.Button(
            self.series_window,
            width=15,
            text='Import Data',
            command=self.create_arg
        )
        button1.place(relx=0.8, rely=0.9, relwidth=0.15)
        # Button to browse series
        button2 = ttk.Button(
            self.series_window,
            width=15,
            text='Browse',
            command=self.browse
        )
        button2.place(relx=0.65, rely=0.9, relwidth=0.12)
        # Button to select all series available in the menu
        button3 = ttk.Button(
            self.series_window,
            width=12,
            text='Select all',
            command=self.select_all
        )
        button3.place(relx=0.68, rely=0.1, relwidth=0.12)
        # Button to clear all selections
        button4 = ttk.Button(
            self.series_window,
            width=17,
            text='Clear selected',
            command=self.clear_all
        )
        button4.place(relx=0.81, rely=0.1, relwidth=0.165)
        # scrollbars
        scrolly = ttk.Scrollbar(
            self.series_window, 
            orient=tk.VERTICAL, 
            command=self.listBox.yview
        )
        scrolly.place(relx=0.95, rely=0.22, relwidth=0.025, relheight=0.6)
        scrollx = ttk.Scrollbar(
            self.series_window, 
            orient=tk.HORIZONTAL, 
            command=self.listBox.xview
        )
        scrollx.place(relx=0.05, rely=0.8, relwidth=0.9, relheight=0.035)
        self.listBox.config(yscrollcommand=scrolly.set)
        self.listBox.config(xscrollcommand=scrollx.set)

    def update_lbox(self):
        """Updates the listbox if the user enters any text in the 
        search box
        """
        search_term = self.search_var.get()
        self.listBox.delete(0, tk.END)
        for item in self.filtered_info:
            row = item[0] + ": " + item[self.index]
            if search_term.lower() in row.lower():
                self.listBox.insert(tk.END, row)

    def create_arg(self):
        """Creates the argument for method get_data, which is a string with 
        name of the variables separated by spaces
        """
        varlist = [
            self.listBox.get(item).split(':', maxsplit=1)[0] for item in self.listBox.curselection()
        ]
        if not varlist:
            errormsgbox(
                title='Selection Error', 
                message='Please select at least one series'
            )
            return
        self.variables = ' '.join(varlist)
        self.download_window()

    def download_window(self):
        """Creates the download window with the progress bar
        """
        sub_window = tk.Toplevel(self.series_window)
        sub_window.title('BPstat')
        sub_window.geometry(
            get_geometry(
                height=self.parent.winfo_screenheight(), 
                width=self.parent.winfo_screenwidth(), 
                relx=0.4, rely=0.45, relwidth=0.3, relheight=0.15)
        )
        lbl = ttk.Label(
            sub_window, 
            text='Importing data', 
            font='times 14 bold'
        )
        lbl.place(relx=0.3, rely=0.2, relwidth=0.4)
        lbl.configure(anchor="center")
        progbar = ttk.Progressbar(
            sub_window, 
            orient=tk.HORIZONTAL, 
            length=200, 
            mode='indeterminate'
        )
        progbar.place(relx=0.1, rely=0.6, relwidth=0.8)
        progbar.start(15)
        self.download_data()

    def download_data(self):
        """Intermediate step to download the data on a different
        thread. When we download the data without threading, the 
        progress bar does not show up.
        """
        x = threading.Thread(target=self.get_data)
        x.start()

    def get_data(self):
        """Extracts data for the chosen series
        """
        info = list(self.get_info())
        # print equivalent command using bpstatuse
        self.get_mult_series(info)
        print('\n')
        if self.language == 'PT':
            print(f'bpstat use, vars({self.variables}) frame({self.frame}) {self.replace}')
        else:
            print(f'bpstat use, vars({self.variables}) frame({self.frame}) en {self.replace}')
        self.parent.destroy()

    def get_info(self) -> zip:
        """Returns a zip object with the information about the 
        specified series. Each tuple corresponds to a variable

        tuple format: (variable name, series id, domain id, dataset id, series label)
        example for variable D010M88873: 
            (
                'D010M88873', 
                88873, 
                10, 
                '9a04dd6b16441184dd993a5015490e72',
                'Total revenue - State BO - M€'
            )
        """
        if self.language == 'EN':
            info = pd.read_csv(
                self.file, 
                usecols=['var', 'series_id', 'domain_id', 'dataset_id', 'series_label_en']
            )
            info = info.rename(columns={'series_label_en': 'series_label'})
        else:
            info = pd.read_csv(
                self.file, 
                usecols=['var', 'series_id', 'domain_id', 'dataset_id', 'series_label_pt']
            )
            info = info.rename(columns={'series_label_pt': 'series_label'})
        # create dataset with chosen variables
        variables = pd.DataFrame({'var': [item.strip() for item in self.variables.split()]})
        # get info on chosen variables by merging with info dataset
        merge = variables.merge(info, how='inner', on='var')
        # turn dataset into dict
        variables_info = merge.to_dict(orient='list')
        # return zip (later evaluated as list of tuples)
        return zip(
            variables_info['var'],
            variables_info['domain_id'],
            variables_info['series_id'],
            variables_info['dataset_id'],
            variables_info['series_label']
        )

    def get_mult_series(self, info: list):
        """Creates the dataset with the user chosen variables in Stata

        Parameters
        ----------
        info : list[tuple]
            information about the series
        """
        # meta information (labels for variables)
        meta = {}
        # create DataFrame
        #print('Report:')
        for index, series in enumerate(info):
            var_name, domain_id, series_id, dataset_id, series_label = series
            print('\n' + var_name)
            meta[var_name] = series_label
            try:
                df = df.merge(
                    SeriesWindow.get_one_series(
                        var_name, 
                        series_id, 
                        domain_id, 
                        dataset_id
                    ), 
                    how='outer', on='date'
                )
                print(f'Series imported: {index+1} of {len(info)}')
            # get_one_series returned None
            except TypeError:
                print('Not able to import data for series')
            except NameError:
                df = SeriesWindow.get_one_series(var_name, series_id, domain_id, dataset_id)
                # get_one_series returned None
                if df is None:
                    print('Not able to import data for series')
                    del df
                else:
                    print(f'Series imported: {index+1} of {len(info)}')
        # create dataset in Stata        
        try:
            stata_frame = Frame.create(self.frame)
        # To allow the user to choose other series while inside the app
        # Drops the series previously imported
        except FrameError:
            stata_frame = Frame.connect(self.frame)
            stata_frame.drop()
            stata_frame = Frame.create(self.frame)
        finally:
            stata_frame.setObsTotal(len(df))
            for item in df.columns:
                if str(df[item].dtype)[:3] == 'obj':
                    stata_frame.addVarStr(item, 1)
                    stata_frame.store(item, None, df[item])
                    if item == 'date':
                        if self.language == 'EN':
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

    def browse(self):
        """Browses the the selected series in the official site
        """
        varlist = [
            self.listBox.get(item).split(':', maxsplit=1)[0] for item in self.listBox.curselection()
        ]
        if not varlist:
            errormsgbox(
                title='Selection Error', 
                message='Please select at least one series'
            )
            return
        for var in varlist:
            webbrowser.open_new_tab(
                f'https://bpstat.bportugal.pt/serie/{var[5:]}'
            )

    def select_all(self):
        """Selects all items in the listbox
        """
        self.listBox.select_set(0, tk.END)

    def clear_all(self):
        """Clears all items in the listbox
        """
        self.listBox.selection_clear(0, tk.END)

    @staticmethod
    def get_freqs(freqs) -> list:
        """Returns a list of tuples with information about the 
        frequencies to create the radio buttons

        Parameters
        ----------
        freqs : set
            available frequencies for a domain

        Returns
        -------
        list
            available frequencies for a specified domain
        """
        freqs_dict = {
            'D': 'Daily',
            'M': 'Monthly',
            'Q': 'Quarterly',
            'B': 'Biannual',
            'A': 'Annual'
        }
        # To preserve the order
        return [(freqs_dict[item], item) for item in freqs_dict if item in freqs] 

    @staticmethod
    def get_one_series(
            series: str, series_id: int, 
            domain_id: int, dataset_id: str
        ) -> pd.DataFrame:
        """Returns a pandas DataFrame for the specified series

        Parameters
        ----------
        series : str
            name of the series
        series_id : int
            series numeric code
        domain_id : int
            domain numeric code
        dataset_id : str
            dataset string code

        Returns
        -------
        pd.DataFrame
            series data
        """
        # get observations for the series (json file)
        series_url = SeriesWindow.create_url(
            series_ids=series_id, 
            domain=domain_id, 
            dataset=dataset_id
        )
        data = SeriesWindow.get_json(series_url)
        # return the dataset
        try:
            return pd.DataFrame(
                {
                    'date': data['dimension']['reference_date']['category']['index'],
                    series: data['value']
                }
            )
        # get_json returned None
        except KeyError:
            pass

    @staticmethod
    def create_url(
            *, base_url: str = "https://bpstat.bportugal.pt/data/v1/",
            series_ids: int, domain: int, dataset: str
        ) -> str:
        """Creates the API series url 

        Parameters
        ----------
        series_ids : int
            code of the series or the comma separated values of the codes
        domain : int
            domain id
        dataset : str
            dataset id
        base_url : str, optional
            api base url, by default "https://bpstat.bportugal.pt/data/v1/"

        Returns
        -------
        str
            series API url
        """
        return base_url + f"domains/{domain}/datasets/{dataset}/?lang=EN&series_ids={series_ids}"

    @staticmethod
    def get_json(url: str) -> dict:
        """Extracts json data from the API

        Parameters
        ----------
        url : str
            API series url

        Returns
        -------
        dict
            series data
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


class DomainWindow:
    
    def __init__(self, language, file, meta_df, frame, replace):
        """Domain window. Allows the user to choose a domain for
        the BPstat series

        Parameters
        ----------
        language : str
            display language of series' labels and descriptions
        file : str
            zip file with meta data on the series
        meta_df : pandas.DataFrame
            dataframe with series meta data 
        frame : str
            Stata frame
        replace : str
            replace option in Stata
        """
        self.language = language
        self.file = file
        self.meta_df = meta_df
        self.frame = frame
        self.replace = replace

        self.root = tk_t.ThemedTk()
        self.root.get_themes()
        self.root.set_theme('radiance') 
        self.root.title("BPstat")
        self.root.geometry(
            get_geometry(
                height=self.root.winfo_screenheight(), 
                width=self.root.winfo_screenwidth(), 
                relx=0.2, rely=0.2, relwidth=0.6, relheight=0.65
            )
        )
        # create list of unique domains and corresponding label
        domains = self.meta_df.drop_duplicates(subset='domain_id')
        self.domains_id = domains['domain_id'].to_list()
        self.domains_label = domains['comp_label'].to_list()
        # Labels
        lbl1 = ttk.Label(
            self.root, 
            text='Select one domain', 
            font='times 16 bold'
        )
        lbl1.place(relx=0.025, rely=0.025)
        # Listbox
        self.listBox = tk.Listbox(
            self.root, 
            width=100, 
            height=20, 
            selectmode=tk.SINGLE, 
            bd=4
        )
        self.listBox.place(relx=0.05, rely=0.15, relwidth=0.9, relheight=0.7)
        for item in self.domains_label:
            self.listBox.insert(tk.END, item)
        # Buttons
        button1 = ttk.Button(
            self.root,
            width=15,
            text='Select',
            command=self.select_item)
        button1.place(relx=0.8, rely=0.9, relwidth=0.15)
        # scrollbars
        scrolly = ttk.Scrollbar(
            self.root, 
            orient=tk.VERTICAL, 
            command=self.listBox.yview
        )
        scrolly.place(relx=0.95, rely=0.15, relwidth=0.025, relheight=0.7)
        scrollx = ttk.Scrollbar(
            self.root, 
            orient=tk.HORIZONTAL, 
            command=self.listBox.xview
        )
        scrollx.place(relx=0.05, rely=0.85, relwidth=0.9, relheight=0.035)
        self.listBox.config(yscrollcommand=scrolly.set)
        self.listBox.config(xscrollcommand=scrollx.set)
        self.root.mainloop()

    def select_item(self):
        """Selects the domain specified by the user and launches
        the Series Window
        """
        try:
            selected_item = self.listBox.curselection()
            domain_id = self.domains_id[selected_item[0]]
            domain_label = self.domains_label[selected_item[0]]
        except IndexError:
            errormsgbox(
                title='Selection Error', 
                message='Please select one domain'
            )
        else:
            # filter on the specified domain
            filtered_df = self.meta_df[self.meta_df['domain_id'] == domain_id]
            variables = filtered_df['var'].tolist()
            variables_desc = filtered_df['series_desc'].tolist()
            variables_labels = filtered_df['series_label'].tolist()
            series_info = zip(variables, variables_labels, variables_desc)
            SeriesWindow(
                self.root, self.file, domain_label, series_info, 
                self.language, self.frame, self.replace
            )


class LanguageWindow:

    def __init__(self, zipfile, frame, replace):
        """Language window. Allows the user to select
        the language for series labels and descriptions 

        Parameters
        ----------
        zipfile : str
            zip file with series meta data
        frame : str
            Stata frame
        replace : str
            replace option in Stata
        """
        self.zipfile = zipfile
        self.frame = frame 
        self.replace = replace

        self.root = tk_t.ThemedTk()
        self.root.get_themes()
        self.root.set_theme('radiance') 
        self.root.title("BPstat")
        self.root.geometry(
            get_geometry(
                height=self.root.winfo_screenheight(), 
                width=self.root.winfo_screenwidth(), 
                relx=0.4, rely=0.45, relwidth=0.25, relheight=0.125
            )
        )
        self.language = tk.StringVar(self.root)
        radio1 = ttk.Radiobutton(
            self.root, 
            text='PT', 
            value='PT', 
            var=self.language
        )
        radio1.place(relx=0.2, rely=0.2, relwidth=0.2)
        radio2 = ttk.Radiobutton(
            self.root, 
            text='EN', 
            value='EN', 
            var=self.language
        )
        radio2.place(relx=0.6, rely=0.2, relwidth=0.2)
        radio2.invoke()
        # Buttons to continue
        langbutton = ttk.Button(
            self.root, 
            text='Continue',
            width=10, 
            command=self.read_file
        )
        langbutton.place(relx=0.3, rely=0.6, relwidth=0.4)
        self.root.mainloop()

    def read_file(self):
        """Reads the zip file with series meta data
        and launches the Domain Window
        """

        if self.language.get() == 'EN':
            meta_df = pd.read_csv(
                self.zipfile,
                usecols=[
                    'var', 'domain_id', 'series_label_en', 
                    'series_desc_en', 'comp_label_en'
                ]
            )
            meta_df = meta_df.rename(
                columns={
                    'series_desc_en': 'series_desc',
                    'comp_label_en': 'comp_label',
                    'series_label_en': 'series_label'
                }
            ) 
        else:
            meta_df = pd.read_csv(
                self.zipfile,
                usecols=[
                    'var', 'domain_id', 'series_label_pt', 
                    'series_desc_pt', 'comp_label_pt'
                ]
            )
            meta_df = meta_df.rename(
                columns={
                    'series_desc_pt': 'series_desc',
                    'comp_label_pt': 'comp_label',
                    'series_label_pt': 'series_label'
                }
            )
        self.root.destroy()
        DomainWindow(
            self.language.get(), self.zipfile, 
            meta_df, self.frame, self.replace
        )


def errormsgbox(title: str, message: str):
    """Show error dialog box

    Parameters
    ----------
    title : str
        Dialog box title
    message : str
        Dialog box error message
    """
    messagebox.showerror(title=title, message=message)


def get_geometry(
        height: int, width: int, relx: float, 
        rely: float, relwidth: float, relheight: float
    ) -> str:
    """Creates the geometry values for a Tk() app. As the 
    geometry method for the app only allows absolute values, 
    the function produces those arguments based on the
    relative positions, height and width provided

    Parameters
    ----------
    height : int
        screen height  (pixels)
    width : int
        screen width  (pixels)
    relx : float
        relative position of x on the screen
    rely : float
        relative position of y on the screen
    relwidth : float
        relative width
    relheight : float
        relative height

    Returns
    -------
    str
        window geometry
    """
    geom_width = int(width * relwidth)
    geom_heigt = int(height * relheight)
    geom_x = int(width * relx)
    geom_y = int(height * rely)

    return f'{geom_width}x{geom_heigt}+{geom_x}+{geom_y}'


def main(file: str, frame: str, replace: str):
    """Main program
    """
    LanguageWindow(file, frame, replace)


end 

