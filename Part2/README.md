# BTC Messages Extractor from Telegram to Google Sheets

This script fetches messages containing the keyword ‘btc’ from a specified Telegram channel and stores them in a Google Sheets spreadsheet. It is designed to retrieve messages from the previous day and append them to the sheet for easy tracking.

[See python script here!](https://github.com/raulvazquez7/data_analyst_challenge/blob/main/Part2/extract_btc_messages.py)
[See csv result here!](https://github.com/raulvazquez7/data_analyst_challenge/blob/main/Part2/bitpanda_de_btc_messages.csv)

## Overview
- Fetches messages from Telegram: Connects to a Telegram channel and retrieves messages containing ‘btc’ from the previous day.
- Stores messages in Google Sheets: Appends the fetched messages to a specified Google Sheets document.

## Requirements
- Python 3.6+
- Telegram API credentials: api_id and api_hash
- Google API credentials: service_account_key.json
- Python libraries:
	- telethon
	- gspread
	- oauth2client

## Setup

1. Install Dependencies:
```bash
pip install telethon gspread oauth2client
```

2. Configure Telegram API:
- Obtain api_id and api_hash from my.telegram.org.

3. Configure Google API:
- Enable Google Sheets API in the Google Cloud Console.
- Create a service account and download the service_account_key.json file.
- Share your Google Sheets document with the service account email.

4. Update Script Configuration:
Replace the placeholders in the script with your actual credentials and IDs:
```python
# Telegram API credentials
api_id = 'YOUR_API_ID'
api_hash = 'YOUR_API_HASH'

# Telegram channel username
channel_username = 'bitpanda_de'  # or your target channel

# Google Sheets credentials file
google_creds_file = 'service_account_key.json'

# Google Sheets spreadsheet ID
spreadsheet_id = 'YOUR_SPREADSHEET_ID'
```

## Usage

Run the script using:
```bash
python extract_btc_messages.py
```
- On the first run, authenticate your Telegram account when prompted.
- The script will fetch messages from the previous day containing ‘btc’ and append them to your Google Sheet.

## Script Structure
- fetch_messages(): Fetches messages containing ‘btc’ from the previous day.
- connect_google_sheets(): Connects to the specified Google Sheets document.
- store_messages(): Appends the fetched messages to the Google Sheet.
- main(): Orchestrates the execution flow.

# Automation Purpose
## Proposal for Automating Daily Updates of Google Sheets with “BTC” Messages from Telegram

I would like to recommend automating the process of updating our Google Sheet with new messages containing “BTC” from the Telegram channel by utilizing Google Cloud Run. This solution offers an efficient, scalable, and secure way to run our existing script without the need for managing underlying infrastructure.

### Why Cloud Run?

Cloud Run is a serverless compute platform provided by Google Cloud that allows us to run stateless containers in a fully managed environment. It’s an excellent choice for automating tasks when the client does not utilize platforms like Databricks. By deploying our script to Cloud Run, we can:

- Automate Execution: Schedule the script to run daily without manual intervention.
- Ensure Scalability: Automatically handle varying workloads without the need for capacity planning.
- Enhance Security: Securely manage credentials and sensitive data using Google Cloud’s security features.
- Reduce Operational Overhead: Eliminate the need to manage servers or infrastructure.

### Proposed Process:

1. Containerize the Script: Package the existing Python script into a Docker container, ensuring all dependencies are included.
2. Deploy to Cloud Run: Upload the container image to Google Container Registry and deploy it to Cloud Run. This makes the script accessible as a web service that can be triggered via HTTP requests.
3. Schedule Execution with Cloud Scheduler: Use Google Cloud Scheduler to invoke the Cloud Run service at a specified time each day. This effectively automates the daily execution of the script.
4. Manage Secrets Securely: Utilize Google Secret Manager to store sensitive information like Telegram API credentials and Google Sheets API keys. Configure the Cloud Run service to access these secrets securely at runtime.
5. Configure Permissions: Assign appropriate IAM roles to the Cloud Run service account to ensure it has the necessary permissions to access Google Sheets and Secret Manager.
6. Monitoring and Logging: Leverage Google Cloud’s monitoring tools to track script executions, capture logs, and set up alerts for any failures or anomalies.

### Alternative with Databricks:

If Databricks is part of our technology stack, we can automate the process directly within a Databricks notebook. Databricks offers robust scheduling and integration capabilities, allowing us to:

- Embed the Script in a Notebook: Run the Python script within a Databricks notebook for seamless integration with existing workflows.
- Use Databricks Jobs: Schedule the notebook to run daily using Databricks’ job scheduling feature.
- Centralize Data Processing: Benefit from Databricks’ unified analytics platform if we are already using it for other data tasks.

### Conclusion:

Automating this process with Cloud Run is a highly effective solution when Databricks is not in use. It streamlines the workflow, ensures our Google Sheet is updated daily with new “BTC” messages, and reduces manual effort. Should we be utilizing Databricks, integrating the automation within a notebook would be equally beneficial.

This approach not only enhances efficiency but also aligns with best practices for security and scalability. I recommend proceeding with the Cloud Run implementation to achieve a robust and maintainable automation process.

By adopting this solution, we can ensure our data is consistently up-to-date, allowing for timely insights and decision-making.
