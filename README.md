# Flutter Firebase To-Do App

A simple To-Do list app built with **Flutter** and **Firebase Firestore**, allowing users to:
- Add, update, and delete tasks.
- Mark tasks as completed or pending.
- Filter tasks by status (All, Completed, Pending).
- Each task includes a title, description, and due date.

---

##  Features
- Firebase Authentication for user-specific tasks.
- Real-time Firestore database updates.
- Beautiful UI with task filtering.
- Fully responsive design.

---

##  Folder Structure

lib/
│
├── main.dart # Entry point
├── firebase_options.dart # Firebase configuration (auto-generated)
│
├── auth/
│ ├── login_screen.dart # User login screen
│ └── signup_screen.dart # User signup screen
│
├── home/
│ └── todo_screen.dart # Main To-Do screen
│
├── widgets/
│ ├── common_text_field.dart # Reusable text field widget
│ └── common_button.dart # Reusable button widget
│
└── theme/
└── app_theme.dart # App theme colors and constants