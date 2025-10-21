# AWS Kinesis Node.js Application

This directory contains the Node.js code for working with AWS Kinesis streams.

## Prerequisites

- Node.js 20.6.0 or higher

## Installation Instructions

1. Download Node.js from [https://nodejs.org/en/download/](https://nodejs.org/en/download/)
   - Select the Windows installer (.msi) for the LTS version
   - Make sure to download version 20.6.0 or higher

2. Run the installer and follow these steps:
   - Accept the license agreement
   - Choose the installation directory
   - Select the features to install (default is fine)
   - Click "Install"

3. Verify the installation:
   ```
   node --version
   npm --version
   ```

4. Install project dependencies:
   ```
   cd src/node
   npm install
   ```

5. Run the application:
   ```
   npm start
   ```

## Development

Update the `index.js` file to implement your AWS Kinesis data processing logic.