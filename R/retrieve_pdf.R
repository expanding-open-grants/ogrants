# package dependencies
#   magrittr
#   rvest
#   httr

library(magrittr)

# trim trailing single quotes and square brackets
extract_raw_link <- function(link)
{
  gsub("^['\\[]+|['\\]]+$", "", link, perl = TRUE)
}

# check 
resolves_into_pdf <- function(resp)
{
  httr::status_code(resp) == 200 && 
    grepl("pdf|binary|octet", httr::headers(resp)$`content-type`)
}

get_binary_pdf_from_link <- function(link)
{
  # access link
  link <- extract_raw_link(link)
  resp <- httr::GET(link)
  
  # check type of response
  if (httr::status_code(resp) != 200) {
    stop("link did not resolve", resp)
  }
  
  # received a pdf
  if (resolves_into_pdf(resp))
  {
    return(httr::content(resp, "raw"))
    ## binary data can be written to a file to check:
    # writeBin(binary_data, file.path(tempdir(), "test.pdf"))
  }
  
  # attempt to parse for a link to a pdf
  if (grepl("text/html", httr::headers(resp)$`content-type`)) {
    baseurl <- resp$url
    links <- rvest::read_html(resp) %>%
      rvest::html_nodes("a") %>%
      rvest::html_attr("href") %>%
      rvest::url_absolute(baseurl)
    
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


grants_df <- read.csv("data/opengrants.csv")

xx <- grants_df$link[1]
yy <- grants_df$link[4]
zz <- "https://doi.org/10.5281/zenodo.1302495"


get_pdf_from_link(xx)
get_pdf_from_link(yy)



