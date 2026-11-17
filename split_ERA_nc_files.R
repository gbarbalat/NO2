library(stars)

# 1. Define directories
base_dir <- "C:/Documents and Settings/Guillaume/Downloads"
out_dir  <- file.path(base_dir, "Daily_NC_2024")
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

# 2. Map the folder/zip month labels to month numbers (1 to 12)
# Adjust patterns if your exact folder/zip names vary slightly (e.g., "April2024" vs "Apr2024")
month_patterns <- c(
  "Jv2024", "Feb2024", "March2024", "April2024", "May2024", "June2024",
  "July2024", "Aug2024", "Sept2024", "Oct2024", "Nov2024", "Dec2024"
)

# Find all .zip files in Downloads
zip_files <- list.files(base_dir, pattern = "\\.zip$", full.names = TRUE)

# 3. Loop through each month (1 = Jan ... 12 = Dec)
for (m in seq_along(month_patterns)) {
  pat <- month_patterns[m]
  matched_zip <- zip_files[grepl(pat, basename(zip_files), ignore.case = TRUE)]
  
  if (length(matched_zip) == 0) {
    warning(paste("No zip file found matching:", pat))
    next
  }
  
  # Unzip into a temporary folder for this month
  temp_unzip_dir <- file.path(tempdir(), paste0("unzip_m", m))
  unzip(matched_zip[1], exdir = temp_unzip_dir)
  
  # Locate the instant stepType .nc file inside the extracted archive
  nc_file <- list.files(
    temp_unzip_dir, 
    pattern = "stepType-instant\\.nc$", 
    full.names = TRUE, 
    recursive = TRUE
  )
  
  if (length(nc_file) == 0) {
    warning(paste("No instant .nc file found inside:", basename(matched_zip[1])))
    next
  }
  
  # Read the monthly NetCDF file
  tmp <- read_stars(nc_file[1])
  
  # Dynamically calculate start and end dates for month m in 2024
  start_date <- as.Date(sprintf("2024-%02d-01", m))
  end_date   <- seq(start_date, by = "month", length.out = 2)[2] - 1
  dates      <- seq(start_date, end_date, by = "day")
  
  message(sprintf("Processing %s (%d days)...", pat, length(dates)))
  
  # 4. Slice each 24-hour day and export as YYYYMMDD.nc
  for (i in seq_along(dates)) {
    start_idx <- (i - 1) * 24 + 1
    end_idx   <- i * 24
    
    daily_slice <- tmp[, , , start_idx:end_idx]
    
    out_name <- paste0(format(dates[i], "%Y%m%d"), ".nc")
    out_path <- file.path(out_dir, out_name)
    
    write_mdim(daily_slice, out_path)
  }
  
  # Clean up extracted temp files to save disk space
  unlink(temp_unzip_dir, recursive = TRUE)
}
