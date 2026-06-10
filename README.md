# hxdiscord_api

A modern, interactions-first Discord API wrapper for **Haxe**, targeting **Node.js** and **C++ (hxcpp)**, on the Discord API **v10**.

Write a working bot in a few lines: connect with intents, register commands, and reply — including ephemeral (only-you) slash command responses.

```haxe
final client = new Client(token, Intents.GUILDS | Intents.GUILD_MESSAGES | Intents.MESSAGE_CONTENT);

client.onReady = () -> trace('logged in as ${client.user.username}');

client.add("ping", ctx -> ctx.reply("pong"));

client.connect();
```

---

## Features

- **Gateway connection** with HELLO / heartbeat (+ ACK zombie detection) / IDENTIFY / dispatch
- **Intents** (including privileged ones like Message Content)
- **REST client** with auth header, User-Agent, and JSON handling
- **Unified command system** — one `add(...)` for:
  - prefix commands (`!ping`), with a global or per-command prefix — even prefixless
  - condition rules (run when a predicate matches a message)
  - slash commands (with **ephemeral** replies)
- **One `Context`** for every command, with a single `reply(content, style)`
- **Typed data models** (User, Guild, Channel, Message, Member, Role, Emoji, …)
- Platform behind interfaces (`IHttpClient`, `IGatewaySocket`, `IScheduler`) so other targets can be added later

> Not in v1: voice, OAuth2 user-auth, the outgoing HTTP-interactions webhook, and REST rate limiting (planned next).

---

## Requirements

- [Haxe](https://haxe.org) 4.3+
- **Node.js target:** [Node.js](https://nodejs.org) 18+, `hxnodejs` (Haxe lib), and `ws` (npm package)
- **C++ target:** `hxcpp` and `haxe-ws` (Haxe libs), plus a C++ toolchain (MSVC, g++, or clang)

---

## Installation

```bash
haxelib install hxdiscord_api
```

This pulls the Haxe dependencies (`hxnodejs`, `haxe-ws`) automatically. Then add what your target needs:

```bash
# Node.js target also needs the ws npm package
npm install ws

# C++ target also needs hxcpp (plus a C++ toolchain: MSVC, g++, or clang)
haxelib install hxcpp
```

---

## Creating a bot & getting a token

1. Open the [Discord Developer Portal](https://discord.com/developers/applications) → **New Application**.
2. Go to **Bot** → **Reset Token** → copy it. (This is the *bot token*, not the Client ID/Secret.)
3. On the same page, enable **MESSAGE CONTENT INTENT** if you want to read message text.
4. Invite the bot with the **`bot`** and **`applications.commands`** scopes (the second is required for slash commands):

   ```
   https://discord.com/api/oauth2/authorize?client_id=YOUR_CLIENT_ID&permissions=68608&scope=bot%20applications.commands
   ```

Keep this token secret. In the example you paste it directly into `Main.hx`; for real projects load it from an environment variable or a gitignored file instead.

---

## Quick start

`example/Main.hx`:

```haxe
package;

import gateway.Intents;
import commands.ReplyStyle;

class Main {
	static function main() {
		final token = "PASTE_YOUR_TOKEN";

		final client = new Client(token, Intents.GUILDS | Intents.GUILD_MESSAGES | Intents.MESSAGE_CONTENT);

		client.onReady = () -> Sys.println('logged in as ${client.user.username}');

		client.add("ping", ctx -> ctx.reply("pong"));            // !ping  -> pong
		client.add("hi", ctx -> ctx.reply("hello!", Reply));     // !hi    -> replies to you

		client.add({                                             // /secret -> only you see it
			name: "secret",
			description: "A reply only you can see",
			execute: ctx -> ctx.reply("only you can see this", Ephemeral)
		});

		client.connect();
	}
}
```

Paste your bot token over `"PASTE_YOUR_TOKEN"`, then build and run:

```bash
haxe bot.hxml          # see "Building" below for the hxml
node bin/bot.js
```

---

## Intents

Combine intents with `|`. Privileged intents (Message Content, Guild Members, Presence) must also be enabled in the Developer Portal.

```haxe
import gateway.Intents;

final intents = Intents.GUILDS
	| Intents.GUILD_MESSAGES
	| Intents.MESSAGE_CONTENT;

final client = new Client(token, intents);
```

Available: `GUILDS`, `GUILD_MEMBERS`, `GUILD_MODERATION`, `GUILD_EMOJIS_AND_STICKERS`, `GUILD_INTEGRATIONS`, `GUILD_WEBHOOKS`, `GUILD_INVITES`, `GUILD_VOICE_STATES`, `GUILD_PRESENCES`, `GUILD_MESSAGES`, `GUILD_MESSAGE_REACTIONS`, `GUILD_MESSAGE_TYPING`, `DIRECT_MESSAGES`, `DIRECT_MESSAGE_REACTIONS`, `DIRECT_MESSAGE_TYPING`, `MESSAGE_CONTENT`, `GUILD_SCHEDULED_EVENTS`, `AUTO_MODERATION_CONFIGURATION`, `AUTO_MODERATION_EXECUTION`, `GUILD_MESSAGE_POLLS`, `DIRECT_MESSAGE_POLLS`.

---

## Commands

Everything is registered through a single method: `client.add(...)`. It returns the client, so calls can be chained. The shape of what you pass decides the kind of command:

| Kind | Define with | Triggered by |
|---|---|---|
| Prefix command | `add("name", handler)` or `{ name, execute }` | `!name …` (a chat message) |
| Condition rule | `{ when, execute }` | any message matching a predicate |
| Slash command | `{ name, description, execute }` | `/name` (an interaction) |

### Prefix commands

```haxe
// Shorthand: name + handler
client.add("ping", ctx -> ctx.reply("pong"));

// Object form
client.add({ name: "ping", execute: ctx -> ctx.reply("pong") });
```

Arguments after the command name are parsed for you:

```haxe
client.add("echo", ctx -> {
	if (ctx.args.length == 0) ctx.reply("nothing to echo");
	else ctx.reply(ctx.argString);
});
```

**Prefix.** The default is `"!"`. Change it globally with:

```haxe
client.commandPrefix = "?";
```

…or give a single command its **own** starting prefix — the 3rd argument in the shorthand, or the `prefix` field in the object form. Use `""` for no prefix at all:

```haxe
client.add("ping", ctx -> ctx.reply("pong"));          // !ping    (global default)
client.add("hi", ctx -> ctx.reply("hello!"), "?");     // ?hi
client.add("status", ctx -> ctx.reply("ok"), ".");     // .status
client.add("menu", ctx -> ctx.reply("..."), "");       // menu     (prefixless)

client.add({ name: "hi", prefix: "?", execute: ctx -> ctx.reply("hello!") });
```

Matching uses a word boundary, so `?hi` won't fire on `?high`. Different commands can use different prefixes at the same time.

### Condition rules

Run a handler whenever a predicate matches a message — no fixed command name needed.

```haxe
import commands.Conditions;

client.add({ when: Conditions.contains("!ping"), execute: ctx -> ctx.reply("pong") });
client.add({ when: Conditions.matches(~/\bbye\b/i), execute: ctx -> ctx.reply("See you!") });

// Your own predicate is just Message -> Bool:
client.add({ when: m -> m.content.length > 100, execute: ctx -> ctx.reply("long one!") });
```

Built-in `Conditions`:

| Builder | Matches when the message… |
|---|---|
| `equals("hi")` | content equals `hi` |
| `contains("ping")` | content contains `ping` |
| `startsWith("?")` | content starts with `?` |
| `endsWith("!")` | content ends with `!` |
| `matches(~/regex/i)` | content matches a regex |
| `fromUser(id)` | author is that user |
| `inChannel(id)` | posted in that channel |
| `all([a, b])` | all conditions match (AND) |
| `any([a, b])` | any condition matches (OR) |
| `not(a)` | condition does not match |

### Slash commands

Add `description` and the command becomes a slash command. It's registered automatically in every guild the bot is in (instant), so it appears under `/` right away. Requires the `applications.commands` invite scope.

```haxe
client.add({
	name: "hello",
	description: "Greet the channel",
	execute: ctx -> ctx.reply('Hello from ${ctx.user.username}!')
});
```

### Putting it together

```haxe
client
	.add("ping", ctx -> ctx.reply("pong"))                                   // !ping
	.add("echo", ctx -> ctx.reply(ctx.argString, Reply))                     // !echo hi -> replies "hi"
	.add("hi", ctx -> ctx.reply("hey"), "?")                                 // ?hi  (custom prefix)
	.add({ when: Conditions.contains("good morning"),                        // reacts to a phrase
	       execute: ctx -> ctx.reply("Good morning!") })
	.add({ name: "secret", description: "Only-you reply",                    // /secret  (ephemeral)
	       execute: ctx -> ctx.reply("🤫", Ephemeral) });
```

---

## The `Context` object

Every command handler — prefix, condition, or slash — receives the same `ctx`:

| Member | Description |
|---|---|
| `ctx.reply(content, ?style)` | Respond (see reply styles below) |
| `ctx.user` | The user who invoked the command |
| `ctx.args` | Words after a prefix command name |
| `ctx.argString` | `args` joined back into a string |
| `ctx.message` | The triggering message (null for slash commands) |
| `ctx.interaction` | The triggering interaction (null for message commands) |
| `ctx.client` | The `Client` |

### Reply styles

`reply` takes an optional `ReplyStyle`:

```haxe
import commands.ReplyStyle;

ctx.reply("hi");              // Normal    — plain message (default)
ctx.reply("hi", Reply);       // Reply     — references the user's message
ctx.reply("hi", Ephemeral);   // Ephemeral — only the user sees it (slash commands)
```

---

## Sending messages & embeds

```haxe
client.sendMessage(channelId, "hello");

client.sendEmbed(channelId, {
	title: "Status",
	description: "All systems go.",
	color: 0x57F287
});

client.reply(message, "got it");  // reply referencing a message
```

Every send takes an optional callback `(err, data)`:

```haxe
client.sendMessage(channelId, "hi", (err, data) -> {
	if (err != null) trace('send failed: $err');
});
```

---

## Events

```haxe
client.onReady = () -> trace('ready as ${client.user.username}');
client.onMessageCreate = (msg) -> trace('${msg.author.username}: ${msg.content}');
client.onDispatch = (type, data) -> trace('event: $type');   // any gateway event
client.onLog = (line) -> trace('[gateway] $line');            // connection/heartbeat logs
```

---

## Raw REST access

For endpoints not yet wrapped, use `client.rest`:

```haxe
client.rest.get('/users/@me', (err, data) -> trace(data.username));
client.rest.post('/channels/$channelId/messages', { content: "hi" });
client.rest.request("DELETE", '/channels/$channelId/messages/$messageId');
```

---

## Project structure

```
src/
├── Client.hx           # main facade: connect, events, add(...), send helpers
├── commands/           # Command, Context, Conditions, ReplyStyle
├── gateway/            # GatewayClient, Intents, Opcodes
├── rest/               # RestClient
├── types/              # User, Guild, Channel, Message, Role, ... + interactions/
└── platform/           # IHttpClient / IGatewaySocket / IScheduler (interfaces)
    ├── node/           # Node.js implementations  (#if js)
    └── sys/            # C++ / sys implementations (#if sys)
example/Main.hx         # the example bot
test/Tests.hx           # cross-target unit tests
```

The platform interfaces are the seam between the portable core and the
target-specific transport. `Client` never references Node or sys APIs directly —
it asks `Platform` for an implementation, chosen at compile time.

---

## Building

The same source compiles to either target. The right platform implementation
(HTTP, WebSocket, timers) is selected automatically via conditional compilation,
so your bot code doesn't change between targets.

### Node.js — `bot.hxml`

```hxml
-lib hxnodejs
-cp src
-cp example
-D js-es=6
-main Main
--js bin/bot.js
```

```bash
haxe bot.hxml
node bin/bot.js
```

### C++ — `build-cpp.hxml`

```hxml
-lib haxe-ws
-cp src
-cp example
-main Main
-cpp bin/cpp
```

```bash
haxe build-cpp.hxml
./bin/cpp/Main
```

The example hardcodes the token (`final token = "PASTE_YOUR_TOKEN";`) for simplicity — paste your real token there first. For real projects, prefer loading it from an environment variable or a gitignored file instead of committing it.

> On C++ the gateway uses `haxe-ws`, polled on a `haxe.Timer` on the main event loop (mirroring Node's single-threaded model), and secure `wss://` relies on hxcpp's bundled mbedtls. The Node.js target is the more battle-tested of the two.

---

## Tests

`test/Tests.hx` is a small target-agnostic suite (snowflake decoding, intents, conditions) that runs on both targets:

```bash
# Node.js
haxe tests.hxml && node bin/tests.js

# C++
haxe tests-cpp.hxml && ./bin/tests-cpp/Tests
```

---

## Project status

Targets: **Node.js** (primary, well-tested) and **C++** (hxcpp, newer — the gateway/REST work but have had less real-world testing).

Implemented: gateway connect/heartbeat/identify/dispatch, REST client, intents, typed models, the unified command system (prefix / condition / slash) with global and per-command prefixes, ephemeral replies, embeds.

Planned next: REST **rate limiting**, slash command **options/arguments**, resume/reconnect, message components (buttons/selects/modals), and configurable caching.

Out of scope for v1: voice, OAuth2 user-auth, and the outgoing HTTP-interactions webhook.

---

## License

MIT
