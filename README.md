# BizBize

This repository is organized as a monorepo so the backend, web app, and iOS app can be managed from a single GitHub repository.

## Structure

```text
.
├── server/  # Vapor backend
├── web/     # Web frontend
└── ios/     # iOS app
```

## Projects

- `server/`: Swift Vapor backend. See `server/README.md`.
- `web/`: reserved for the web frontend.
- `ios/`: reserved for the iOS app.

## Server

Run the backend from the `server/` directory:

```bash
cd server
swift build
swift run
```

Run tests:

```bash
cd server
swift test
```
