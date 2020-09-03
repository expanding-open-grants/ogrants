# Indexing of grant fulltext document

## Overview

Scripts and functions to process the open grants data and help feed it into Elasticsearch.

## Usage

*The following shell commands assume a working directory that is the root folder, and not the `R/` folder that this README resides in.*

To run the data generation loop, use

```bash
Rscript R/load_grants_data.R
```

To run the example PDF retrieval script, use

```bash
Rscript R/example_retrieve-pdf.R
```

## Package dependencies

* `magrittr`
* `rvest`
* `httr`
* `here`
* `elastic`
* `readr`

## File listing

* `load_grants_data.R` - commented script to load grant metadata and pdfs into Elasticsearch
* `example_retrieve-pdf.R` - commented script demo-ing the functions to read in the opengrants.csv data table and resolve individual links into PDF streams
* `retrieve_pdf.R` - function definitions to resolve links into PDF streams
* `make_elasticsearch_doc.R` - function definitions to load data into Elasticsearch

## TODO

* deal with grants entries with multiple links:
  - this currently gets output with commas at https://expanding-open-grants.github.io/ogrants/opengrants.csv, which causes some problems reading the data in
  - potentially resolved by fixing the Liquid syntax in `{repo root}/opengrants.csv`, or by reading in the output csv file and processing it better
* future-proofing by caching data and/or automating the lookup of new entries
