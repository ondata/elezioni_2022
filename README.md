# Dati scrutini Referendum 2022

**Nota bene**: i dati presenti in questo repository sono riutilizzabili e distribuiti con [Licenza Creative Commons Attribuzione 4.0 Internazionale](https://creativecommons.org/licenses/by/4.0/deed.it).<br>
Se li usi, cita questo repository (https://github.com/ondata/elezioni_2022/) e l'**Associazione onData**.

La **fonte dati** sono le API di Eligendo, che alimentano questo sito <https://elezioni.interno.gov.it/referendum/scrutini/20220612/scrutiniFI>.

Ad oggi - 15 giugno 2022 - il Ministero dell'Interno non rende scaricabili questi dati, ma soltanto visualizzabili a schermo.

# Referendum

## Scrutini Comuni Italiani

Il file con gli **scrutini** per **comune** è [`scrutini.csv`](referendum/output/scrutini.csv). Lo schema dati è invariato rispetto all'originale, con la sola aggiunta del codice Istat dei Comuni.<br>

Qui sotto 3 righe di esempio:

| comune | cod | desc | sz_perv | vot_m | vot_f | vot_t | perc_vot | sk_bianche | sk_nulle | sk_contestate | voti_si | voti_no | perc_si | perc_no | dt_agg | CODICE ISTAT |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 070370630 | 3 | Separazione delle funzioni dei magistrati ... | 1 | 19 | 27 | 46 | 13,26 | 0 | 1 | 0 | 32 | 13 | 71,11 | 28,89 | 20220613005830 | 008067 |
| 030150330 | 3 | Separazione delle funzioni dei magistrati ... | 5 | 324 | 306 | 630 | 17,84 | 11 | 6 | 0 | 498 | 115 | 81,24 | 18,76 | 20220613011631 | 017037 |
| 010272260 | 3 | Separazione delle funzioni dei magistrati ... | 1 | 14 | 5 | 19 | 13,67 | 1 | 0 | 0 | 14 | 4 | 77,78 | 22,22 | 20220613011956 | 004226 |

Ai dati è associato un file di anagrafica ([`scrutini-anagrafica.csv`](referendum/output/scrutini-anagrafica.csv)). Sotto 3 righe di esempio:

| comune | st | t_ele | t_ref | f_elet | dt_ele | l_terr | area | cod_com | desc_com | cod_prov | desc_prov | cod_reg | desc_reg | ele_m | ele_f | ele_t | sz_tot | CODICE ISTAT |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 030990380 | ESERCIZIO | Referendum | ABROGATIVO | SCRUTINI | 20220612000000 | COMUNE | I | 380 | MELETI | 99 | LODI | 3 | LOMBARDIA | 175 | 171 | 346 | 1 | 098038 |
| 010521420 | ESERCIZIO | Referendum | ABROGATIVO | SCRUTINI | 20220612000000 | COMUNE | I | 1420 | TRECATE | 52 | NOVARA | 1 | PIEMONTE | 6919 | 7173 | 14092 | 18 | 003149 |
| 150510100 | ESERCIZIO | Referendum | ABROGATIVO | SCRUTINI | 20220612000000 | COMUNE | I | 100 | BRUSCIANO | 51 | NAPOLI | 15 | CAMPANIA | 6180 | 6592 | 12772 | 14 | 063010 |

## Scrutini Estero

Il file con gli **scrutini** per **comune** è [`estero-scrutini.csv`](referendum/output/estero-scrutini.csv).<br>
Qui sotto 3 righe di esempio:

| cod | desc | sz_perv | ele_t | vot_t | perc_vot | sk_bianche | sk_nulle | sk_contestate | voti_si | voti_no | perc_si | perc_no | ced | ric | dt_agg | nazione | note |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | Abrogazione del Testo ... | 1 | 577 | 218 | 37,78 | 24 | 66 | 0 | 80 | 48 | 62,50 | 37,50 | N | N | 20220613102442 | 350 |  |
| 3 | Separazione delle funzioni dei magistrati ... | 54 | 246771 | 24299 | 9,85 | 613 | 2484 | 7 | 13001 | 8194 | 61,34 | 38,66 | N | N | 20220613165333 | 281 |  |
| 2 | Limitazione delle misure cautelari ... | 1 | 264 | 79 | 29,92 | 4 | 3 | 0 | 43 | 29 | 59,72 | 40,28 | N | S | 20220613090538 | 306 | UNO O PIU' CONSOLATI DELLO STATO HANNO EFFETTUATO LO SCRUTINIO CONGIUNTAMENTE A QUELLO DI UNO O PIU' CONSOLATI DI ALTRO STATO DA OGNUNO DEI QUALI SONO PERVENUTE MENO DI VENTI BUSTE |


Ai dati è associato un file di anagrafica  ([`estero-scrutini-anagrafica.csv`](referendum/output/estero-scrutini-anagrafica.csv)). Sotto 3 righe di esempio:

| st | t_ele | t_ref | f_elet | dt_ele | l_terr | area | cod_rip | desc_rip | cod_naz | desc_naz | sz_tot | nazione |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ESERCIZIO | Referendum | ABROGATIVO | SCRUTINI | 20220612000000 | NAZIONE | E | 4 | AFRICA ASIA OCEANIA ANTARTIDE | 351 | BURKINA FASO | 1 | 351 |
| ESERCIZIO | Referendum | ABROGATIVO | SCRUTINI | 20220612000000 | NAZIONE | E | 4 | AFRICA ASIA OCEANIA ANTARTIDE | 317 | ISRAELE | 3 | 317 |
| ESERCIZIO | Referendum | ABROGATIVO | SCRUTINI | 20220612000000 | NAZIONE | E | 4 | AFRICA ASIA OCEANIA ANTARTIDE | 370 | MAROCCO | 2 | 370 |

# Script

Lo [script](referendum.sh) usato per scaricare i dati fa uso di  [GNU Parallel](https://www.gnu.org/software/parallel/).
