# Smart LED Panel Testing System

## Overview
This project implements a low-cost and efficient automated quality control system for LED panels using digital sensing and image processing. The system combines sensor-based preliminary testing with targeted image processing to detect and localize faulty LEDs in matrices.

## Project Details
- **Course**: EEE 460 - Optoelectronics Laboratory (January 2024)
- **Institution**: Bangladesh University of Engineering and Technology (BUET)
- **Department**: Electrical and Electronic Engineering
- **Date**: December 2024

## Features
- Two-stage hybrid testing approach
- Preliminary testing using BH1750FVI digital light intensity sensors
- Image processing-based defect detection and localization
- Automated batch testing capability
- Detailed PDF report generation with defect visualization
- Controlled testing environment to eliminate ambient light interference

## Team Members (Group 5, Section G1)
- **Anindya K. Choudhury** (1906081)
  - LED Light Control
  - Image Processing and Fault Localization
  - Report Generation
  - Webcam Setup
  - Process and Workflow Integration

- **Shadman Saquib** (1806020)
  - Image Pre-Processing and Framing
  - Debugging
  - Process and Workflow Integration

- **Chinmoy Biswas** (1906029)
  - Literature Review
  - Digital Intensity Sensor Setup
  - Intensity Reference Value Generation
  - Building and Wiring the Setup

- **Mushfiquzzaman Abid** (1906084)
  - Sensor DataFlow Muxing
  - Intensity Detection and Thresholding
  - Building and Wiring the Setup

## Instructors
- **Dr. Muhammad Anisuzzaman Talukder**, Professor
- **Tanushri Medha Kundu**, Part-Time Lecturer

## Technical Components
- Arduino UNO microcontrollers for sensor data acquisition and LED matrix control
- BH1750FVI digital light intensity sensors
- High-resolution webcam for image capture
- MATLAB for image processing and report generation
- MAX7219-based LED matrix for testbench

## Repository Structure
- `/src/` - Source code for Arduino firmware and MATLAB scripts
- `/docs/` - Project documentation
- `/reports/` - Sample test reports and results
- `/images/` - Images of the setup and results

## How It Works
1. System establishes baseline reference values using a good LED matrix
2. Real-time sensor data is compared to reference values during testing
3. If anomalies are detected, image processing is triggered
4. Image analysis identifies specific faulty LEDs and their positions
5. Comprehensive PDF reports are generated for each test

## Demo Video
[Watch Demo on YouTube](https://www.youtube.com/watch?v=ZHAm56Lurb8)

## Future Work
- Machine learning integration for predictive diagnostics
- Spectral analysis capabilities (CRI, CCT)
- Power and efficiency measurements
- Enhanced detection of flickering and dimming issues
- Cost optimization through custom PCB design
- Improved image processing algorithms


This project is academic work completed for EEE 460 at BUET.