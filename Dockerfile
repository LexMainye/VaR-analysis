FROM julia:1.8

# Set the working directory
WORKDIR /fin_engineering

# Copy the project files into the container
COPY . .

# Install necessary Julia packages
RUN julia -e 'using Pkg; Pkg.add(["YFinance", "DataFrames", "Plots", "CSV", "Gtk", "Statistics", "StatsBase"])'

# Run the Data.jl script to fetch and process stock data
RUN julia Data.jl

# Set up the container to use the host X server for GUI
ENV DISPLAY=:0

# Command to run the app (GUI will appear on host)
CMD ["julia", "app.jl"]