*! version 0.3 3Nov2020
* Programmed by Gustavo Iglésias
* Dependencies: Python 3 (requests and pandas)


program define bpstatdescribe

version 16

syntax, vars(string) [en]

if "`en'" == "en" {
	local lg "EN"
}
else {
	local lg "PT"
}

di 

python: describe("`vars'", "`lg'")

end

version 16
python:
import time
import requests


def get_json(url: str) -> dict:
    """
    Returns a json object based on a request to <url>
    """
    wait = 0
    while True:
        time.sleep(wait)
        response = requests.get(url)
        if response.status_code == 200:
            #print(f'Successful request')
            return response.json()
        elif response.status_code == 429:
            wait += 0.5
            print(f'Requests limits exceeded: increasing the waiting time to {wait} seconds')
            continue
        else:
            print(f'Response status code: {response.status_code}')
            break
			

def format_long_string(string, maxlen):
    list_string = list(string)
    for index in range(0,len(list_string), 70):
        if index == 0:
            continue
        else:
            list_string.insert(index, "\n" + (maxlen+2) * " ")
    
    return "".join(list_string)


def get_max_len(items):
    return max([len(item) for item in items])


def get_cat_info(domain, dimension_id, cat_id, lang):
    info = requests.get(
        f"https://bpstat.bportugal.pt/data/v1/domains/{domain}/dimensions/{dimension_id}/?lang={lang}"
    ).json()
    
    return {
        info['label']: info['category']['label'][f'{cat_id}']
    }


def get_domain_label(domain_id, lang):
    info = requests.get(
        f"https://bpstat.bportugal.pt/data/v1/domains/{domain_id}/?lang={lang}"
    ).json() 

    return {
        'domain_label': info['label']
    }


def print_info(series, info, lang):
    info = info[0]
    # get info for periodicity and unit of measure
    cats = [item for item in info['dimension_category'] if item['dimension_id'] in (40, 70)]
    del info["dimension_category"]
    del info["short_label"]
    info.update(
        get_domain_label(info['domain_ids'][0], lang)
    )
    for cat in cats:
        cat_info = get_cat_info(info['domain_ids'][0], cat['dimension_id'], cat['category_id'], lang)
        info.update(cat_info)

    key_maxlen = get_max_len(info.keys())

    print(f"************** {series} **************")
    print("")
    for item in info:
        space = (key_maxlen - len(item)) * " "
        if item == "label" or item == "description":
            print(f"{item}{space}: {format_long_string(info[item], key_maxlen)}")
        else:
            print(f"{item}{space}: {info[item]}")
    print("\n")

		
def describe(series, lang: str) -> None:
    """
    describe series specified by the user
    @series: comma separated values
    """
    series_list = [item.strip() for item in series.split()]
    try:
        domains = [int(item[1:4]) for item in series_list]
    except ValueError:
        raise ValueError('Specified series do not exist')
    else:
        for series in series_list:
            url = f"https://bpstat.bportugal.pt/data/v1/series/?lang={lang}&series_ids={series[5:]}"
            series_meta = get_json(url)
            print_info(series, series_meta, lang)
	
end