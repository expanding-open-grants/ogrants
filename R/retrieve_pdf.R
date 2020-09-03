`%>%` <- magrittr::`%>%`

# trim trailing single quotes and square brackets
extract_raw_link <- function(link)
{
  gsub("^['\\[]+|['\\]]+$", "", link, perl = TRUE)
}

# check if result from httr::GET might be a pdf or binary stream
resolves_into_pdf <- function(resp)
{
  httr::status_code(resp) == 200 && 
    grepl("pdf|binary|octet", httr::headers(resp)$`content-type`)
}

# try to resolve a URL into a binary pdf stream
get_binary_pdf_from_link <- function(link, skip_on_error = TRUE)
{
  dat <- NULL
  tryCatch(dat <- retrieve_pdf_from_link(link), 
           error = function(e) {
             if (skip_on_error)
             {
               warning("skipping error")
             } else {
               e
             }
           })
  return(dat)
}

retrieve_pdf_from_link <- function(link)
{
  # access link
  link <- extract_raw_link(link)
  resp <- httr::GET(link)
  
  # check type of response
  if (httr::status_code(resp) != 200) {
    stop("link did not resolve", resp)
  }
  
  # received a pdf
  if (resolves_into_pdf(resp)) { return(httr::content(resp, "raw")) }
  
  # attempt to parse for a link to a pdf
  if (grepl("text/html", httr::headers(resp)$`content-type`)) {
    baseurl <- resp$url
    links <- xml2::read_html(resp) %>%
      rvest::html_nodes("a") %>%
      rvest::html_attr("href") %>%
      xml2::url_absolute(baseurl)
    
    # check for links that contain "pdf"
    pdf_link <- unique(grep("pdf", links, value = TRUE))
    if (length(pdf_link) == 1)
    {
      resp <- httr::GET(pdf_link)
      if (resolves_into_pdf(resp)) { return(httr::content(resp, "raw")) }
    }
    
    # check for links that contain "download"
    download_link <- unique(grep("download", links, value = TRUE))
    if (length(download_link) == 1)
    {
      resp <- httr::GET(download_link)
      if (resolves_into_pdf(resp)) {return(httr::content(resp, "raw"))}
    }
    
    warning("unable to resolve link into a pdf: ", link)
    return(NULL)
  }
  
  stop("unable to resolve link")
}
