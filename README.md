# Calx - Quantitative Math Practice Suite

Calx is a high-performance quantitative arithmetic training suite designed to help users sharpen their mental calculation speed, accuracy, and APM (Answers Per Minute). The project is structured as a monorepo consisting of a marketing landing page, a React-Vite web application, a multi-platform Flutter mobile application, and an Express-PostgreSQL backend server.

---

## 📁 Repository Structure

```tree
calx.com/
├── apps/
│   ├── landing/          # Pure HTML/JS/CSS Landing page with local APK download and redirect logic
│   ├── web/              # React + Vite quantitative math webapp (lives at https://calx-three.vercel.app/)
│   ├── mobile/           # Flutter mobile app with 100% feature parity and in-app auto-updater
│   └── server/           # Express.js backend server integrated with Neon Cloud PostgreSQL
└── README.md             # Project documentation (this file)
```

---

## 🚀 App Modules & Technical Highlights

### 1. Marketing Landing Page (`apps/landing`)
* **Features:** Responsive dark-mode landing layout, English & Hindi translation systems, animated components, and CTA buttons linking to the deployed React webapp.
* **APK Download Flow:** Tapping **Download Android APK** dynamically checks the latest asset from GitHub Releases via the GitHub API. If the API is rate-limited or the repository is private, it falls back to downloading the locally-hosted `app-release.apk` stored directly on the landing page server.

### 2. React Web Application (`apps/web`)
* **Tech Stack:** React, Vite, Vanilla CSS.
* **Features:** timed calculations console, custom light/dark theme variables, auto-checking numeric inputs, Neon DB synchronized login sessions, dashboard stats, and a speed leaderboard.

### 3. Flutter Mobile Application (`apps/mobile`)
* **Tech Stack:** Flutter, Dart, SharedPreferences.
* **Features:** 
  * 100% parity with the React webapp layout, colors, and features.
  * **In-App Direct Updater:** Queries the GitHub Releases API. If a new version is found, it downloads the APK directly inside the app with a sleek cyan animated progress bar and automatically launches the package installer via `open_file`.
  * **Custom Calx App Icon:** Built with adaptive mipmap assets matching the webapp's dark circle and cyan symbol logo.
  * **Multilingual:** Translation maps support English and Hindi dialects.

### 4. Express Backend Server (`apps/server`)
* **Tech Stack:** Node.js, Express, PG (node-postgres), BcryptJS.
* **Features:** Neon PostgreSQL schema initializer and table migration logic, authentication endpoints (`/api/auth/signup` and `/api/auth/signin`), Google session hooks, leaderboard generation, and status aggregators.

---

## 🛠️ Installation & Local Setup

### Running Backend Server
1. Navigate to `/apps/server`
2. Create a `.env` file (refer to `.env.example`):
   ```env
   DATABASE_URL=your_postgres_connection_string
   PORT=5000
   ```
3. Install dependencies and start:
   ```bash
   npm install
   npm start
   ```

### Running React Webapp
1. Navigate to `/apps/web`
2. Create a `.env` file:
   ```env
   VITE_API_URL=http://localhost:5000
   ```
3. Install dependencies and start:
   ```bash
   npm install
   npm run dev
   ```

### Running Flutter Mobile App
1. Install Flutter SDK and configure your emulator/device.
2. Navigate to `/apps/mobile`
3. Download dependencies:
   ```bash
   flutter pub get
   ```
4. Build the android release APK:
   ```bash
   flutter build apk --release
   ```
   *(Note: The built APK will be saved at `build/app/outputs/flutter-apk/app-release.apk`)*

---

## 🌐 Production Deployment

1. **Backend Server:** Deploy the Node/Express app to Render, Railway, or Heroku, setting the root directory to `apps/server` and adding the `DATABASE_URL` environment variable.
2. **React Webapp:** Deploy to Vercel (or Netlify), setting the `VITE_API_URL` environment variable to your live backend domain.
3. **Landing Page:** Deploy the pure HTML folder to Vercel or GitHub Pages, making sure to copy the latest `app-release.apk` to the root folder as a download fallback.
