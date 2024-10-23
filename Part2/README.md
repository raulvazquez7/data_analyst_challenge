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

## Automation Purpose
To automate the daily update of your Google Sheet with new messages containing “BTC” using Cloud Run, you can leverage Google’s serverless infrastructure to run your script on a scheduled basis. Here’s how the process would work:

1. Containerize Your Script: Package your existing Python script into a Docker container. This involves creating a Docker image that includes your script and all its dependencies, ensuring it can run in any environment without modification.
2. Deploy to Cloud Run: Upload your container image to Google Container Registry (Artifact Registry) and deploy it to Cloud Run. Cloud Run will host your containerized application and manage the underlying infrastructure, scaling automatically as needed.
3. Set Up Cloud Scheduler: Configure Cloud Scheduler to trigger your Cloud Run service at a specific time every day. Cloud Scheduler can send an HTTP request to your Cloud Run endpoint, effectively invoking your script on a daily schedule.
4. Manage Secrets and Credentials: Use Google Secret Manager to securely store sensitive information like your Telegram API credentials and Google Sheets API keys. Configure your Cloud Run service to access these secrets at runtime without hardcoding them into your script.
5. Configure Permissions: Ensure that the service account associated with your Cloud Run service has the necessary permissions to access the Google Sheets API and Secret Manager. This involves assigning appropriate IAM roles to the service account.
6. Logging and Monitoring: Utilize Google Cloud’s logging and monitoring tools to keep track of your script’s executions. Cloud Logging can capture logs from your script, and you can set up alerts for failures or anomalies.

By implementing this setup, your script will automatically run daily in a secure and scalable environment, fetching new “BTC” messages from the Telegram channel and appending them to your Google Sheet without any manual intervention.
