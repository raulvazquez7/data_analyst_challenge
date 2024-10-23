BTC Messages Extractor from Telegram to Google Sheets

This script fetches messages containing the keyword ‘btc’ from a specified Telegram channel and stores them in a Google Sheets spreadsheet. It is designed to retrieve messages from the previous day and append them to the sheet for easy tracking.

Overview
- Fetches messages from Telegram: Connects to a Telegram channel and retrieves messages containing ‘btc’ from the previous day.
- Stores messages in Google Sheets: Appends the fetched messages to a specified Google Sheets document.

Requirements
- Python 3.6+
- Telegram API credentials: api_id and api_hash
- Google API credentials: service_account_key.json
- Python libraries:
	- telethon
	- gspread
	- oauth2client

Setup

1.Install Dependencies:

```bash
pip install telethon gspread oauth2client
```
