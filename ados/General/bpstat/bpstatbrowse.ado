*! version 0.3 30Oct2020
* Programmed by Gustavo Iglésias
* Dependencies: Python 3 (requests and pandas)


program define bpstatbrowse

version 16

syntax, vars(string)

python: browse("`vars'")



end

version 16
python:
import webbrowser
		
		
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