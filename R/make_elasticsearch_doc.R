# construct attachment JSON
make_body_attach <- function(binary_dat)
{
  paste0('{\n  "fulltext": "', base64enc::base64encode(binary_dat), '"\n}')
}

# construct elastic search document
make_doc <- function(conn, 
                     index, 
                     body, 
                     baseurl = "https://expanding-open-grants.github.io/ogrants/", 
                     stash_id = "temp")
{
  # construct body from grant_info
  body$url <- paste0(baseurl, body$url)
  body$url <- gsub("(?<!https:)//", "/", body$url, perl = TRUE)
  body$url <- gsub("(ogrants/){2,}", "ogrants/", body$url)
  body$link <- extract_raw_link(body$link)
  
  # retrieve pdf (probably should be wrapped to timeout)
  pdf_binary_dat <- get_binary_pdf_from_link(body$link)
  if (!is.null(pdf_binary_dat))
  {
    # create temporary doc for attachment ingestion
    pipeline_attachment(conn,
                        index, 
                        id = stash_id, 
                        pipeline = "pdfin", 
                        make_body_attach(pdf_binary_dat))
    pdf_content <- docs_get(conn, index, stash_id)
    
    # get content back
    body$attachment <- pdf_content$`_source`$attachment
  }
  
  # add document
  docs_create(conn, 
              index, 
              id = body$id, 
              body = body)
}
