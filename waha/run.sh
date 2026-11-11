#!/bin/sh
# Turn the add-on options (/data/options.json) into WAHA environment variables,
# then hand over to the original WAHA entrypoint.
set -e

OPTIONS=/data/options.json
ENV_FILE=/tmp/waha-options.env

if [ -f "$OPTIONS" ]; then
  node -e '
    const o = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
    const env = {
      WAHA_API_KEY: o.api_key,
      WAHA_DASHBOARD_USERNAME: o.dashboard_username,
      WAHA_DASHBOARD_PASSWORD: o.dashboard_password,
      WHATSAPP_SWAGGER_USERNAME: o.dashboard_username,
      WHATSAPP_SWAGGER_PASSWORD: o.dashboard_password,
      WHATSAPP_DEFAULT_ENGINE: o.engine,
      TZ: o.timezone,
    };
    for (const line of o.env_vars || []) {
      const i = line.indexOf("=");
      if (i > 0) env[line.slice(0, i).trim()] = line.slice(i + 1);
    }
    const q = (v) => "\x27" + String(v).replace(/\x27/g, "\x27\\\x27\x27") + "\x27";
    for (const [k, v] of Object.entries(env)) {
      if (v !== undefined && v !== null && v !== "" && /^[A-Za-z_][A-Za-z0-9_]*$/.test(k)) {
        console.log("export " + k + "=" + q(v));
      }
    }
  ' "$OPTIONS" > "$ENV_FILE"
  . "$ENV_FILE"
  rm -f "$ENV_FILE"
fi

mkdir -p "$WAHA_LOCAL_STORE_BASE_DIR"

exec /entrypoint.sh
