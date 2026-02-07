# Tamit

A private, minimalist social app for exactly 2 users built with Flutter and Supabase.

## Features

- 🔐 Email/password and magic link authentication
- 👤 User profiles with avatars and bios
- 📝 Text posts with optional images
- ❤️ Likes and comments
- 💬 1-to-1 real-time chat
- 🟢 Real-time online presence
- 🔒 Strict 2-user limit enforced at database level

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- A Supabase account ([supabase.com](https://supabase.com))

## Setup Instructions

### 1. Clone or Navigate to Project

```bash
cd c:\Users\Harshali\OneDrive\Desktop\tamit
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Set Up Supabase

#### 3.1 Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Wait for the project to finish setting up

#### 3.2 Run Database Migrations

In your Supabase project dashboard:

1. Go to **SQL Editor**
2. Run the files in this order:
   - `supabase/schema.sql` - Creates all tables, indexes, and triggers
   - `supabase/rls_policies.sql` - Sets up Row Level Security
   
3. Go to **Storage** and create two public buckets:
   - `avatars` (Public: Yes)
   - `posts` (Public: Yes)

4. After creating buckets, go back to **SQL Editor** and run:
   - `supabase/storage.sql` - Sets up storage policies

#### 3.3 Configure Environment Variables

1. Get your Supabase credentials:
   - Go to **Settings** → **API**
   - Copy your **Project URL**
   - Copy your **anon public** key

2. Update `lib/config/env.dart`:
   ```dart
   static const String supabaseUrl = 'YOUR_SUPABASE_URL_HERE';
   static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY_HERE';
   ```

#### 3.4 Add Initial Users

Since this is a private 2-user app, you need to manually create exactly 2 user accounts:

1. Go to **Authentication** → **Users**
2. Click **Add User** and create the first account with email/password
3. Click **Add User** again and create the second account
4. **Important**: The app is designed for exactly 2 users. Do not create more than 2 accounts.

> **Note**: The database schema includes a constraint that prevents creating more than 2 user profiles.

### 4. Run the App

#### For Android:
```bash
flutter run
```

#### For iOS (macOS only):
```bash
flutter run -d ios
```

## Project Structure

```
lib/
├── config/          # App configuration (theme, env)
├── models/          # Data models
├── providers/       # Riverpod providers
├── screens/         # UI screens
│   ├── auth/       # Login screen
│   ├── feed/       # Posts feed, create post, comments
│   ├── chat/       # Chat list, 1-to-1 chat
│   └── profile/    # Profile view and edit
├── services/        # Backend services
└── widgets/         # Reusable widgets
```

## Usage

### Login

Users can log in using:
- Email + Password
- Magic link (email-only, sends login link)

### Posts

- Create posts with text + optional image
- Like and unlike posts
- Comment on posts
- View all posts in chronological order

### Chat

- Direct 1-to-1 conversation with the other user
- Real-time message delivery
- See when the other user is online/offline
- View last seen status

### Profile

- Upload avatar
- Edit bio
- View online status
- Logout

## Key Technologies

- **Flutter** - Cross-platform mobile framework
- **Supabase** - Backend (Auth, Database, Storage, Realtime)
- **Riverpod** - State management
- **Image Picker** - Camera/gallery access
- **Cached Network Image** - Efficient image loading

## Security

All data is protected by Supabase Row Level Security (RLS) policies:

- Users can only read/write their own profile data
- All users can view posts, but only authors can delete
- Messages are private between sender and receiver
- Storage buckets have policies to prevent unauthorized access

## Limitations (By Design)

- **Exactly 2 users** (enforced at database level)
- No public signup
- No push notifications
- No search or discovery
- No followers or social graph
- 1-to-1 chat only (no group chats)
- Minimalist UI (2 tabs: Feed and Chat)

## Troubleshooting

### "Cannot find module" errors

Make sure you've run:
```bash
flutter pub get
```

### Supabase connection errors

- Verify your URL and anon key in `lib/config/env.dart`
- Check that your Supabase project is running
- Ensure you've run all SQL migrations

### Images not loading

- Verify storage buckets are public
- Check storage.sql policies were applied
- Ensure correct bucket names: `avatars` and `posts`

### Real-time not working

- Enable Realtime in Supabase dashboard:
  - Go to **Database** → **Replication**
  - Enable replication for `messages` table

## License

Private project - All rights reserved.
