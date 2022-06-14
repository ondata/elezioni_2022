#!/bin/bash

### requisiti ###
# miller https://github.com/johnkerl/miller
# gnu parallel https://www.gnu.org/software/parallel/
# jq https://stedolan.github.io/jq/
### requisiti ###

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# crea cartelle di lavoro
mkdir -p "$folder"/referendum/rawdata/scrutini
mkdir -p "$folder"/referendum/rawdata/scrutini/estero
mkdir -p "$folder"/referendum/processing/scrutini
mkdir -p "$folder"/referendum/resources


# svuota cartella dati grezzi
rm "$folder"/referendum/rawdata/scrutini/*
rm "$folder"/referendum/rawdata/scrutini/estero/*
rm "$folder"/referendum/processing/scrutini/*

# scarica anagrafica ripartizioni territoriali italiane
curl -kL "https://elezioni.interno.gov.it/tornate/20220612/enti/comunali_territoriale_italia.json" >"$folder"/referendum/resources/ita.json


# converti anagrafica in TSV
jq <"$folder"/referendum/resources/ita.json '.enti' | mlr --j2t unsparsify then filter '$tipo=="CM"' then cut -f cod,desc then put -S '$RE=sub($cod,"^([0-9]{2})(.+)$","\1");$PR=sub($cod,"^([0-9]{2})([0-9]{3})(.+)$","\2");$CM=sub($cod,"^(.+)([0-9]{4})$","\2")' | tail -n +2 >"$folder"/referendum/resources/itaCM.tsv

# scarica in parallelo i dati sui comuni
parallel --colsep "\t" --max-args 1 -j50% 'curl -k -L --max-time 1200 --connect-timeout 1200 "https://eleapi.interno.gov.it/siel/PX/scrutiniFI/DE/20220612/TE/09/RE/{3}/PR/{4}/CM/{5}" \
-H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:101.0) Gecko/20100101 Firefox/101.0" \
-H "Accept: application/json, text/javascript, */*; q=0.01" \
-H "Accept-Language: it,en-US;q=0.7,en;q=0.3" \
-H "Accept-Encoding: gzip, deflate, br" \
-H "Content-Type: application/json" \
-H "Origin: https://elezioni.interno.gov.it" \
-H "DNT: 1" \
-H "Connection: keep-alive" \
-H "Referer: https://elezioni.interno.gov.it/" \
-H "Sec-Fetch-Dest: empty" \
-H "Sec-Fetch-Mode: cors" \
-H "Sec-Fetch-Site: same-site" \
-H "Pragma: no-cache" \
-H "Cache-Control: no-cache" \
-H "TE: trailers" --compressed >./referendum/rawdata/scrutini/{1}.json 2>/dev/null' :::: ./referendum/resources/itaCM.tsv

if [ -f "$folder"/referendum/processing/scrutini.jsonl ]; then
  rm "$folder"/referendum/processing/scrutini.jsonl
fi

# converti in unico JSONL i dati sugli scrutini
for i in "$folder"/referendum/rawdata/scrutini/*.json; do
  #crea una variabile da usare per estrarre nome e estensione
  filename=$(basename "$i")
  #estrai estensione
  extension="${filename##*.}"
  #estrai nome file
  filename="${filename%.*}"
  jq <"$i" -c '.scheda[]' | mlrgo --jsonl put '$comune="'"$filename"'";$comune=sub($comune,".+/","");$comune=regextract($comune,"[0-9]+")' >>"$folder"/referendum/processing/scrutini.jsonl
done

if [ -f "$folder"/referendum/processing/scrutini-anagrafica.jsonl ]; then
  rm "$folder"/referendum/processing/scrutini-anagrafica.jsonl
fi

# converti in unico JSONL i dati sull'anagrafica
for i in "$folder"/referendum/rawdata/scrutini/*.json; do
  #crea una variabile da usare per estrarre nome e estensione
  filename=$(basename "$i")
  #estrai estensione
  extension="${filename##*.}"
  #estrai nome file
  filename="${filename%.*}"
  jq <"$i" -c '.int' | mlrgo --jsonl put '$comune="'"$filename"'";$comune=sub($comune,".+/","");$comune=regextract($comune,"[0-9]+")' >>"$folder"/referendum/processing/scrutini-anagrafica.jsonl
done

# converti in CSV i JSONL
mlr --j2c unsparsify "$folder"/referendum/processing/scrutini-anagrafica.jsonl >"$folder"/referendum/processing/scrutini-anagrafica.csv
mlr --j2c unsparsify "$folder"/referendum/processing/scrutini.jsonl >"$folder"/referendum/processing/scrutini.csv

# scarica anagrafica stati esteri
curl -kL "https://elezioni.interno.gov.it/tornate/20220612/enti/referendum_territoriale_estero.json" >"$folder"/referendum/resources/estero.json

# converti anagrafica in TSV
jq <"$folder"/referendum/resources/estero.json '.enti' | mlr --j2t unsparsify then filter '$tipo=="NA"' then cut -f cod,desc then put -S '$ER="0".sub($cod,"^([0-9]{1})(.+)$","\1");$cod=sub($cod,"^[0-9]","")' | tail -n +2 >"$folder"/referendum/resources/esteroCM.tsv

# fai pulizia cartella dati grezzi
find ./referendum/rawdata/scrutini/estero -iname "*.json" -delete

# scarica in parallelo i dati sull'estero delle nazioni
parallel --colsep "\t" --max-args 1 -j50% 'curl -k -L --max-time 1200 --connect-timeout 1200  "https://eleapi.interno.gov.it/siel/PX/scrutiniFE/DE/20220612/TE/09/ER/{3}/NA/{1}" \
-H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:101.0) Gecko/20100101 Firefox/101.0" \
-H "Accept: application/json, text/javascript, */*; q=0.01" \
-H "Accept-Language: it,en-US;q=0.7,en;q=0.3" \
-H "Accept-Encoding: gzip, deflate, br" \
-H "Content-Type: application/json" \
-H "Origin: https://elezioni.interno.gov.it" \
-H "DNT: 1" \
-H "Connection: keep-alive" \
-H "Referer: https://elezioni.interno.gov.it/" \
-H "Sec-Fetch-Dest: empty" \
-H "Sec-Fetch-Mode: cors" \
-H "Sec-Fetch-Site: same-site" \
-H "Pragma: no-cache" \
-H "Cache-Control: no-cache" \
-H "TE: trailers" --compressed >./referendum/rawdata/scrutini/estero/{1}.json 2>/dev/null' :::: ./referendum/resources/esteroCM.tsv

if [ -f "$folder"/referendum/processing/estero-scrutini.jsonl ]; then
  rm "$folder"/referendum/processing/estero-scrutini.jsonl
fi

# unisci i dati sugli scrutini dai singoli json a un unico JSONL
for i in "$folder"/referendum/rawdata/scrutini/estero/*.json; do
  #crea una variabile da usare per estrarre nome e estensione
  filename=$(basename "$i")
  #estrai estensione
  extension="${filename##*.}"
  #estrai nome file
  filename="${filename%.*}"
  jq <"$i" -c '.scheda[]' | mlrgo --jsonl put '$nazione="'"$filename"'";$nazione=sub($nazione,".+/","");$nazione=regextract($nazione,"[0-9]+")' >>"$folder"/referendum/processing/estero-scrutini.jsonl
done

if [ -f "$folder"/referendum/processing/estero-scrutini-anagrafica.jsonl ]; then
  rm "$folder"/referendum/processing/estero-scrutini-anagrafica.jsonl
fi

# unisci i dati sull'anagrafica dai singoli json a un unico JSONL
for i in "$folder"/referendum/rawdata/scrutini/estero/*.json; do
  #crea una variabile da usare per estrarre nome e estensione
  filename=$(basename "$i")
  #estrai estensione
  extension="${filename##*.}"
  #estrai nome file
  filename="${filename%.*}"
  jq <"$i" -c '.int' | mlrgo --jsonl put '$nazione="'"$filename"'";$nazione=sub($nazione,".+/","");$nazione=regextract($nazione,"[0-9]+")' >>"$folder"/referendum/processing/estero-scrutini-anagrafica.jsonl
done

# converti i JSONL in CSV
mlr --j2c unsparsify then cut -x -f note_din then rename -r -r '"note.+",note'  "$folder"/referendum/processing/estero-scrutini.jsonl >"$folder"/referendum/output/estero-scrutini.csv
mlrgo --j2c unsparsify "$folder"/referendum/processing/estero-scrutini-anagrafica.jsonl > "$folder"/referendum/output/estero-scrutini-anagrafica.csv

# estrai colonne per JOIN codici ISTAT comuni
mlr --csv cut -f "CODICE ISTAT",comune  "$folder"/risorse/codici_comuni.csv >"$folder"/referendum/processing/anagrafica-comuni.csv

# aggiungi all'anagrafica i codici comunali Istat
mlrgo --csv join --ul -j comune -f "$folder"/referendum/processing/scrutini-anagrafica.csv then unsparsify "$folder"/referendum/processing/anagrafica-comuni.csv >"$folder"/referendum/output/scrutini-anagrafica.csv

# aggiungi agli scrutini i codici comunali Istat
mlrgo --csv join --ul -j comune -f "$folder"/referendum/processing/scrutini.csv then unsparsify "$folder"/referendum/processing/anagrafica-comuni.csv >"$folder"/referendum/output/scrutini.csv
