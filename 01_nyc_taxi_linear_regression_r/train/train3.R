#' Copyright(c) Microsoft Corporation.
#' Licensed under the MIT license.

library(azuremlsdk)
library(optparse)


options <- list(
  make_option(c("-d", "--data_folder")),
  make_option(c("-u", "--username"))
)

opt_parser <- OptionParser(option_list = options)
opt <- parse_args(opt_parser)

#printing out to log the data folder
paste(opt$data_folder)

#printing out to the log the user name
paste(opt$username)


#read from file
filename <- paste(opt$username, "green-taxi.Rd", sep="-")
paste(filename)

paste("about to read RDS")
df <- readRDS(file.path(opt$data_folder, filename))

summary(df)
#-----------------------------
set.seed(42)

#------------------------
sample_size_split <- as.integer(nrow(df) * .80)

print(nrow(df))
print(sample_size_split)

df_idx <- sample(1:nrow(df), sample_size_split)
df_train <- df[df_idx, ]
nrow(df_train)
df_test <- df[-df_idx, ]
nrow(df_test)

RMSE = function(model){
  RMSE_train = sqrt(mean(resid(model) ^ 2))
  RMSE_test = sqrt(mean(( df_test$totalAmount - predict(model, newdata = df_test))^2))
  
  values = c(
    RMSE_train = RMSE_train, 
    RMSE_test = RMSE_test)
}


#------------------------------------------

print("About to generate model Model 3")
mod = lm(totalAmount ~ vendorID*tripDistance + vendorID*passengerCount, data = df_train)



print("Summary of Model")
summary(mod)

results = RMSE(mod)

log_metric_to_run("R^2", summary(mod)$r.squared)
log_metric_to_run("RMSE Train", results['RMSE_train'])
log_metric_to_run("RMSE Test", results['RMSE_test'])


summary(mod)$r.squared

summary(mod)$coef


output_dir = "outputs"
if (!dir.exists(output_dir)){
  dir.create(output_dir)
}
saveRDS(mod, file = "./outputs/model.rds")
message("Model saved")