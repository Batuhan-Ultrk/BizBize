# BizBize Server

OfficeLore/BizBize backend built with Vapor.

Detailed API documentation: `API.md`

## Auth Endpoints

- `POST /auth/register` creates a user and returns a permanent token.
- `POST /auth/login` returns a permanent token unless the user must reset their password after logout.
- `POST /auth/logout` invalidates user tokens and marks password reset as required.
- `GET /auth/me` returns the authenticated user profile.
- `POST /auth/password-reset` creates a 10-minute reset token.
- `POST /auth/password-reset/confirm` accepts `token` and `newPassword`.

## Announcement Endpoints

All announcement endpoints require `Authorization: Bearer <token>`.

- `POST /announcements` creates an announcement.
- `GET /announcements` lists announcements visible to the current user.
- `GET /announcements?type=event` filters by `birthday`, `gift`, `event`, or `operational`.
- `GET /announcements/:id` returns a visible announcement detail.
- `POST /announcements/:id/rsvp` sets the current user's RSVP status as `attending` or `notAttending`.

Targeting uses `targetUserIds`; an empty or omitted list means everyone. Attendee IDs are returned only to the announcement creator.

## Poll Endpoints

All poll endpoints require `Authorization: Bearer <token>`.

- `POST /polls` creates a manual poll.
- `GET /polls` lists polls visible to the current user.
- `GET /polls?type=manual` filters by `manual` or `dailyLunch`.
- `GET /polls/:id` returns a visible poll detail.
- `POST /polls/:id/vote` casts one vote for a poll.
- `GET /polls/daily-lunch` returns today's lunch poll if opened.
- `POST /polls/daily-lunch/vote` casts a lunch vote as `home`, `outside`, or `order`.

The daily lunch poll is created automatically after 09:00 while the server is running. It closes at 12:00.

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
