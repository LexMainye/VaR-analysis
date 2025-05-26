# Load necessary packages
using YFinance, Dates, DataFrames, Plots, CSV

# Fetch MSFT historical data
df = DataFrame(get_prices("MSFT", range="5y", interval="1d", divsplits=true, exchange_local_time=false))

# Convert to DataFrame
select!(df, [:timestamp, :close])  # Keep only date and close price
rename!(df, :timestamp => :Date, :close => :Close)


# Create the  data directory if it doesn't exist
data_dir = "data"
if !isdir(data_dir)
    mkdir(data_dir)
end

# Save to CSV in the "data" folder
csv_path = joinpath(data_dir, "MSFT_stock_prices.csv")
CSV.write(csv_path, df)

println("Saved to: ", csv_path)

# Plot the data
plot(df.Date, df.Close, 
    label="MSFT Close Price", 
    xlabel="Date", 
    ylabel="Price",
    title="Microsoft (MSFT) Stock Price - Last Year",
    linewidth=2,
    color=:blue)
    
# Create the "plots" directory if it doesn't exist
plots_dir = "plots"
if !isdir(plots_dir)
    mkdir(plots_dir)
end

# Save to the "plots" folder
savefig(joinpath(plots_dir, "msft_stock_price.png")) 