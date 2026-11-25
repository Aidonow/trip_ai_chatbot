# Trip AI Chatbot

A web application for planning trips through conversational interactions. Users can create an account, start chats, and review saved travel suggestions, including destination, estimated budget, and trip duration.

**Live application:** [trip-chatbot-7c8e98292082.herokuapp.com](https://trip-chatbot-7c8e98292082.herokuapp.com/)

## Features

- User registration and authentication with Devise
- Conversations associated with user accounts
- Persistent messages and travel suggestions
- A history of saved suggestions with individual detail pages
- RubyLLM configuration for OpenAI integration

## Technology Stack

- Ruby 3.3.5
- Rails 8.1
- PostgreSQL
- Devise
- RubyLLM and OpenAI
- Bootstrap

## Requirements

- Ruby 3.3.5
- Bundler
- PostgreSQL

## Getting Started

Clone the repository and install its dependencies:

```bash
git clone https://github.com/Aidonow/trip_ai_chatbot.git
cd trip_ai_chatbot
bundle install
```

Ensure PostgreSQL is running, then prepare the database:

```bash
bin/rails db:prepare
```

### OpenAI Configuration

To use features that connect to OpenAI, provide an API key in a `.env` file in the project root:

```dotenv
OPENAI_API_KEY=your_openai_api_key
```

The `.env` file is excluded from version control. Never commit or share your API key.

### Run the Application

Start the Rails server:

```bash
bin/rails server
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

## Running Tests

Run the Rails test suite with:

```bash
bin/rails test
```

## Data Model

The application stores users, chats, messages, and travel results. A result can include a destination, price, duration, and descriptive content.

After pulling changes that include database migrations, update the local database with:

```bash
bin/rails db:prepare
```
