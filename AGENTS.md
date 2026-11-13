# Agent context

Project conventions and feature docs for Cursor agents.

## Feature docs

- [Party Assistant](docs/assistant.md) — multi-step wizard that collects party details and recommends ready bundles (custom party build planned). Read this before changing `app/views/assistant`, `AssistantController`, or kids bundle matching.
- Monitor day planning — fixture graph in `db/fixtures/day.yml`, POROs under `app/models/day/`, views at `/monitor/deliveries` and `/monitor/timeline`. Read this glossary before changing those.

## Glossary

### Island

A white surface that sits on a page background: `bg-white`, rounded corners (`rounded-xl`), and a light border (`border border-gray-200`). Optional padding and a light shadow (`shadow-sm`) when the island is interactive or needs lift. Use islands to group related content into distinct panels — order cards, delivery cards, timeline blocks — not for chrome like nav or sticky headers.

### Day (fixed date)

Monitor prototype is locked to one calendar day (`Day::DATE`, currently Fri 13 Nov 2026). All orders, supplier orders, and deliveries in the fixture belong to that day. No calendar UI yet.

### Umbrella order (Order)

Customer-facing order (`Day::Order`). Internally just “order”. Has a 2-hour customer receive slot, customer name + avatar initials, order total, and profit margin. An umbrella order owns one or more supplier orders and may be touched by several deliveries.

### Supplier order

Cook/prep unit from one supplier for one umbrella order (`Day::SupplierOrder`). Holds the line items and a prep window (`prep_start`–`prep_end`). On the timeline, prep is an island (product cards only, no label) on that supplier’s lane; a pickup spans every track of the supplier orders it carries (one car, N preps → N-row-tall pickup). One umbrella order can have multiple supplier orders (different suppliers, or the same supplier across morning/lunch/dinner waves).

### Order item

Quantity of a product on a supplier order (`Day::OrderItem`). Shown as square product cards with emoji and a top-right quantity badge.

### Product / Supplier

Catalog stubs for the day fixture (`Day::Product`, `Day::Supplier`). Supplier has a display color used on badges; product has name + emoji.

### Delivery

A booked multileg ride with a courier partner (`Day::Delivery`). Kinds: swiftee, uber, stuart, self. Has a cost and an ordered list of stops. Does not belong to a single umbrella order — one delivery can touch hub stock and multiple customers/orders.

### Stop

One leg of a delivery (`Day::Stop`): supplier, hub (`tadaaa`), or customer. Either a pickup or a dropoff, each with its own time window. Typical windows in fixtures: **30 min pickup**, **1 hr dropoff**, with **30–60 min drive** between consecutive stops (minimal/no overlap). Each stop lists `load` / `unload` order-item ids (what goes into / out of the car). Cargo must balance across a delivery (e.g. morning Jelena cakes unload at hub, then reload on evening fan-out with Geamos food).

### Hub (tadaaa)

Our consolidation place — same physical location as supplier TADAAA!. On the timeline they share one lane (inbound/fan-out `place: hub`, outbound own-stock `place: supplier` / `supplier_id: tadaaa`). Used for morning inbound consolidation, evening fan-out, and cooking/assembly of own stock.

### Deliveries view

`/monitor/deliveries` — split panel: umbrella order cards | delivery cards for the day, with selection sync between them. Scenario workflow graphs sit at the bottom.

### Timeline view

`/monitor/timeline` — horizontal day timeline at 200px/hour (06:00–20:00). Swimlanes: Geamos, TADAAA/hub, Jelena — built by `Day::TimelineLayout`. Customer stops stay on the previous supplier/hub stop’s lane and track (straight arrow; e.g. Geamos → TADAAA → Alice: cross-lane then same-lane). Prep and stop islands are tall (`size-16` + padding); overlapping intervals stack onto tracks within a lane, non-overlapping waves reuse from the top. Cross-lane legs bias tracks toward the neighbor (Geamos→hub on top of the hub lane, Jelena→hub at the bottom) so inbound arrows don’t cross. Cross-lane connectors use cubic curves. Hub stay (continuity) connectors are hidden by default; `?continuity=1` shows them. `?focus=prep|delivery|<supplier_id>|<order_id>` keeps that type / supplier / umbrella order normal and dims the rest (SSR; grayscale + semitransparent); supplier focus = that supplier’s prep plus pickup/dropoff at that supplier; no focus = all normal. Left labels stay undimmed. Same scenario graphs at the bottom.
