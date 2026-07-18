# 🎮 Minecraft-Discord Authentication Backend

[![Elixir CI](https://github.com/yourusername/minecraft_discord_auth/workflows/elixir/badge.svg)](https://github.com/yourusername/minecraft_discord_auth/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Phoenix Framework](https://img.shields.io/badge/Phoenix-1.8.1-purple.svg)](https://www.phoenixframework.org/)
[![Elixir](https://img.shields.io/badge/Elixir-1.15-blue.svg)](https://elixir-lang.org/)

> **A secure authentication backend for Minecraft servers using Discord OAuth2**

---

## 🌟 **About the Project**

This project provides a **secure, scalable authentication system** that allows Minecraft players to verify their identity through Discord. Built with **Elixir and Phoenix Framework**, it offers:

- ✅ **Discord OAuth2 Integration** - Secure authentication via Discord
- ✅ **Player Management API** - Full CRUD operations for player accounts
- ✅ **Rate Limiting** - Protection against abuse and DDoS attacks
- ✅ **Session Tracking** - Real-time tracking of logged-in players
- ✅ **Minecraft Plugin Integration** - Seamless integration with Skript

---

## 🚀 **Quick Start**

### **Prerequisites**

- [Elixir 1.15+](https://elixir-lang.org/install.html)
- [Phoenix 1.8+](https://hexdocs.pm/phoenix/installation.html)
- [Node.js 18+](https://nodejs.org/) (for asset compilation)
- [SQLite](https://www.sqlite.org/download.html) (or PostgreSQL/MySQL for production)
- Discord Developer Account with OAuth2 application

### **Installation**

```bash
# Clone the repository
git clone https://github.com/yourusername/minecraft_discord_auth.git
cd minecraft_discord_auth

# Install dependencies
mix deps.get

# Setup database
mix ecto.create
mix ecto.migrate

# Build assets
mix assets.setup
mix assets.build

# Create environment file
cp .env.example .env
# Edit .env with your credentials

# Start the server
mix phx.server
```

The server will be available at `http://localhost:4000`

---

## 🛠️ **Configuration**

### **Environment Variables**

Create a `.env` file in the project root:

```bash
# Discord OAuth2 Configuration
export DISCORD_CLIENT_ID=your_discord_client_id
export DISCORD_CLIENT_SECRET=your_discord_client_secret
export GUILD_ID=your_discord_guild_id

# Application Secrets
export SMP_SECRET=your_api_secret_key
export SECRET_KEY_BASE=$(mix phx.gen.secret)

# Server Configuration
export PORT=4000
export PHX_HOST=yourdomain.com
export MC_SERVER_IP=your_minecraft_server_ip

# Database Configuration
export DATABASE_PATH=/path/to/database.db
```

> **⚠️ IMPORTANT: Never commit your `.env` file to version control!**
> Add it to your `.gitignore` file.

### **Discord Setup**

1. Go to [Discord Developer Portal](https://discord.com/developers/applications)
2. Create a new application
3. Go to **OAuth2** → **General**
4. Add redirect URI: `http://localhost:4000/auth/discord/callback` (development) or `https://yourdomain.com/auth/discord/callback` (production)
5. Copy the **Client ID** and **Client Secret** to your `.env` file
6. Enable the following OAuth2 scopes:
   - `identify`
   - `guilds`

---

## 🔌 **API Documentation**

### **Base URL**
```
https://yourdomain.com
```

### **Authentication Flow**

#### **1. Start Authentication**
```
GET /auth?mc_username={username}
```
- Redirects to Discord OAuth2
- Stores `mc_username` in session

#### **2. Discord Callback**
```
GET /auth/discord/callback
```
- Handles Discord OAuth2 callback
- Verifies guild membership
- Creates/updates player record
- Returns success/failure page

### **Player Management API**

All API endpoints require the `secret` header matching your `SMP_SECRET`.

#### **Create Player**
```
POST /players/create
Headers:
  secret: your_smp_secret

Body:
{
  "mc_username": "Player123",
  "ds_username": "DiscordUser#1234"
}
```

**Response:**
- `200 OK` - Success
- `409 Conflict` - Account already exists
- `403 Forbidden` - Invalid secret

#### **Check Login Status**
```
GET /players/logged?mc_username=Player123
Headers:
  secret: your_smp_secret
```

**Response:**
```json
{
  "logged": true
}
```

#### **Temporary Login Mark**
```
GET /players/templog?mc_username=Player123
Headers:
  secret: your_smp_secret
```
- Marks player as logged in temporarily (30 seconds)

#### **Get Player Info**
```
GET /players/show?mc_username=Player123
# or
GET /players/show?ds_username=DiscordUser
Headers:
  secret: your_smp_secret
```

**Response:**
```json
{
  "mc_username": "Player123",
  "ds_username": "DiscordUser#1234",
  "first_connection": "2024-01-15T10:30:00Z",
  "last_change": "2024-01-16T14:25:00Z"
}
```

#### **Update Username**
```
POST /players/edit
Headers:
  secret: your_smp_secret

Body (update Discord username):
{
  "mc_username": "Player123",
  "new_ds_username": "NewDiscordUser"
}

Body (update Minecraft username):
{
  "ds_username": "DiscordUser",
  "new_mc_username": "NewPlayer456"
}
```

#### **Reset IP**
```
GET /players/resetip?mc_username=Player123
# or
GET /players/resetip?ds_username=DiscordUser
Headers:
  secret: your_smp_secret
```
- Clears the stored IP hash for the player

#### **Delete Player**
```
DELETE /players/
Headers:
  secret: your_smp_secret

Body:
{
  "mc_username": "Player123"
  # or
  "ds_username": "DiscordUser"
}
```

---

## 🎮 **Minecraft Integration**

### **Skript Plugin Setup**

1. Download the latest version of the Skript plugin from the [`minecraft_plugin`](minecraft_plugin/) directory
2. Place `discord_auth.sk` in your server's `plugins/Skript/scripts` directory
3. Create a `config.yml` file:

```yaml
# config.yml
server: "https://your-auth-server.com"
secret: "your-smp-secret"
timeout: 60
messages:
  success: "&a✅ Authentication successful! Welcome to the server!"
  error: "&c❌ Authentication failed. Please try again."
  timeout: "&c⏰ Authentication timeout. Please reconnect."
  waiting: "&e⏳ Please authenticate via Discord to play."
```

### **Configuration Options**

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `server` | string | required | URL of your authentication server |
| `secret` | string | required | Must match `SMP_SECRET` from server |
| `timeout` | integer | 60 | Seconds before timeout |
| `messages.success` | string | - | Message on successful auth |
| `messages.error` | string | - | Message on failed auth |
| `messages.timeout` | string | - | Message on timeout |
| `messages.waiting` | string | - | Message while waiting for auth |

### **Plugin Features**

- **Automatic Authentication**: Players must authenticate to play
- **Adventure Mode Lock**: Players are locked in adventure mode until authenticated
- **Session Management**: Tracks authentication state per player
- **Command Integration**: `/callapi <player>` for manual checks
- **Event Cancellation**: Blocks actions (chat, movement, etc.) while unauthenticated

---

## 📊 **Architecture Overview**

### **Technology Stack**

| Component | Technology | Version |
|-----------|------------|---------|
| **Backend Framework** | Phoenix | 1.8.1 |
| **Language** | Elixir | 1.15+ |
| **Database** | Ecto + SQLite | 3.13 |
| **Authentication** | Ueberauth + Ueberauth.Discord | 0.10 |
| **Rate Limiting** | Hammer | 7.0 |
| **Frontend** | Tailwind CSS | 4.1.7 |
| **UI Components** | daisyUI | Latest |
| **Icons** | Heroicons | 2.2.0 |
| **Build Tool** | esbuild | 0.10 |

### **System Architecture**

```
Minecraft Server → Skript Plugin → Auth Backend → Discord API
                                       ↓
                                  SQLite Database
```

### **Data Flow**

1. Minecraft player joins server
2. Skript plugin queries `/players/logged?mc_username=Player123`
3. If not authenticated, player is locked in adventure mode
4. Player receives authentication URL
5. Player visits URL in browser, redirected to Discord
6. Player approves Discord OAuth2 request
7. Discord redirects back to `/auth/discord/callback`
8. Server validates Discord token and guild membership
9. Server creates/updates player record
10. Server marks player as logged in
11. Skript plugin polls and detects authentication
12. Player is unlocked and can play

---

## 🔐 **Security Features**

### **✅ Implemented Security Measures**

| Feature | Implementation | Status |
|---------|----------------|--------|
| **Input Validation** | Ecto changesets, regex validation | ✅ |
| **Output Escaping** | Phoenix HTML escaping | ✅ |
| **CSRF Protection** | Built-in Phoenix CSRF tokens | ✅ |
| **SQL Injection Prevention** | Ecto parameterized queries | ✅ |
| **API Authentication** | Secret header validation | ✅ |
| **IP Protection** | SHA256 hashing | ✅ |
| **Rate Limiting** | Hammer library | ✅ |
| **Guild Verification** | Discord API membership check | ✅ |
| **Session Security** | Signed cookies | ✅ |

### **🔒 Security Best Practices**

1. **Always use HTTPS** in production
2. **Rotate secrets** regularly
3. **Monitor logs** for suspicious activity
4. **Keep dependencies updated**
5. **Use strong passwords** for Discord bot
6. **Limit API access** to Minecraft server IP
7. **Enable Discord 2FA** for your bot account

---

## 🚀 **Deployment**

### **Development**

```bash
mix phx.server
```
- Server runs on `http://localhost:4000`
- Auto-reloads on code changes
- LiveView enabled

### **Production**

#### **Option 1: Docker**

```dockerfile
# Dockerfile
FROM elixir:1.15 as builder

# Install dependencies
RUN apt-get update && apt-get install -y git nodejs npm

WORKDIR /app
COPY . .

# Build the application
RUN mix local.rebar --force
RUN mix local.hex --force
RUN mix deps.get --only prod
RUN mix compile
RUN npm install --prefix assets/node_modules
RUN npm run deploy --prefix assets
RUN mix phx.digest

FROM elixir:1.15-slim

WORKDIR /app
COPY --from=builder /app/_build/prod/rel/auth_backend /app
COPY --from=builder /app/priv /app/priv
COPY --from=builder /app/assets /app/assets

ENV MIX_ENV=prod
ENV PORT=4000

CMD ["_build/prod/rel/auth_backend/bin/auth_backend", "start"]
```

```bash
# Build and run
docker build -t minecraft-auth .
docker run -p 4000:4000 \
  -e DISCORD_CLIENT_ID=your_id \
  -e DISCORD_CLIENT_SECRET=your_secret \
  -e SMP_SECRET=your_smp_secret \
  -e GUILD_ID=your_guild \
  -e MC_SERVER_IP=your_ip \
  -e DATABASE_PATH=/data/auth.db \
  -v /path/to/data:/data \
  minecraft-auth
```

#### **Option 2: Direct Deployment**

```bash
# Build for production
MIX_ENV=prod mix deps.get --only prod
MIX_ENV=prod mix compile
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix phx.digest

# Create release
MIX_ENV=prod mix release

# Run
PORT=4000 \
DISCORD_CLIENT_ID=your_id \
DISCORD_CLIENT_SECRET=your_secret \
SMP_SECRET=your_smp_secret \
GUILD_ID=your_guild \
MC_SERVER_IP=your_ip \
DATABASE_PATH=/path/to/database.db \
_build/prod/rel/auth_backend/bin/auth_backend start
```

### **Production Checklist**

- [ ] HTTPS configured with valid SSL certificate
- [ ] All secrets in environment variables (not in code)
- [ ] Database backups configured
- [ ] Monitoring in place
- [ ] Logging configured
- [ ] Firewall rules configured
- [ ] Rate limiting tuned for production load
- [ ] Database indexes created
- [ ] CORS configured for Minecraft server
- [ ] Security headers enabled

---

## 🗺️ **Project Roadmap**

### **🎯 Current Status (v0.1.0)**
- ✅ Core authentication flow
- ✅ Discord OAuth2 integration
- ✅ Player management API
- ✅ Basic Skript plugin
- ✅ Rate limiting
- ✅ Session tracking

### **🚧 Short-term Goals (v0.2.0 - Next 1-2 Months)**

| Feature | Priority | Status | ETA |
|---------|----------|--------|-----|
| **Fix security vulnerabilities** | High | In Progress | 1 week |
| **Add comprehensive tests** | High | Not Started | 2 weeks |
| **Improve error handling** | Medium | Not Started | 1 week |
| **Add structured logging** | Medium | Not Started | 1 week |
| **Document API with OpenAPI** | Medium | Not Started | 1 week |
| **Add admin dashboard** | Low | Not Started | 2 weeks |
| **Multi-guild support** | Low | Not Started | 2 weeks |

### **📅 Medium-term Goals (v0.3.0 - 3-6 Months)**

| Feature | Priority | Description |
|---------|----------|-------------|
| **PostgreSQL support** | Medium | Replace SQLite for better scalability |
| **Redis session storage** | Medium | Enable horizontal scaling |
| **JWT authentication** | Medium | Stateless authentication for API |
| **Player statistics** | Low | Track login history, play time, etc. |
| **Ban system** | Low | Integrate with Discord bans |
| **Webhook support** | Low | Discord notifications for events |

### **🌟 Long-term Goals (v1.0.0 - 6-12 Months)**

| Feature | Priority | Description |
|---------|----------|-------------|
| **Multi-server support** | Medium | Support multiple Minecraft servers |
| **Role-based permissions** | Medium | Discord role to Minecraft permission mapping |
| **Plugin marketplace** | Low | Share plugins with community |
| **Analytics dashboard** | Low | Visualize authentication metrics |
| **Self-hosted Discord bot** | Low | Alternative to Ueberauth |
| **Docker Compose setup** | Low | Easy deployment with Docker |
| **Kubernetes support** | Low | Cloud-native deployment |

---

## 🤝 **Contributing**

We welcome contributions from the community!

### **How to Contribute**

1. Fork the repository
2. Clone your fork
3. Create a feature branch (`git checkout -b feature/amazing-feature`)
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

### **Contribution Guidelines**

- Follow the existing code style
- Add tests for new features
- Update documentation
- Use descriptive commit messages
- Keep pull requests focused on one feature/fix
- All pull requests must pass CI checks

### **Setting Up Development Environment**

```bash
git clone https://github.com/yourusername/minecraft_discord_auth.git
cd minecraft_discord_auth
mix deps.get
mix ecto.create
mix ecto.migrate
mix assets.setup
cp .env.example .env
# Edit .env with your credentials
mix phx.server
```

### **Running Tests**

```bash
# Run all tests
mix test

# Run specific test file
mix test test/auth_backend_web/controllers/api_controller_test.exs

# Run with coverage
mix test --cover
```

---

## 🐛 **Reporting Issues**

If you encounter any issues:

1. Check existing issues to see if it's already been reported
2. Create a new issue with:
   - Clear description of the problem
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots (if applicable)
   - Environment information (Elixir version, Phoenix version, OS, etc.)

---

## 📜 **License**

This project is licensed under the **MIT License**.

---

## 🙏 **Acknowledgments**

- **[Phoenix Framework](https://www.phoenixframework.org/)** - The web framework
- **[Elixir](https://elixir-lang.org/)** - The programming language
- **[Discord](https://discord.com/)** - For OAuth2 API
- **[Skript](https://skriptlang.github.io/)** - For Minecraft plugin support

---

## 📚 **About Elixir & Phoenix**

### **Elixir**

Elixir is a **functional, concurrent programming language** built on the Erlang VM (BEAM).

**Key Features:**
- Functional programming with immutable data
- Lightweight processes for concurrency
- Fault-tolerant with "let it crash" philosophy
- Distributed computing capabilities
- Powerful metaprogramming with macros

**Why Elixir for this project?**
- Perfect for real-time applications (web sockets, gaming)
- Scalable to millions of connections
- Fault-tolerant - systems self-heal
- Great developer experience

### **Phoenix Framework**

Phoenix is a **web development framework** written in Elixir for building scalable, maintainable, and real-time web applications.

**Key Features:**
- Convention over configuration
- Built-in WebSocket support (Phoenix Channels)
- LiveView for real-time HTML updates without JavaScript
- Functional programming paradigms
- Modular plug-based architecture

**Why Phoenix for this project?**
- Real-time capabilities by default
- Excellent scalability
- Maintainable code structure
- Optimized performance
- Great developer tools

---

## 🆘 **Support**

- Read the documentation
- Check the issues
- Join our Discord community
- Create an issue for bugs/feature requests

---

> **Built with Elixir and Phoenix**
> **Minecraft-Discord Authentication Backend**
