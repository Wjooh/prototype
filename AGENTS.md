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

Cook/prep unit from one supplier for one umbrella order (`Day::SupplierOrder`). Holds the line items and a prep window (`prep_start`–`prep_end`) that sits on the timeline Cook lane, before pickup. One umbrella order can have multiple supplier orders (different suppliers, or the same supplier across morning/lunch/dinner waves).

### Order item

Quantity of a product on a supplier order (`Day::OrderItem`). Shown as square product cards with emoji and a top-right quantity badge.

### Product / Supplier

Catalog stubs for the day fixture (`Day::Product`, `Day::Supplier`). Supplier has a display color used on badges; product has name + emoji.

### Delivery

A booked multileg ride with a courier partner (`Day::Delivery`). Kinds: swiftee, uber, stuart, self. Has a cost and an ordered list of stops. Does not belong to a single umbrella order — one delivery can touch hub stock and multiple customers/orders.

### Stop

One leg of a delivery (`Day::Stop`): supplier, hub (`tadaaa`), or customer. Either a pickup or a dropoff, each with its own time window. Typical windows in fixtures: **30 min pickup**, **1 hr dropoff**, with **30–60 min drive** between consecutive stops (minimal/no overlap).

### Hub (tadaaa)

Our consolidation place. Appears as a stop place, not a supplier. Used for morning inbound consolidation and evening fan-out, and for mixing hub stock into customer deliveries.

### Deliveries view

`/monitor/deliveries` — split panel: umbrella order cards | delivery cards for the day, with selection sync between them. Scenario workflow graphs sit at the bottom.

### Timeline view

`/monitor/timeline` — horizontal day timeline at 200px/hour (06:00–20:00). Two lanes: **Cook** (supplier-order prep bars with expanded item cards) and **Delivery** (one bar per stop, width = that stop’s window, consecutive stops linked with curves). Lane visibility toggled via query params `cook=0` / `delivery=0` (SSR; hidden lanes render grayscale + semitransparent). Same scenario graphs at the bottom.
