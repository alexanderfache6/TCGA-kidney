## Overview

## Module 1 - Preprocessing

Given 512x512 image slides of Kidney tissue, preprocessing intends to clean up defects and select  regions of interest within each sample.

Preprocessing techniques employed include:
- Reinhardt's Method for Color Normalization

Given a limited data set, data augmentation is key for increasing the number of samples. Through methods such as:
- flipping
- rotating
- cropping

additional samples of 224x224 are created.

224x224 was chosen as the modified dimensions of each sample as many pretrained CNNs invoke 224x224 as the input dimensionality.

## Module 2 - Feature Extraction and Selection

## Module 3 - Classification
