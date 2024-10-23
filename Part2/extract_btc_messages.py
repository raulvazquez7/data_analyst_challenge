from telethon import TelegramClient
import datetime
from datetime import timezone
import gspread
from oauth2client.service_account import ServiceAccountCredentials
import os

## 0. Set variables and auth

# Telegram API credentials
api_id = 'YOUR_API_ID'
api_hash = 'YOUR_API_HASH'

# Telegram channel username
channel_username = 'bitpanda_de'  # or your target channel

# Google Sheets credentials file
google_creds_file = 'service_account_key.json'

# Google Sheets spreadsheet ID
spreadsheet_id = 'YOUR_SPREADSHEET_ID'

client = TelegramClient(session_name, api_id, api_hash)

# Session name
session_name = 'btc_extractor_session'

## 1. Set functions

async def fetch_messages():
    try:
        # Calculate the date range for the previous day
        today = datetime.date.today()
        yesterday = today - datetime.timedelta(days=1)
        from_date = datetime.datetime.combine(yesterday, datetime.time.min).replace(tzinfo=timezone.utc)
        to_date = datetime.datetime.combine(yesterday, datetime.time.max).replace(tzinfo=timezone.utc)
        print(f"Fetching messages from {from_date} to {to_date}")

        # Get the channel entity
        channel = await client.get_entity(channel_username)
        print(f"Fetched channel: {channel.title}")

        # Fetch messages
        messages = []
        async for message in client.iter_messages(channel, offset_date=to_date):
            if message.date < from_date:
                # Reached messages earlier than our date range
                break
            if message.message and 'btc' in message.message.lower():
                messages.append({
                    'Date': message.date.strftime('%Y-%m-%d %H:%M:%S'),
                    'Sender': message.sender_id,
                    'Message': message.message
                })
        print(f"Found {len(messages)} messages containing 'btc'")
        return messages
    except Exception as e:
        print(f"Error fetching messages: {e}")
        return []

def connect_google_sheets():
    try:
        scope = ['https://spreadsheets.google.com/feeds', 'https://www.googleapis.com/auth/drive']
        creds = ServiceAccountCredentials.from_json_keyfile_name(google_creds_file, scope)
        gclient = gspread.authorize(creds)
        sheet = gclient.open_by_key(spreadsheet_id).sheet1
        return sheet
    except Exception as e:
        print(f"Error connecting to Google Sheets: {e}")
        return None

def store_messages(sheet, messages):
    try:
        if not sheet:
            print("Google Sheet is not available.")
            return

        # Prepare data to insert
        data = []
        for msg in messages:
            data.append([msg['Date'], msg['Sender'], msg['Message']])

        # Find the next available row
        next_row = len(sheet.get_all_values()) + 1
        print(f"Next available row in Google Sheet: {next_row}")

        # Insert data into the sheet
        if data:
            sheet.insert_rows(data, row=next_row)
            print(f"{len(data)} messages appended to Google Sheet")
        else:
            print("No new messages to append")
    except Exception as e:
        print(f"Error storing messages in Google Sheets: {e}")

async def main():
    try:
        # Start Telegram client
        await client.start()
        print("Connected to Telegram")
    except Exception as e:
        print(f"Error connecting to Telegram: {e}")
        return

    try:
        messages = await fetch_messages()
        print(f"Total messages fetched: {len(messages)}")
    except Exception as e:
        print(f"Error during message fetching: {e}")
        return

    try:
        sheet = connect_google_sheets()
    except Exception as e:
        print(f"Error during Google Sheets connection: {e}")
        return

    try:
        store_messages(sheet, messages)
    except Exception as e:
        print(f"Error during storing messages: {e}")
        return

if __name__ == '__main__':
    with client:
        client.loop.run_until_complete(main())
