## dependencies and function definitions
library(elastic)
source(here::here("R", "retrieve_pdf.R"))

## Elasticsearch connection params
ES_index_name <- "ogrants"

## get csv from website
csv_path <- file.path(tempdir(), "opengrants.csv")
download.file("https://expanding-open-grants.github.io/ogrants/opengrants.csv",
              csv_path)
grants_df <- readr::read_csv(csv_path)

ES <- connect()

## setup ingestion pipeline
boddy <- '{
  "description" : "Extract attachment information",
  "version" : 1,
  "processors" : [
    {
      "attachment" : {
        "field": "fulltext",
        "indexed_chars" : -1
      }
    }
  ]
}'
pipeline_create(ES, id = 'pdfin', body = boddy)

# check if index exists
if (!index_exists(ES, ES_index_name)) index_create(ES, ES_index_name)

# attach function
make_body_attach <- function(binary_dat)
{
  paste0('{\n  "fulltext": "', base64enc::base64encode(binary_dat), '"\n}')
}

## loop over grants data
for (i in seq_len(NROW(grants_df)))
{
  # TODO: check if `id` = grants_df$id[i] exists as a document
  
  # retrieve pdf (probably should be wrapped to timeout)
  pdf_binary_dat <- get_binary_pdf_from_link(grants_df$link[i])
  if (is.null(pdf_binary_dat)) { next() }
  
  # attach pdf
  pipeline_attachment(ES,
                      index = ES_index_name, 
                      id = grants_df$id[i], 
                      pipeline = "pdfin", 
                      make_body_attach(pdf_binary_dat))
}

