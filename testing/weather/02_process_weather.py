# script gets URLs of all Australian BoM weather station observations
# ... and saves them to a CSV

import csv
import os
# import pandas
# import matplotlib.pyplot as plt
import requests

from bs4 import BeautifulSoup

# where to save the files
output_path = os.path.join(os.path.dirname(os.path.realpath(__file__)), "data")

# states to include (note: no "OT" state in BoM observations)
states = ["ACT", "NSW", "NT", "QLD", "SA", "TAS", "VIC", "WA"]

# urls for each state's weather observations
base_url = "http://www.bom.gov.au/{0}/observations/{0}all.shtml"

obs_urls = list()

for state in states:
    # get URL for web page to scrape
    input_url = base_url.format(state.lower())

    # load and parse web page
    r = requests.get(input_url)
    soup = BeautifulSoup(r.content, features="html.parser")

    # get all links
    links = soup.find_all('a', href=True)

    for link in links:
        url = link['href']

        if "/products/" in url:

            # change URL to get JSON file of weather obs
            obs_url = url.replace("/products/", "http://www.bom.gov.au/fwo/").replace(".shtml", ".json")
            # print(obs_url)

            obs_urls.append(obs_url)

with open(os.path.join(output_path, 'weather_observations_urls.txt'), 'w', newline='') as output_file:
    output_file.write("\n".join(obs_urls))

# download each obs file    
i = 1
num_urls = len(obs_urls)

for url in obs_urls:
    file_path = os.path.join(output_path, "obs", url.split("/")[-1])

    with open(file_path, 'w', newline='') as output_file:
        output_file.write(requests.get(url).text)

    print("Saved {} : {} of {}".format(file_path, i, num_urls))

    i += 1