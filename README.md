# Netflix-Dashboard

A Netflix Dashboard built using R Shiny for data analysis, AI prediction, and content recommendation.

## Features

### Project Overview
- Total Netflix content
- Total Movies
- Total TV Shows

### Analytics Dashboard
- Content type distribution graph
- Release year trend graph
- Interactive data table

### AI Prediction
Predict whether Netflix content is:
- Movie
- TV Show

Based on:
- Release Year
- Rating

Model used:
- Random Forest

### Recommendation System
Simple content recommendation based on content type similarity.

## Technologies Used

- R
- Shiny
- Shinydashboard
- Plotly
- DT
- RandomForest

## Dataset

Dataset used:
Netflix Titles Dataset

Columns used:
- title
- type
- release_year
- rating

## Installation

Install required packages:

```r
install.packages(c(
  "shiny",
  "shinydashboard",
  "plotly",
  "DT",
  "randomForest"
))
