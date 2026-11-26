# AÏDO — Trip AI Chatbot

AÏDO is an AI travel copilot that helps users plan trips through conversation. Create an account, chat with AÏDO for destination suggestions, and review saved trips with their estimated budget and duration.

**Live application:** [trip-chatbot-7c8e98292082.herokuapp.com](https://trip-chatbot-7c8e98292082.herokuapp.com/)

## Meet AÏDO

AÏDO is the friendly travel companion who guides users through the trip-planning chat. The avatar represents AÏDO, while the flying illustration welcomes users on the home page.

<p align="center">
  <img src="app/assets/images/aido%20avatar.png" alt="AÏDO travel companion avatar" width="220">
  &nbsp;&nbsp;&nbsp;
  <img src="app/assets/images/aido%20on%20plane.png" alt="AÏDO flying on a paper plane" width="220">
</p>

## Features

- User registration and authentication with Devise
- Conversational trip planning with AÏDO
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
