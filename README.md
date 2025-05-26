# VaR Calculator Project

This project implements a Value at Risk (VaR) calculator using Julia. It consists of two main components: data fetching and a graphical user interface for calculating VaR.

## Project Files

- **Data.jl**: 
  - Fetches historical stock data for Microsoft (MSFT) using the YFinance package.
  - Processes the data to retain only the date and close price.
  - Saves the processed data as a CSV file.
  - Generates a plot of the stock prices over the last year.

- **app.jl**: 
  - Implements a VaR calculator using the Gtk library for the user interface.
  - Allows users to upload a CSV file, select a price column, and calculate the VaR based on the selected data.
  - Displays the results and generates a histogram of log returns.

- **Dockerfile**: 
  - Contains instructions to build a Docker image for the project.
  - Sets up the Julia environment, installs necessary packages, and runs the `app.jl` file.

## Getting Started

### Prerequisites

- Docker installed on your machine.

### Building the Docker Image

To build the Docker image, navigate to the project directory and run the following command:

```
docker build -t var_calculator .
```

### Running the Docker Container

After building the image, you can run the container with the following command:

```
docker run -it --rm var_calculator
```

This will start the VaR calculator application.

## Usage

1. Click on "Upload CSV" to load the stock price data.
2. Select the appropriate price column from the dropdown menu.
3. Set the confidence level using the spinner.
4. Click "Calculate VaR" to compute the Value at Risk.
5. The results will be displayed, along with a histogram of log returns.

## Analysis Findings

The VaR calculator was tested with Microsoft (MSFT) stock data over a 5-year period, producing the following insights:

### Statistical Results
- **Confidence Level**: 95.0%
- **Value at Risk**: -0.027343 (or -2.73%)
- **Number of Returns**: 1256 trading days
- **Mean Return**: 0.000723 (or 0.072%)
- **Standard Deviation**: 0.017083 (or 1.71%)

### Interpretation
- At a 95% confidence level, the maximum expected daily loss is 2.73%
- The positive mean return (0.072%) indicates a consistent upward trend
- The standard deviation of 1.71% suggests moderate daily price volatility
- Analysis covers a substantial dataset of 1256 trading days (~ 5 years)

### Visualization Analysis
The histogram of log returns reveals:
- A bell-shaped distribution centered near zero, with peak frequency around 300 occurrences
- Returns primarily concentrated between -0.05 and 0.05 (±5% daily movement)
- VaR threshold marked by the red vertical line at -0.027343 (-2.73%)
- High data quality with 1257 observations providing statistical robustness
- Key distribution characteristics:
  * Highest frequency bars clustered around 0%, indicating stable daily price movements
  * Slightly asymmetric with longer left tail (negative skewness)
  * Approximate normal distribution shape suggesting predictable market behavior
  * Few extreme events beyond ±5%, showing controlled volatility
  * Clear VaR boundary capturing 95% of return scenarios

This distribution visualization confirms MSFT's stable trading pattern with well-defined risk boundaries, supporting the statistical findings of moderate volatility and positive trend.

## License

This project is licensed under the MIT License.