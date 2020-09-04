source(here::here("R", "retrieve_pdf.R"))

#### load in table of grants
grants_data <- here::here("_site", "opengrants.dat")
if (!file.exists(grants_data))
{
  download.file("https://expanding-open-grants.github.io/ogrants/opengrants.dat",
                grants_data)
}
grants_df <- read.table(grants_data, header = TRUE, sep = "|")

#### example link lookups
# example 1 - RIO DOI
link <- grants_df$link[1]
# <https://doi.org/10.3897/rio.2.e8760>

# example 2 - figshare DOI
link <- grants_df$link[4]
# <https://doi.org/10.6084/m9.figshare.1239172>

# example 3 - direct PDF link
link <- strsplit(grants_df$link[5], "><")[[1]][1]
# <https://www.niaid.nih.gov/sites/default/files/K01-Lilliam-Ambroggio-Application.pdf

# example 4 - zenodo DOI
link <- grants_df$link[63]
# <https://doi.org/10.5281/zenodo.3236624>

# example 5 - github
link <- strsplit(grants_df$link[13], "><")[[1]][1]
# <https://github.com/ybrandvain/GRFP/blob/master/Bird_NSF_Research_official.pdf

# example 6 - figshare (not working)
# there's some javascript redirect on the page
link <- grants_df$link[58]
# <https://doi.org/10.6084/m9.figshare.5217382>

# example 7 - google drive
link <- grants_df$link[139]
# <https://docs.google.com/file/d/0By0SDlWE5_VYV3hvS2FNSzFSSHUtbHlIWWhxUzFIQQ/>

# example 8 - zenodo with multiple links
link <- grants_df$link[163]
# <https://doi.org/10.5281/zenodo.1303986>

#### retrieving the binary data
binary_dat <- get_binary_pdf_from_link(link)

## binary data can be written to a file to check, e.g.
dest <- file.path(tempdir(), "test.pdf")
writeBin(binary_dat, dest)
cat("Wrote a pdf to ", dest)

