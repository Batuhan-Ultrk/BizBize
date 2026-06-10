# BizBize Server

OfficeLore/BizBize backend built with Vapor.

## Auth Endpoints

- `POST /auth/register` creates a user and returns a permanent token.
- `POST /auth/login` returns a permanent token unless the user must reset their password after logout.
- `POST /auth/logout` invalidates user tokens and marks password reset as required.
- `GET /auth/me` returns the authenticated user profile.
- `POST /auth/password-reset` creates a 10-minute reset token.
- `POST /auth/password-reset/confirm` accepts `token` and `newPassword`.

## Environment

```bash
APP_NAME=OfficeLore
MAX_REGISTERED_USERS=50
SERVER_HOSTNAME=0.0.0.0
SERVER_PORT=8080
```

## Getting Started

Run these commands from the `server/` directory.

Start only PostgreSQL with Docker:

```bash
docker compose up -d db
```

Run migrations from the host:

```bash
swift run BizBizeServer migrate --yes
```

Run the server directly on the host:

```bash
swift run
```

By default, the server binds to `0.0.0.0:8080`, so devices on the same local network can call it through your machine's LAN IP.

Build the project using the Swift Package Manager:

```bash
swift build
```

Execute tests:

```bash
swift test
```

Stop the local database:

```bash
docker compose down
```

Wipe the local database volume:

```bash
docker compose down -v
```

### See more

- [Vapor Website](https://vapor.codes)
- [Vapor Documentation](https://docs.vapor.codes)
- [Vapor GitHub](https://github.com/vapor)
- [Vapor Community](https://github.com/vapor-community)
