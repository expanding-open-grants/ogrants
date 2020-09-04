## dependencies and function definitions
library(elastic)
source(here::here("R", "retrieve_pdf.R"))
source(here::here("R", "make_elasticsearch_doc.R"))

## Elasticsearch connection params
ES_index_name <- "ogrants"

## get csv from website
grants_data <- here::here("_site", "opengrants.dat")
if (!file.exists(grants_data))
{
  download.file("https://expanding-open-grants.github.io/ogrants/opengrants.dat",
                grants_data)
}
grants_df <- read.table(grants_data, header = TRUE, sep = "|")
# attr(grants_df, "problems") <- NULL
# attr(grants_df, "spec") <- NULL
# attr(grants_df, "class") <- "data.frame"

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

stash_id <- "temp"

## loop over grants data
grants_list <- split(grants_df, seq(NROW(grants_df)))
for (grant_info in grants_list)
{
  message(grant_info$id)
  body <- as.list(grant_info)
  make_doc(conn = ES, 
           index = ES_index_name, 
           body = body, 
           stash_id = stash_id, 
           silent = TRUE)
}

docs_create(ES, ES_index_name, stash_id)
docs_delete(ES, ES_index_name, stash_id)
