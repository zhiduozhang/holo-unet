# Thrombosis

## Libraries

- Tensorflow
- Keras
- matplotlib
- sklearn
- numpy
- scipy

## Processing Pipeline

### 1. Data ID CSV & File restructuring

File: restructure v2

Each from the raw data source is renamed to a unique id, and stored in the root folder as a numpy array. The ids are stored in a csv called ids.csv

### 2. Augmentation

### 3. Feature Extraction

File: Feature Extraction

We extract features from the raw numpy arrays, read as images, and stored the metrics in the ids.csv file in line with the id of the numpy array.

### Linear Regression

#### Image -> Flow Rate

File: Image Logistic Regression Keras

Simple Logistic Regression on the image to predict flow rate.

#### Features -> Flow rate

File: Logistic Regression Keras

Logistic Regression applied to the extracted features to predict flow rate. Also completed using cross-validation and the result is visualised through a confusion matrix.

### CNN

Currently not working since it's on the 

### K-Means

File: K-Means

### Visualisations

File: K-Means

Visualisation of the extracted features. Visualisations include: Pearsons Corrolation Coefficient. Scatter/Histograms of individual features. Graphs of t-SNE and other dimensionality reduction methods. 
