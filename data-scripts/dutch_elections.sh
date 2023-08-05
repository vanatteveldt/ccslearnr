mkdir -p tmp

wget -P tmp -nc https://raw.githubusercontent.com/DIRKMJK/kiesraad/master/kiesraad/parse_eml.py
if [ ! -d env ]; then
    python3 -m venv env
    env/bin/pip install -r requirements.txt
fi

for i in {1..3}; do
    wget -P tmp -nc "https://data.overheid.nl/sites/default/files/dataset/be8b7869-4a12-4446-abab-5cd0a436dc4f/resources/EML_bestanden_PS2023_deel_$i.zip"
done

if [ ! -f tmp/elections_raw.csv ]; then
    env/bin/python dutch_elections.py
fi

wget -P tmp -nc https://www.cbs.nl/-/media/_excel/2022/37/2022-cbs-pc6huisnr20210801_buurt.zip
unzip -d tmp -n tmp/2022-cbs-pc6huisnr20210801_buurt.zip

if [ ! -f ../data/dutch_demographics.csv ]; then
    Rscript dutch_elections.R
fi

wget -P tmp -nc https://geodata.ucdavis.edu/gadm/gadm4.1/gpkg/gadm41_NLD.gpkg
