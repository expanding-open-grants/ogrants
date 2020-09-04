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
                     stash_id = "temp", 
                     silent = TRUE)
{
  msg("Constructing id = ", body$id, silent = silent)
  
  # check for existence
  doc_exists <- docs_get(conn, index, id = body$id, exists = TRUE)
  if (doc_exists)
  {
    doc <- docs_get(conn, index, id = body$id, verbose = !silent)
    attachment <- doc$`_source`$attachment
    if (!is.null(attachment))
    {
      msg("  attachment exists..skipping.", silent = silent)
      return()
    }
  }
  
  # construct body from grant_info
  body$url <- paste0(baseurl, body$url)
  body$url <- gsub("(?<!https:)//", "/", body$url, perl = TRUE)
  body$url <- gsub("(ogrants/){2,}", "ogrants/", body$url)
  body$link <- strsplit(body$link, "><")[[1]][1] # get first link
  body$link <- extract_raw_link(body$link)
  
  # retrieve pdf (probably should be wrapped to timeout)
  pdf_binary_dat <- get_binary_pdf_from_link(body$link)
  if (!is.null(pdf_binary_dat))
  {
    msg("  retrieved PDF data.", silent = silent)
    # create temporary doc for attachment ingestion
    pipeline_attachment(conn,
                        index, 
                        id = stash_id, 
                        pipeline = "pdfin", 
                        make_body_attach(pdf_binary_dat))
    pdf_content <- docs_get(conn, index, stash_id, verbose = FALSE)
    
    # get content back
    body$attachment <- pdf_content$`_source`$attachment
  }
  
  # coerce NAs
  body[is.na(body)] <- NA
  
  # add document
  docs_create(conn, 
              index, 
              id = body$id, 
              body = body)
  msg("  done.", silent = silent)
}

msg <- function(..., silent = FALSE)
{
  if (silent) { return() }
  message(...)
}