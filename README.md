# WAHA WhatsApp Add-on for Home Assistant

Run [WAHA (WhatsApp HTTP API)](https://waha.devlike.pro) as a native Home Assistant add-on on your own hardware — no external services, no cloud dependency.

> **⚠️ Legal Warning:** This add-on violates WhatsApp's Terms of Service. WhatsApp prohibits reverse engineering their service and using unofficial third-party clients or APIs. Using this add-on may result in your WhatsApp account being temporarily or permanently banned. **Use at your own risk.** See [Disclaimer](#disclaimer) for details.

## What is WAHA?

WAHA is a self-hosted REST API for WhatsApp. It runs as a Docker container and exposes HTTP endpoints to send and receive WhatsApp messages programmatically. This add-on wraps WAHA for seamless use inside Home Assistant OS.

## Supported Architectures

| Architecture | Device | Docker Image |
|---|---|---|
| `aarch64` | Raspberry Pi 4, Raspberry Pi 5 | `devlikeapro/waha:arm-2026.10.1` |
| `amd64` | x86 PC, Intel NUC, VM | `devlikeapro/waha:latest-2026.10.1` |

> **Note:** Home Assistant builds this add-on locally and passes your device's architecture as `BUILD_ARCH`. The `Dockerfile` uses it to pick the matching WAHA image, so no manual changes are needed. The WAHA version is set by `WAHA_VERSION` in the `Dockerfile`.

## Installation

### Standard Installation

1. Go to **Settings → Apps → Install App  → Respositories(triple dot - top right) → Add**
2. Add `https://github.com/sushiljain1989/hassio-addons`
3. Find **WAHA WhatsApp** in the store and click **Install**
4. Start the add-on(See Docs)

### Manual Installation (if repository add fails)

If you cannot add the repository through the UI, you can install the add-on by copying the files directly onto your Home Assistant machine.

#### Step 1 — Access your Home Assistant filesystem

You need access to the HA filesystem. Use any one of the following options:

**Option A — File Editor add-on** (simplest, browser-based)
1. Install the **File Editor** add-on from the Add-on Store
2. Open it and navigate to `/addons/`

**Option B — Visual Studio Code add-on** (best for editing files)
1. Install the **Studio Code Server** add-on from the Add-on Store
2. Open it — you get a full VS Code editor with access to the entire HA filesystem
3. Navigate to `/addons/`

#### Step 2 — Find your device architecture

In the VS Code terminal or SSH terminal run:

```bash
ha info | grep arch
```

| Output | Architecture | Device |
|---|---|---|
| `aarch64` | aarch64 | Raspberry Pi 4, Raspberry Pi 5 |
| `x86_64` | amd64 | x86 PC, Intel NUC, VM |

#### Step 3 — Copy the addon folder

Download or clone the repository from `https://github.com/sushiljain1989/hassio-addons` and copy the entire `waha/` folder into `/addons/` on your HA machine.

#### Step 4 — Install from local add-on store

1. Go to **Settings → Apps → Install app**
2. The **WAHA WhatsApp** add-on will appear under **Local add-ons**
3. Click **Install**

## First-Time Setup

> **⚠️ Security:** The default API key and dashboard password in this add-on are public and must be changed before use. Set `api_key`, `dashboard_username` and `dashboard_password` to your own values in the add-on's **Configuration** tab, then restart the add-on. Use your own key wherever the examples below show `waha_fixed_key_2026`.

1. Open the Web UI (`http://<your-ha-ip>:3000/dashboard`)
2. Log in with `admin` / `waha_fixed_password_2026`
3. Start the `default` session
4. Scan the QR code in WhatsApp: **Settings → Linked Devices → Link a Device**
5. Session will show as **WORKING** — you only need to scan once

## Sending WhatsApp Messages from Home Assistant

Add to `configuration.yaml`:

```yaml
rest_command:
  send_whatsapp:
    url: "http://localhost:3000/api/sendText"
    method: POST
    headers:
      Content-Type: application/json
      X-Api-Key: "waha_fixed_key_2026"
    payload: '{"chatId": "{{ phone }}@c.us", "text": "{{ message }}", "session": "default"}'

  waha_start_session:
    url: "http://localhost:3000/api/sessions/default/start"
    method: POST
    headers:
      X-Api-Key: "waha_fixed_key_2026"
```

Use in automations:

```yaml
service: rest_command.send_whatsapp
data:
  phone: "491234567890"
  message: "Motion detected in the garden!"
```

## Auto-start Session After Reboot

Add to `automations.yaml`:

```yaml
- alias: "Start WAHA session on startup"
  trigger:
    - platform: homeassistant
      event: start
  action:
    - delay: "00:00:30"
    - service: rest_command.waha_start_session
```

## Configuration

Set these in the add-on's **Configuration** tab:

| Option | Default | Description |
|---|---|---|
| `api_key` | `waha_fixed_key_2026` | API key — send it as the `X-Api-Key` header in every REST request |
| `dashboard_username` | `admin` | Dashboard and Swagger login username |
| `dashboard_password` | `waha_fixed_password_2026` | Dashboard and Swagger login password |
| `engine` | `WEBJS` | WhatsApp engine: `WEBJS`, `NOWEB` or `GOWS` |
| `timezone` | — | Timezone, e.g. `America/Sao_Paulo` |
| `env_vars` | `[]` | Any other WAHA environment variable, one `NAME=value` per line (see below) |

Options are applied when the add-on starts, so restart it after changing them.

Example `env_vars` to forward incoming messages to a Home Assistant webhook:

```yaml
env_vars:
  - WHATSAPP_HOOK_URL=http://homeassistant:8123/api/webhook/whatsapp_incoming
  - WHATSAPP_HOOK_EVENTS=message
```

The full list of WAHA variables is in the [WAHA docs](https://waha.devlike.pro/docs/how-to/config/).

## Session API Reference

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/sessions` | Create a new session |
| `GET` | `/api/sessions` | List all sessions |
| `GET` | `/api/sessions/{session}` | Get session status |
| `POST` | `/api/sessions/{session}/start` | Start a session |
| `POST` | `/api/sessions/{session}/stop` | Stop a session |
| `POST` | `/api/sessions/{session}/restart` | Restart a session |
| `POST` | `/api/sessions/{session}/logout` | Logout and clear auth |
| `DELETE` | `/api/sessions/{session}` | Delete session |
| `GET` | `/api/{session}/auth/qr` | Get QR code image |

## Session Status States

| Status | Meaning |
|---|---|
| `STOPPED` | Not running |
| `STARTING` | Initializing |
| `SCAN_QR_CODE` | Waiting for QR scan (expires in 60-120s) |
| `WORKING` | Connected and ready |
| `FAILED` | Error — restart or re-authenticate |

## Storage

Session data is stored in HA persistent storage at `/data/.sessions` and survives add-on restarts and HA reboots. You only need to scan the QR code once.

Media files are stored temporarily at `/tmp/whatsapp-files` with a 180 second lifetime by default.

## Notes

- Uses WAHA CORE (free) — no paid subscription required
- Not affiliated with or endorsed by WhatsApp/Meta
- Uses [whatsapp-web.js](https://github.com/pedroslopez/whatsapp-web.js) engine by default
- WhatsApp may ban accounts that use unofficial APIs — use at your own risk

## Disclaimer & Legal Notice

> **By installing or using this add-on you explicitly and irrevocably accept all terms in the [LICENSE](./LICENSE). If you do not agree, do not install or use this software.**

**This project is provided as-is, without any warranty of any kind, express or implied.**

The author (Sushil Jain) is not affiliated with, endorsed by, or in any way associated with WhatsApp, Meta, the WAHA project, or the Home Assistant project.

### WhatsApp Terms of Service

This add-on violates WhatsApp's Terms of Service. WhatsApp explicitly prohibits reverse engineering their service and using unofficial third-party clients or APIs. Using this add-on may result in your WhatsApp account being **temporarily or permanently banned** and may expose you to legal action by Meta/WhatsApp.

### Intended Use

This software is intended for **personal, non-commercial, educational use only** on your own private hardware. It must **not** be used for:
- Bulk or automated mass messaging
- Spam or unsolicited commercial communications
- Operating a messaging service for third parties
- Any purpose that violates applicable laws or regulations

### Privacy & Data Protection

You are the sole data controller for any personal data processed through your use of this software. You are solely responsible for compliance with GDPR, BDSG (Germany), CCPA, and all other applicable data protection laws. The author is neither a data processor nor a data controller and bears no liability for any data breach or regulatory penalty.

### Security Responsibility

The default credentials shipped in this add-on are **examples only** and are publicly visible on GitHub. You are solely responsible for changing them before deployment. The author accepts no liability for any security incident resulting from use of default or weak credentials.

### No Support or Maintenance

The author has no obligation to provide support, bug fixes, updates, or responses to issues or pull requests. This software may cease to function at any time without notice.

### Limitation of Liability

To the maximum extent permitted by law, the author accepts **zero liability** for any damage, data loss, account suspension, regulatory fines, legal costs, or any other harm — direct or indirect — arising from the use or misuse of this software. The author's total cumulative liability shall not exceed **€0.00**.

### Indemnification

By using this software, you agree to fully indemnify and hold harmless the author from any and all claims, losses, damages, liabilities, and costs (including attorney fees) arising from your use of the software, your violation of any law or third-party terms of service, or any messages transmitted through your use of the software.


See the full [LICENSE](./LICENSE) for complete terms including all warranties, limitations, indemnification, prohibited uses, and jurisdiction clauses.
