# WAHA WhatsApp Add-on — Full Documentation

## Overview

WAHA (WhatsApp HTTP API) is a self-hosted REST API for WhatsApp. This add-on runs WAHA as a Home Assistant add-on, giving you full WhatsApp integration without any external services.

---

## Installation

### Standard Installation

1. Go to **Settings → Apps → Install App  → Respositories(triple dot - top right) → Add**
2. Add `https://github.com/sushiljain1989/hassio-addons`
3. Find **WAHA WhatsApp** in the store and click **Install**
4. Start the add-on

---

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

In the **Terminal** tab of the SSH add-on or the VS Code terminal, run:

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

---

## First-Time Setup

> **⚠️ Security:** The default API key and dashboard password in this add-on are public and must be changed before use. Set `api_key`, `dashboard_username` and `dashboard_password` to your own values in the add-on's **Configuration** tab, then restart the add-on. Use your own key wherever the examples below show `waha_fixed_key_2026`.

After installing and starting the add-on:

1. Open the **Web UI** — click "Open Web UI" on the add-on page, or go to `http://<your-ha-ip>:3000/dashboard`
2. Log in with:
   - Username: `admin`
   - Password: `waha_fixed_password_2026`
3. The `default` session is pre-configured — click **Start** to start it
4. A QR code will appear — scan it with WhatsApp on your phone:
   - Open WhatsApp → **Settings → Linked Devices → Link a Device**
5. Wait for status to show **WORKING**

Session data is persisted — you only need to scan the QR code once. After HA or add-on restarts, start the session again (or use the auto-start automation below).

---

## Docker Image

This add-on uses the official WAHA Docker image:

| Architecture | Image Tag |
|---|---|
| `aarch64` (Raspberry Pi 4/5) | `devlikeapro/waha:arm-2026.10.1` |
| `amd64` (x86/NUC/VM) | `devlikeapro/waha:latest-2026.10.1` |

The correct image is selected automatically. Home Assistant builds the add-on locally and passes your device's architecture as the `BUILD_ARCH` build argument; the `Dockerfile` uses it to pick the matching image. The WAHA version is set by `WAHA_VERSION` in the `Dockerfile`.

WAHA CORE (free tier) is used. No paid subscription required.

---

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

## Environment Variables

The variables below can be set through `env_vars` (the ones covered by an option above are set for you). The full list is in the [WAHA docs](https://waha.devlike.pro/docs/how-to/config/).

### Security

| Variable | Default | Description |
|---|---|---|
| `WAHA_API_KEY` | `waha_fixed_key_2026` | API key — include as `X-Api-Key` header in all REST requests |
| `WAHA_DASHBOARD_USERNAME` | `admin` | Dashboard UI login username |
| `WAHA_DASHBOARD_PASSWORD` | `waha_fixed_password_2026` | Dashboard UI login password |
| `WAHA_NO_API_KEY` | `false` | Set `true` to disable API key requirement |

### Sessions

| Variable | Default | Description |
|---|---|---|
| `WAHA_DEFAULT_SESSION` | `default` | Default session name |
| `WHATSAPP_RESTART_ALL_SESSIONS` | `false` | Auto-restart all sessions on startup |
| `WAHA_AUTO_START_DELAY_SECONDS` | `0` | Delay before auto-starting sessions |
| `WAHA_CLIENT_DEVICE_NAME` | — | Name shown in WhatsApp Linked Devices list |
| `WAHA_CLIENT_BROWSER_NAME` | — | Browser name shown in WhatsApp |

### Storage

| Variable | Default | Description |
|---|---|---|
| `WAHA_LOCAL_STORE_BASE_DIR` | `/data/.sessions` | Base directory for session persistence |
| `WHATSAPP_FILES_FOLDER` | `/tmp/whatsapp-files` | Directory for received media files |
| `WHATSAPP_FILES_LIFETIME` | `180` | Media file lifetime in seconds (`0` = permanent) |
| `WHATSAPP_DOWNLOAD_MEDIA` | `true` | Whether to download incoming media |

### Engine

| Variable | Default | Description |
|---|---|---|
| `WHATSAPP_DEFAULT_ENGINE` | `WEBJS` | Engine: `WEBJS`, `NOWEB`, or `GOWS` |

### Logging

| Variable | Default | Description |
|---|---|---|
| `WAHA_LOG_LEVEL` | `info` | Log level: `error`, `warn`, `info`, `debug`, `trace` |
| `WAHA_LOG_FORMAT` | `PRETTY` | Log format: `PRETTY` or `JSON` |
| `TZ` | — | Timezone e.g. `Europe/Berlin` |

### Webhooks (receive messages in HA)

| Variable | Default | Description |
|---|---|---|
| `WHATSAPP_HOOK_URL` | — | URL to POST incoming events to |
| `WHATSAPP_HOOK_EVENTS` | — | Events to forward: `message`, `session.status`, or `*` for all |
| `WHATSAPP_HOOK_HMAC_KEY` | — | Secret key for webhook HMAC signature verification |
| `WHATSAPP_HOOK_RETRIES_POLICY` | — | Retry policy: `linear` or `exponential` |
| `WHATSAPP_HOOK_RETRIES_DELAY_SECONDS` | `2` | Delay between retries |

### Proxy

| Variable | Default | Description |
|---|---|---|
| `WHATSAPP_PROXY_SERVER` | — | Proxy server (e.g. `localhost:3128`) |
| `WHATSAPP_PROXY_SERVER_USERNAME` | — | Proxy username |
| `WHATSAPP_PROXY_SERVER_PASSWORD` | — | Proxy password |

---

## Session Management API

All requests require the `X-Api-Key` header.

### Create a session

```bash
curl -X POST http://<ha-ip>:3000/api/sessions \
  -H 'Content-Type: application/json' \
  -H 'X-Api-Key: waha_fixed_key_2026' \
  -d '{"name": "default"}'
```

### Start a session

```bash
curl -X POST http://<ha-ip>:3000/api/sessions/default/start \
  -H 'X-Api-Key: waha_fixed_key_2026'
```

### Check session status

```bash
curl http://<ha-ip>:3000/api/sessions/default \
  -H 'X-Api-Key: waha_fixed_key_2026'
```

Response:
```json
{
  "name": "default",
  "status": "WORKING",
  "me": {
    "id": "491234567890@c.us",
    "pushName": "Your Name"
  }
}
```

### Get QR code for authentication

```bash
curl http://<ha-ip>:3000/api/default/auth/qr?format=image \
  -H 'X-Api-Key: waha_fixed_key_2026' \
  --output qr.png
```

### Stop a session

```bash
curl -X POST http://<ha-ip>:3000/api/sessions/default/stop \
  -H 'X-Api-Key: waha_fixed_key_2026'
```

### Logout (clears WhatsApp auth — requires new QR scan)

```bash
curl -X POST http://<ha-ip>:3000/api/sessions/default/logout \
  -H 'X-Api-Key: waha_fixed_key_2026'
```

### Session status states

| Status | Meaning |
|---|---|
| `STOPPED` | Not running |
| `STARTING` | Initializing |
| `SCAN_QR_CODE` | Waiting for QR scan (expires in 60–120s) |
| `WORKING` | Connected and ready |
| `FAILED` | Error — restart or re-authenticate |

---

## Sending Messages API

### Send a text message

```bash
curl -X POST http://<ha-ip>:3000/api/sendText \
  -H 'Content-Type: application/json' \
  -H 'X-Api-Key: waha_fixed_key_2026' \
  -d '{
    "chatId": "491234567890@c.us",
    "text": "Hello from Home Assistant!",
    "session": "default"
  }'
```

### Send an image

```bash
curl -X POST http://<ha-ip>:3000/api/sendImage \
  -H 'Content-Type: application/json' \
  -H 'X-Api-Key: waha_fixed_key_2026' \
  -d '{
    "chatId": "491234567890@c.us",
    "file": {"url": "https://example.com/image.jpg"},
    "caption": "Look at this!",
    "session": "default"
  }'
```

### Send a file

```bash
curl -X POST http://<ha-ip>:3000/api/sendFile \
  -H 'Content-Type: application/json' \
  -H 'X-Api-Key: waha_fixed_key_2026' \
  -d '{
    "chatId": "491234567890@c.us",
    "file": {"url": "https://example.com/document.pdf"},
    "caption": "Your document",
    "session": "default"
  }'
```

> **Note:** Phone numbers must be in international format without `+` (e.g. `491234567890` not `+491234567890`)

---

## Home Assistant Integration

### REST commands (`configuration.yaml`)

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

  waha_stop_session:
    url: "http://localhost:3000/api/sessions/default/stop"
    method: POST
    headers:
      X-Api-Key: "waha_fixed_key_2026"
```

### Auto-start session on HA boot (`automations.yaml`)

```yaml
- alias: "Start WAHA session on startup"
  trigger:
    - platform: homeassistant
      event: start
  action:
    - delay: "00:00:30"
    - service: rest_command.waha_start_session
```

### Send a message from an automation

```yaml
- alias: "Notify on motion"
  trigger:
    - platform: state
      entity_id: binary_sensor.garden_motion
      to: "on"
  action:
    - service: rest_command.send_whatsapp
      data:
        phone: "491234567890"
        message: "Motion detected in the garden!"
```

### Receive messages via webhook

To trigger HA automations when a WhatsApp message arrives, add the webhook variables to `env_vars` in the add-on's **Configuration** tab:

```yaml
env_vars:
  - WHATSAPP_HOOK_URL=http://homeassistant:8123/api/webhook/whatsapp_incoming
  - WHATSAPP_HOOK_EVENTS=message
```

Then in HA create an automation with a webhook trigger:

```yaml
- alias: "Handle incoming WhatsApp message"
  trigger:
    - platform: webhook
      webhook_id: whatsapp_incoming
  action:
    - service: notify.notify
      data:
        message: "WhatsApp message received: {{ trigger.json.payload.body }}"
```

---

## Storage

Session authentication data is stored at `/data/.sessions` inside the container, which maps to HA's persistent add-on storage. This survives:
- Add-on restarts
- HA reboots
- HA OS updates

You only need to scan the QR code once. If you **logout** (not stop) the session, WhatsApp auth is cleared and a new QR scan is required.

---

## Troubleshooting

**QR code keeps appearing after restart**
- The session was logged out, not just stopped. Start the session — if it goes to `WORKING` directly, data is persisted. If it goes to `SCAN_QR_CODE`, scan once and it will persist going forward.

**401 Unauthorized**
- Add the `X-Api-Key` header with your `api_key` (default `waha_fixed_key_2026`) to all requests.

**Message not delivered**
- Check session status is `WORKING` before sending.
- Phone number must be in international format without `+`.

**Add-on won't start**
- Check the add-on logs for errors.
- Make sure port 3000 is not used by another add-on.

**Web UI not accessible**
- Try `http://<your-ha-ip>:3000/dashboard` directly in your browser.

---

## Disclaimer & Legal Notice

> **By installing or using this add-on you explicitly and irrevocably accept all terms in the LICENSE file. If you do not agree, do not install or use this software.**

**This project is provided as-is, without any warranty of any kind, express or implied.**

The author (Sushil Jain) is not affiliated with, endorsed by, or in any way associated with WhatsApp, Meta, the WAHA project, or the Home Assistant project.

### WhatsApp Terms of Service

This add-on violates WhatsApp's Terms of Service. WhatsApp explicitly prohibits reverse engineering their service and using unofficial third-party clients or APIs. WAHA works by reverse-engineering the WhatsApp Web protocol, which is unauthorized by WhatsApp/Meta.

**Risks include:**
- Temporary or permanent ban of your WhatsApp account
- Legal action by WhatsApp/Meta in extreme cases

### Intended Use

This software is intended for **personal, non-commercial, educational use only** on your own private hardware. It must **not** be used for:
- Bulk or automated mass messaging
- Spam or unsolicited commercial communications
- Operating a messaging service for third parties
- Any purpose that violates applicable laws or regulations, including EU anti-spam law (ePrivacy Directive), Germany's UWG, CAN-SPAM, or CASL

### Privacy & Data Protection

You are the sole data controller for any personal data processed through your use of this software. You are solely responsible for compliance with GDPR (EU) 2016/679, BDSG (Germany), CCPA, and all other applicable data protection laws. Sending automated messages without recipients' prior consent may be illegal in your jurisdiction. The author is neither a data processor nor a data controller and bears no liability for any data breach or regulatory penalty.

### Security Responsibility

The default credentials (`WAHA_API_KEY`, `WAHA_DASHBOARD_USERNAME`, `WAHA_DASHBOARD_PASSWORD`) shipped in this add-on are **examples only** and are publicly visible on GitHub. You are solely responsible for changing them before deployment and for securing access to the API. The author accepts no liability for any security incident resulting from use of default or weak credentials.

### No Support or Maintenance

The author has no obligation to provide support, bug fixes, updates, or responses to issues or pull requests. This software may cease to function at any time without notice, including as a result of changes to WhatsApp's platform.

### Limitation of Liability

To the maximum extent permitted by law, the author accepts **zero liability** for any damage, data loss, account suspension, regulatory fines, legal costs, or any other harm — direct or indirect — arising from the use or misuse of this software. The author's total cumulative liability shall not exceed **€0.00**.

### Indemnification

By using this software, you agree to fully indemnify and hold harmless the author from any and all claims, losses, damages, liabilities, and costs (including attorney fees) arising from your use of the software, your violation of any law or third-party terms of service, or any messages transmitted through your use of the software.

