## dependencies and function definitions
library(elastic)
source(here::here("R", "retrieve_pdf.R"))

## Elasticsearch connection params
ES_index_name <- "ogrants"

## get csv from website
csv_path <- here::here("_site", "opengrants.csv")
if (!file.exists(csv_path))
{
  download.file("https://expanding-open-grants.github.io/ogrants/opengrants.csv",
                csv_path)
}
grants_df <- readr::read_csv(csv_path)
attr(grants_df, "problems") <- NULL
attr(grants_df, "spec") <- NULL
attr(grants_df, "class") <- "data.frame"

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

## loop over grants data
for (i in seq_len(NROW(grants_df)))
{
  baseurl <- "https://expanding-open-grants.github.io/ogrants/"
  
  # construct body from grants_df
  body <- as.list(grants_df[i,])
  body$url <- paste0(baseurl, body$url)
  body$url <- gsub("(?<!https:)//", "/", body$url, perl = TRUE)
  body$url <- gsub("(ogrants/){2,}", "ogrants/", body$url)
  body$link <- extract_raw_link(body$link)
  
  # retrieve pdf (probably should be wrapped to timeout)
  pdf_binary_dat <- get_binary_pdf_from_link(grants_df$link[i])
  if (!is.null(pdf_binary_dat))
  {
    # create temporary doc with temporary id for attachment ingestion
    stash_id <- "temp"
    pipeline_attachment(ES,
                        index = ES_index_name, 
                        id = stash_id, 
                        pipeline = "pdfin", 
                        make_body_attach(pdf_binary_dat))
    pdf_content <- docs_get(ES, ES_index_name, stash_id)
    body$attachment <- pdf_content$`_source`$attachment
  }

  # add document
  docs_create(ES, ES_index_name, 
              id = body$id, 
              body = body)
}

docs_delete(ES, ES_index_name, stash_id)
