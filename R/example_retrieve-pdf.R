source(here::here("R", "retrieve_pdf.R"))

#### load in table of grants
# download.file("https://expanding-open-grants.github.io/ogrants/opengrants.csv",
#               "data/opengrants.csv")
grants_df <- read.csv("data/opengrants.csv")

#### example link lookups
# example 1 - RIO DOI
link <- grants_df$link[1]
# 'https://doi.org/10.3897/rio.2.e8760'

# example 2 - figshare DOI
link <- grants_df$link[4]
# 'https://doi.org/10.6084/m9.figshare.1239172'

# example 3 - direct PDF link
link <- grants_df$link[5]
# '[https://www.niaid.nih.gov/sites/default/files/K01-Lilliam-Ambroggio-Application.pdf'

# example 4 - zenodo DOI
link <- grants_df$link[75]
# 'https://doi.org/10.5281/zenodo.3236624'

#### retrieving the binary data
binary_dat <- get_binary_pdf_from_link(link)

## binary data can be written to a file to check, e.g.
dest <- file.path(tempdir(), "test.pdf")
writeBin(binary_dat, dest)
cat("Wrote a pdf to ", dest)
