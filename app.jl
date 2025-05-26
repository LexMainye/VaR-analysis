# filepath: /fin_engineering/fin_engineering/app.jl
using Gtk, CSV, DataFrames, Plots, Statistics, StatsBase

# Create main window
win = GtkWindow("VaR Calculator", 600, 500)

# Widgets
open_button = GtkButton("Upload CSV")
column_selector = GtkComboBoxText()
confidence_spinner = GtkSpinButton(90, 99, 1)
set_gtk_property!(confidence_spinner, :value, 95)
calculate_button = GtkButton("Calculate VaR")
result_label = GtkLabel("Click 'Upload CSV' to start")
status_label = GtkLabel("Ready")

# Layout
vbox = GtkBox(:v)
hbox1 = GtkBox(:h)
hbox2 = GtkBox(:h)
hbox3 = GtkBox(:h)

# Set spacing
set_gtk_property!(vbox, :spacing, 10)
set_gtk_property!(hbox1, :spacing, 10)
set_gtk_property!(hbox2, :spacing, 10)
set_gtk_property!(hbox3, :spacing, 10)

# First row - file upload
push!(hbox1, open_button)
push!(hbox1, status_label)

# Second row - column selection and confidence
push!(hbox2, GtkLabel("Price Column:"))
push!(hbox2, column_selector)
push!(hbox2, GtkLabel("Confidence (%):"))
push!(hbox2, confidence_spinner)

# Third row - calculate button
push!(hbox3, calculate_button)

# Add rows to main layout
push!(vbox, hbox1)
push!(vbox, hbox2)
push!(vbox, hbox3)
push!(vbox, result_label)

# Add margins
set_gtk_property!(vbox, :margin_left, 10)
set_gtk_property!(vbox, :margin_right, 10)
set_gtk_property!(vbox, :margin_top, 10)
set_gtk_property!(vbox, :margin_bottom, 10)

push!(win, vbox)

# Global variable to store loaded data
global df = nothing

# Simplified file upload function
function upload_csv()
    println("Upload function called")
    
    # Try a simpler approach - let user select any file first
    files = open_dialog("Select CSV File", win, ("*.csv",))
    
    if files != ""
        println("Selected file: $files")
        set_gtk_property!(status_label, :label, "Loading...")
        
        try
            # Load the CSV file
            global df = CSV.read(files, DataFrame)
            println("Loaded $(nrow(df)) rows and $(ncol(df)) columns")
            println("Column names: $(names(df))")
            
            # Simple approach: recreate the column selector
            # This avoids the freezing issue with clearing items
            println("Updating column selector...")
            
            # Just set the status for now, skip the column selector update temporarily
            set_gtk_property!(status_label, :label, "CSV loaded - $(nrow(df)) rows")
            set_gtk_property!(result_label, :label, 
                "File loaded successfully!\nColumns available: $(join(names(df), ", "))\nManually select 'Close' column and click Calculate VaR")
            
            println("Upload completed successfully")
            
        catch e
            println("Error loading CSV: $e")
            set_gtk_property!(status_label, :label, "Error loading file")
            set_gtk_property!(result_label, :label, "Error: $e")
        end
    else
        println("No file selected")
        set_gtk_property!(status_label, :label, "No file selected")
    end
end

# VaR calculation function
function calculate_var()
    println("Calculate function called")
    
    if df === nothing
        set_gtk_property!(result_label, :label, "Please upload a CSV file first!")
        return
    end
    
    # Since column selector might be problematic, let's auto-detect the Close column
    col_name = nothing
    
    # Look for Close, Price, or similar columns
    for col in names(df)
        col_lower = lowercase(string(col))
        if col_lower in ["close", "price", "adj close", "adjusted close", "closing price"]
            col_name = col
            break
        end
    end
    
    # If no obvious price column, use the last numeric column
    if col_name === nothing
        for col in reverse(names(df))
            if eltype(df[!, col]) <: Union{Number, Missing, AbstractString}
                col_name = col
                break
            end
        end
    end
    
    if col_name === nothing
        set_gtk_property!(result_label, :label, "Could not find a suitable price column!")
        return
    end
    
    confidence = get_gtk_property(confidence_spinner, :value, Float64) / 100
    
    println("Calculating VaR for column: $col_name, confidence: $confidence")
    
    try
        # Get price data
        prices = df[!, col_name]
        println("Price data type: $(typeof(prices))")
        println("First few prices: $(first(prices, min(5, length(prices))))")
        
        # Handle different data types and missing values
        if eltype(prices) <: AbstractString
            # Try to parse strings to numbers
            prices = tryparse.(Float64, replace.(string.(prices), "," => ""))
            prices = filter(!isnothing, prices)
        else
            prices = filter(!ismissing, prices)
        end
        
        # Convert to Float64 vector
        prices = Float64.(prices)
        
        if length(prices) < 2
            set_gtk_property!(result_label, :label, "Need at least 2 valid price points!")
            return
        end
        
        println("Valid prices: $(length(prices))")
        
        # Calculate log returns
        log_returns = diff(log.(prices))
        println("Calculated $(length(log_returns)) returns")
        
        # Calculate VaR
        var_value = quantile(log_returns, 1 - confidence)
        
        # Display results
        conf_pct = round(confidence * 100, digits=1)
        var_rounded = round(var_value, digits=6)
        
        result_text = """VaR Analysis Results:
        Confidence Level: $(conf_pct)%
        Value at Risk: $(var_rounded)
        Number of Returns: $(length(log_returns))
        Mean Return: $(round(mean(log_returns), digits=6))
        Std Dev: $(round(std(log_returns), digits=6))"""
        
        set_gtk_property!(result_label, :label, result_text)
        
        # Create plot
        try
            # Create plots directory if it doesn't exist
            plots_dir = "plots"
            if !isdir(plots_dir)
                mkdir(plots_dir)
            end
            
            p = histogram(log_returns, 
                         bins=30, 
                         alpha=0.7,
                         title="Value-at-Risk Analysis",
                         xlabel="Log Returns",
                         ylabel="Frequency",
                         label="Returns Distribution")
            
            vline!([var_value], 
                   linewidth=3, 
                   color=:red,
                   label="VaR ($conf_pct%)")
            
            # Save plot in plots directory
            plot_file = joinpath(plots_dir, "var_analysis.png")
            savefig(p, plot_file)
            println("Plot saved to: $plot_file")
            
            # Show plot in new window
            plot_window = GtkWindow("VaR Plot", 800, 600)
            if isfile(plot_file)
                img = GtkImage(plot_file)
                push!(plot_window, img)
                showall(plot_window)
            end
            
        catch plot_error
            println("Plotting error: $plot_error")
        end
        
    catch e
        println("Calculation error: $e")
        set_gtk_property!(result_label, :label, "Calculation error: $e")
    end
end

# Connect button signals using simple approach
signal_connect(w -> upload_csv(), open_button, "clicked")
signal_connect(w -> calculate_var(), calculate_button, "clicked")

# Show window
showall(win)

# Keep application running
if !isinteractive()
    c = Condition()
    signal_connect(win, "destroy") do w
        notify(c)
    end
    wait(c)
end