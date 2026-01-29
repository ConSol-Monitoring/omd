
# README – VictoriaMetrics `vmauth` Configuration  

## Overview  

`vmauth` is the authentication and routing proxy for VictoriaMetrics.  
It validates incoming requests, adds the required authentication (headers or bearer tokens) and forwards them to the configured VictoriaMetrics backend(s).  

In an OMD (Open Monitoring Distribution) installation the configuration file is expected at  

```
$OMD_ROOT/etc/victoriametrics/vmauth/auth_conf.yml
```

**Important** – Do **not** delete the header comments that are already present in this file. OMD’s update mechanism will try to rewrite the file and will preserve those comments. Removing them can cause the configuration to be overwritten during package upgrades.

## File structure  

The configuration is a YAML document with the following top‑level keys:

| Key   | Description |
|-------|-------------|
| `users` | List of user definitions. Each entry can contain a `username`/`password` **or** a `bearer_token`. |
| `url_map` | Mapping of source paths (`src_paths`) to a backend (`url_prefix`). Optional settings like `retry_status_codes`, custom `headers` and TLS flags can be defined per map. |

### Example configuration  

Below is a ready‑to‑use example that you can copy into `auth_conf.yml`. Keep the original comment block at the top of the file.

```yaml
#
# OMD VMAUTH config file
# In case this file is empty, check README.md for instructions.
# IMPORTANT: Start editing **below** this line.
#
users:
  - username: "test"
    password: "test"
    url_map:
      - src_paths:
          - "/api/v1/query"
          - "/api/v1/query_range"
          - "/api/v1/labels"
          - "/api/v1/label/[^/]+/vales"
          - "/api/v1/metadata"
          - "/api/v1/query_exemplars"
          - "/api/v1/status/.*"
          - "/api/v1/export"
          - "/api/v1/export/native"
        url_prefix: "https://localhost:8428"
        retry_status_codes: [500,502]
        headers:
          - " Authorization: Basic dGVzdDp0ZXN0Cg"
    tls_insecure_skip_verify: true

  - bearer_token: "DasistderToken"
    url_map:
      - src_paths:
          - "/api/v1/query"
          - "/api/v1/query_range"
          - "/api/v1/labels"
          - "/api/v1/label/[^/]+/vales"
          - "/api/v1/metadata"
          - "/api/v1/query_exemplars"
          - "/api/v1/status/.*"
          - "/api/v1/export"
          - "/api/v1/export/native"
        url_prefix: "https://localhost:8428"
        retry_status_codes: [500,502]
        headers:
          - " Authorization: Basic dGVzdDp0ZXN0Cg"
    tls_insecure_skip_verify: true
```

## How to apply the configuration  

1. **Edit the file**  

   ```bash
   vi $OMD_ROOT/etc/victoriametrics/vmauth/auth_conf.yml
   ```

   Add or modify user entries as needed. Preserve the comment block at the top of the file.

2. **Validate YAML syntax** (optional but recommended)  

   ```bash
   yamllint $OMD_ROOT/etc/victoriametrics/vmauth/auth_conf.yml
   ```

3. **Restart the VMAuth** – this restarts the `vmauth` service with the new configuration:  

   ```bash
   omd restart vmauth
   ```

4. **Verify** that the proxy works by sending a request, e.g.:  

   ```bash
   curl -H "Authorization: Basic $(echo -n test:test | base64)" \
        https://<site>.example.com/vmauth/api/v1/query
   ```

## Common configuration options  

| Option                     | Description |
|----------------------------|-------------|
| `username` / `password`    | Basic authentication credentials. |
| `bearer_token`             | Token for Bearer‑Authorization header. |
| `src_paths`                | Regular expressions or exact paths that should be routed to the backend. |
| `url_prefix`               | Destination VictoriaMetrics endpoint (including scheme and port). |
| `retry_status_codes`       | HTTP status codes that trigger an automatic retry. |
| `headers`                  | Additional HTTP headers to attach to each proxied request. |
| `tls_insecure_skip_verify` | `true` disables TLS certificate verification (useful for self‑signed certs). |

## Tips & Best Practices  

* **Least privilege** – Define only the API paths a user actually needs.  
* **Secure tokens** – Store bearer tokens in a secret manager or restrict file permissions (`chmod 600`).  
* **TLS verification** – Turn off `tls_insecure_skip_verify` in production and use valid certificates.  
* **Version control** – Keep a copy of the configuration in a Git repository.  

## Troubleshooting  

| Symptom                           | Check |
|-----------------------------------|-------|
| `vmauth` fails to start           | Run `omd config show <site_name>` and look for syntax errors in `auth_conf.yml`. |
| Requests return 401/403           | Verify that the credentials (basic or bearer) match what is defined under `users`. |
| Backend is unreachable            | Ensure `url_prefix` is correct, the service is listening on the port, and TLS settings match. |
| No retries on 5xx errors          | Confirm that the status code is listed in `retry_status_codes`. |

---  

For further details refer to the official VictoriaMetrics documentation:  
https://victoriametrics.com/docs/vmauth/