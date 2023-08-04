# parse_eml from https://github.com/DIRKMJK/kiesraad
# data from:
# - https://data.overheid.nl/dataset/verkiezingsuitslag-tweede-kamer-2021#panel-resources
# - https://data.overheid.nl/dataset/verkiezingsuitslag-provinciale-staten-2023

from pathlib import Path
from tmp.parse_eml import parse_eml
import tempfile
import zipfile
import pandas as pd

data = []

for f in Path.cwd().glob("tmp/*.zip"):
    print(f)
    with tempfile.TemporaryDirectory() as d:
        with zipfile.ZipFile(f, 'r') as zip_ref:
            zip_ref.extractall(d)
        dfs = parse_eml(d)
        data += dfs.values()

pd.concat(data).to_csv('tmp/elections_raw.csv', index=False)
