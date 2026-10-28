**Description:**
The **Radio Performance** feature controls which inventory protocol the reader uses to communicate with tags.

**Usage:**
Select the inventory protocol that matches your tag population:

- **GEN2:** Inventories both Gen2 and Gen2X-capable tags using the standard Gen2 protocol. Use this for maximum compatibility.
- **GEN2X:** Inventories only Gen2X-capable tags using the Gen2X protocol. Use this when the tag population fully supports Gen2X.
- **HYBRID:** Inventories Gen2 and Gen2X tags using their respective protocols. Use this for a mixed tag population.

This feature changes the inventory protocol only. It does not enable FastID, TagFocus, Tag Quieting, or Protected Mode.

> **Note:** If the current mode contains antenna, power, filter, or reporting settings, sending only `inventoryProtocol.mode` may reset the omitted settings to their default values. Send the complete operating-mode configuration, including all settings that must remain active.

**How to Configure and Apply Radio Performance:**

1. Retrieve the current operating-mode configuration using MQTT `get_mode` or REST `GET /cloud/mode`.
2. If inventory is running, stop it using MQTT `stop` or REST `PUT /cloud/stop`.
3. In the retrieved configuration, set `payload.inventoryProtocol.mode` for MQTT or `inventoryProtocol.mode` for REST. Keep all other settings that must remain active.
4. Send the complete updated configuration using MQTT `set_mode` or REST `PUT /cloud/mode`.
5. Restart inventory using MQTT `start` or REST `PUT /cloud/start`.

Radio Performance is part of the operating mode, so applying it does not require `applyImpinjGen2X`.

**Parameter Paths:**

- **MQTT:** `payload.inventoryProtocol.mode`
- **REST:** `inventoryProtocol.mode`
- **Type:** string. Must be `GEN2`, `GEN2X`, or `HYBRID`.

<div class="endpoint-block"><div class="ep-heading ep-mqtt">MQTT Endpoint Details</div><table class="endpoint-table"><tbody><tr><td>Command</td><td><code>set_mode</code></td></tr><tr><td>Request body</td><td>Operating-mode configuration inside <code>payload</code></td></tr></tbody></table></div>

<div class="endpoint-block"><div class="ep-heading ep-rest">REST Endpoint Details</div><table class="endpoint-table"><tbody><tr><td>Method</td><td><span class="ep-method ep-method-put">PUT</span></td></tr><tr><td>Path</td><td><code>/cloud/mode</code></td></tr><tr><td>Request URL</td><td><code>https://&lt;device-ip&gt;/cloud/mode</code></td></tr><tr><td>Content-Type</td><td><code>application/json</code></td></tr><tr><td>Request body</td><td>Operating-mode configuration without the MQTT envelope</td></tr></tbody></table></div>
