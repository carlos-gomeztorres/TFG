# Unsupervised Machine Learning for Football Club Valuation

## Description
This repository contains the code, data, and supplementary materials for the research paper titled "Valuing European Football Clubs as Investment Assets through Unsupervised Machine Learning Algorithms". The paper explores the application of advanced machine learning techniques such as Principal Component Analysis (PCA), Self-Organizing Maps (SOM), and Agglomerative Hierarchical Clustering to assess the investment potential of football clubs. By utilizing these unsupervised learning techniques, the research aims to enhance the reliability and granularity of football club valuations, offering stakeholders a data-driven framework for more informed decision-making.

## Table of Contents
1. [Structure](#structure)
2. [Technologies Used](#tech-used)
3. [Installation and Setup](#install)
4. [Data](#data)
5. [Data and Usage](#usage)

## Structure {#structure}

``` bash
.
├── data/               # Contains raw, auxiliary, processed, and scraped data
│   ├── raw/            # Raw data used in the project
│   ├── aux/            # Auxiliary data for support calculations and scraping
│   ├── processed/      # Cleaned and preprocessed data ready for analysis
│   └── scraped/        # Scraped data collected from Transfermarkt
│
├── notebooks/          # RMarkdown notebooks with data preprocessing and modeling
│   ├── financial_data_preprocessing.Rmd   # Preprocessing steps for financial data
│   ├── football_data_preprocessing.Rmd    # Preprocessing steps for football performance data
│   └── Main.Rmd        # Main notebook with clustering and valuation analysis
│
├── scripts/            # R scripts for data collection, functions, and plotting
│   ├── scraping/       # Scripts for web scraping data from Transfermarkt
│   ├── functions/      # Helper functions for calculations and data transformations
│   └── plotting/       # Scripts for data visualization
│
└── README.md           # This file, providing an overview of the repository
```

## Technologies Used {#tech-used}

This project is entirely implemented in R. The following R packages are crucial for different aspects of the project:

| **Project Part**                | **Packages**                                    |
|----------------------------------|-------------------------------------------------|
| Web Scraping                     | `rvest`, `parallel`                             |
| Data Manipulation                | `tidyverse`                                    |
| Principal Component Analysis (PCA)| `base: prcomp`                                 |
| Self-Organizing Maps (SOM)      | `kohonen`                                      |
| Hierarchical Clustering          | `base: hclust`                                 |
| ANOVA                            | `agricolae`                                    |
| Visualization                    | `ggplot2`, `corrplot`, `viridis`, `kableExtra`, `patchwork` |

Ensure these packages are installed to successfully run the code.

## Installation & Setup {#install}

Clone the repository to your local machine:

``` bash
git clone https://github.com/carlos-gomeztorres/TFG.git
cd TFG
```

## Data {#data}

This project uses two primary data sources: financial data from ORBIS and football performance data scraped from Transfermarkt.

### Financial Data (ORBIS)

The financial data for the football clubs in this project comes from ORBIS, a comprehensive global database containing financial information on companies worldwide. 

ORBIS is widely regarded as a reliable resource for financial research, particularly in the areas of corporate valuation and benchmarking, making it an ideal source for assessing football clubs' financial health and investment potential.

### Football Data (Transfermarkt)

The football performance and player market values data were scraped from Transfermarkt (https://www.transfermarkt.com/), a leading online platform that provides in-depth data on football clubs, players, transfers, match results, and other relevant statistics. Transfermarkt is known for its extensive coverage of the football market, including the estimated market value of players, squad composition, and performance metrics for clubs.

For this project, Transfermarkt was scraped to gather data on player values, team performance, and transfers, which were then combined with financial data to give a holistic valuation of football clubs.

## Usage {#usage}

The final datasets used for this project can be found in the data/processed folder, consisting of:
- Transfermarkt.xlsx
- Finances.xlsx
- M&A.xlsx

The analysis is conducted in the Main.Rmd notebook, which applies PCA, SOM, and Hierarchical Clustering for football club valuation.
