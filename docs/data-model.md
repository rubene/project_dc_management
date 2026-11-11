# Data model

Every query v1 needs, and the design of the one main DynamoDB table built around them (issue #7). Later tickets follow this design. A ticket that needs a query not listed here adds it to this page in the same PR.

Terms follow [`GLOSSARY.md`](../GLOSSARY.md). In keys, `<c>` is a Center ID, `<o>` an Organization ID, `<p>` a person ID, `<k>` a child ID and `<d>` a Center-local date (`yyyy-mm-dd`).

## Rules every record follows

### The Center is in the key

- Every record about a Center's operations has a partition key starting `C#<c>#`, or exactly `C#<c>`. Every secondary-index key starts the same way.
- Keys are built only by one key-building module, which can't build a Center key without a Center ID. Request handlers get a data layer bound to the one Center the request was authorized for, so a handler can't read another Center's records even by mistake (ADR 0010).
- Only five partitions sit outside a Center, and none holds anything about a child:

  | Partition | Why it can't be inside a Center |
  |---|---|
  | `PERSON#<p>` | One login spans Centers and Organizations |
  | `LOGIN#<cognito sub>` | Login happens before a Center is known |
  | `ORG#<o>` | An Organization sits above its Centers |
  | `STRIPEACCOUNT#<account>` | Some Stripe Connect webhooks identify only the account |
  | `CENTERS` | A list of every Center, for operations only. No request handler can reach it |

- Scheduled jobs run one Center at a time. Each Center gets its own EventBridge Scheduler schedules, in its own timezone, for its closing-time check and retention, so no job needs a query across Centers. Creating a Center, or changing its timezone or closing time, updates its schedules.

### Corrected records keep append-only history

Records that can be corrected use a **head and history** pair:

- The **head** holds the current version at the record's normal sort key, with a `version` number. Queries read heads.
- Every version, including the first, is also written as an immutable **history** item at `H#<head sort key>#<version, zero-padded>`. It holds the full record, who changed it, when, and the reason.
- A change writes the new history item and updates the head in one transaction. The history put has the condition `attribute_not_exists`, and the head update has the condition `version = expected`, so two changes can't both win and nothing is ever overwritten.
- This doubles the writes for these records, which is cheap at a Center's size and is the price of never losing an original. Don't optimize it away.

This applies to Sign-in/out, Room Transfers, Room presence, a child's people (Guardian status, Authorized Pickup, Emergency Contact, Pickup Restriction, Records Restriction), a child's Payer, Photo Consent and the Center's profile.

A record never moves partition, so a correction can't change a Sign-in/out's day. Instead an Admin **voids** it, which is a correction with a reason, and the replacement is entered as a new record. Staff can enter it as a late entry. A voided record:

- no longer counts toward Attendance or `LIVE`
- stays in the Sign-in/out log and licensing report, marked void with its reason
- dismisses any late-fee suggestion it produced, unless an Admin already approved it. An approved Charge is left for the Admin to reverse.

### Records are ready for offline use (ADR 0004)

- **IDs created on the device.** Records created in the apps take their ID from the device, as a ULID. ULIDs sort by creation time, which also lets retention delete old records by sort-key range. The API rejects IDs that aren't ULIDs, and ULIDs whose time is more than 7 days from the server's clock, so a wrong device clock can't put a record outside retention. The window is revisited when offline use arrives in v2.
- **Two times.** Each record has `occurredAt`, when it happened, as given by the person, and `recordedAt`, when the server saved it, from the `Clock`. Business rules use `occurredAt`. Day partitions use the Center-local date of `occurredAt`, so a late entry lands on the day it happened.
- **Duplicate-safe retries.**
  - A create is a put with the condition `attribute_not_exists(PK)`, and stores a hash of the request on the version 1 history item (or on the item itself, for records without history).
  - The put uses `ReturnValuesOnConditionCheckFailure: ALL_OLD`. If it fails because the item exists, the API compares the request's hash with the stored one, without a second read. The same request gets the original result back, even after later corrections. A different one gets a conflict.
  - A change to an existing record carries a device-created `changeId` and the version it expects. It's retried the same way, against the history item for that version.
  - Records the server derives from another record, such as each child's copy of a Child Update, take a key built from the source's ID, so a retry writes the same keys.
- Every record also stores `recordedBy` (the person), `recordedVia` (`app` or `assistant`) and `deviceId`.

### Addressing records in the API

A record's API path carries every part of its key, so reading or correcting it is a single Get. For example, a Sign-in/out is `/centers/{c}/days/{d}/children/{k}/sign-ins/{id}`, and a photo is `/centers/{c}/batches/{batch}/photos/{photo}`. An ID alone is never enough, because a ULID's time can't give the day of a late entry.

### Other conventions

- Every item has `type` and `centerId` (or `orgId`) attributes, so exports don't parse keys.
- Times are UTC ISO-8601 strings. The Center stores its IANA timezone for local dates and closing time. The Owner picks it when creating the Center, filled in from the browser. It can change later. Existing records keep the dates they were saved with, and the change keeps history.
- A person's ID is separate from their Cognito user ID, because Authorized Pickups and Emergency Contacts without a login need IDs too. The token carries the person ID as a custom claim, so `LOGIN#<sub>` is read only at sign-up.
- Short-lived items (sessions, invitations, Assistant text, dedupe markers) set a `ttl` attribute. DynamoDB deletes them lazily, so reads also check `expiresAt`.
- Access checks always use strongly consistent reads of the base table, never the secondary index, so removing access takes effect on the next request.
- The table has no local secondary index, so no partition has a size limit, and none may be added. Child partitions grow for years.
- **One stream reader.** DynamoDB Streams has a single reader, a Lambda that sends notifications, updates Ratio alerts and retries Stripe syncs. DynamoDB allows about two readers per stream shard, so new work joins this Lambda, or it forwards to EventBridge. It skips deletes made by TTL.

## Table layout

### Partitions inside a Center

The last column is how the Center's export and deletion find each partition (C8). A ticket that adds a new kind of Center partition adds its row here, with how it's found.

| Partition key | Holds | Sort keys | Found from |
|---|---|---|---|
| `C#<c>` | The Center and its settings | `CENTER`, `ROOM#<room>`, `PLAN#<plan>`, `DISCOUNT#<id>`, `LATEFEE`, `BILLING`, `STRIPE`, `SETUP`, `IMPORT#<id>`, `ASSISTANT#<yyyy-mm>` | Fixed |
| `C#<c>#PEOPLE` | Everyone the Center knows, with or without a login, their Roles there, a Staff member's assigned Room, and whether they've ever been a Payer | `PERSON#<p>`, `PIN#<p>`, `INVITE#<token hash>` | Fixed |
| `C#<c>#DEVICES` | Registered devices, shared-tablet sessions | `DEVICE#<device>`, `SESSION#<session>` | Fixed |
| `C#<c>#ROSTER` | One item per child: name, Main Room, Payer, status | `CHILD#<k>` | Fixed |
| `C#<c>#CHILD#<k>` | Everything that belongs to one child | `REL#<p>`, `PAYER`, `CONSENT`, `ENR#<id>`, `OTP#<d>#<id>`, `CHG#<id>`, `CREDIT#<id>`, `UPDATE#<id>`, `CONV#<conv>`, plus `H#…` history | `ROSTER` |
| `C#<c>#DAY#<d>` | The day's events | `SIO#<k>#<id>`, `TRANSFER#<k>#<id>`, `PRESENCE#<p>#<id>`, plus `H#…` history | Every date from the Center's `createdAt` to today |
| `C#<c>#LIVE` | Who's where right now, a projection of the day partitions | `CHILD#<k>`, `STAFF#<p>`, `ALERT#<room>` | Fixed |
| `C#<c>#ANNOUNCEMENTS` | Announcements | `ANN#<id>` | Fixed |
| `C#<c>#CONV#<conv>` | One Conversation's messages and read markers | `MSG#<id>`, `READ#<p>` | `CONV#` heads under each child |
| `C#<c>#BATCHES` | Every photo upload batch | `BATCH#<batch>` | Fixed |
| `C#<c>#BATCH#<batch>` | One batch's photos (a single photo is a batch of one) | `PHOTO#<photo>` | `BATCHES` |
| `C#<c>#PAYER#<p>` | One Payer's Stripe customer and Stripe subscription, and copies of their invoices and payments | `CUSTOMER`, `SUBSCRIPTION`, `INV#<created at>#<stripe invoice>`, `PAYMENT#<created at>#<stripe payment>` | People who have ever been a Payer |
| `C#<c>#NOTIFY` | Notifications already sent, and bundled ones waiting | `SENT#<source id>#<p>`, `DIGEST#<p>#<id>` | Fixed |
| `C#<c>#STRIPE` | Stripe webhook events already handled, and the Payer behind each Stripe customer | `EVENT#<event id>`, `CUSTOMER#<stripe customer>` | Fixed |
| `C#<c>#ASSISTANT#<p>` | A person's Assistant requests, replies and Proposed Actions, deleted after 30 days | `MSG#<id>`, `PROPOSED#<id>` | `PEOPLE` |

Notes on the less obvious choices:

- **A person's Roles are written twice, in one transaction.** `C#<c>#PEOPLE / PERSON#<p>` is the one access checks read. `PERSON#<p> / ACCESS#C#<c>` lets the app list a person's Centers at login.
- **A child's people are one head per person.** `REL#<p>` holds the person's flags for that child (Guardian, Authorized Pickup, Emergency Contact, Pickup Restriction, Records Restriction, former Guardian with a download window). One person can hold several at once.
- **`LIVE` is a projection, never the source of truth.** Each `LIVE` item holds the state that follows from the person's latest event by `occurredAt`, with that event's ID and time, and its own `version`.
  - A new event that's later than the stored one updates the item on top of it.
  - A late entry that's earlier leaves it alone.
  - A correction or void of the stored event walks back through the person's events, day by day with D10, to find the latest one still standing. That works even when a child was signed in on an earlier day and never signed out.
  - The event and the `LIVE` update are one transaction, conditional on `LIVE`'s `version`. If two devices record the same child at once, one transaction fails and is retried on the new state, so neither is lost.
- **Ratio alerts are worked out after the write.** The stream reader compares each Room's counts with its Ratio and updates `ALERT#<room>` only when the state changes. Keeping it out of the Sign-in/out transaction means events in a busy Room don't cancel each other.
- **Invoices live with the Payer, not the child.** A Records Restriction blocks a Guardian's reads under the child, and a restricted Guardian who's the Payer still reads their own partition.
- **Photos are stored once and linked from each tagged child's feed.** The `UPDATE#<photo>` item under each tagged child points at the photo. Who may see a photo is decided when it's read, never copied into the feed:
  - A Guardian of a tagged child sees it unless an Admin removed it.
  - Anyone else who may see the feed sees it only if every tagged child has Photo Consent. Staff see it as held back otherwise.
  - So removing a photo or withdrawing consent is a single write, and it applies to photos already shared.
  - A feed page reads the page's photos and the tagged children's consent in one batch Get each (M10, M8).
- **A Staff member's Room** is the Room they're present in, or their assigned Room when they aren't present in any. It decides which children they see and which shared Conversations they can reply in.

### Billing through Stripe Billing (ADR 0011)

- Every Payer is a person with an app login, so they can pay, set up autopay and download their history in the app.
- Each Payer has a Stripe customer and one Stripe subscription in the Center's Stripe account, stored as `C#<c>#PAYER#<p> / CUSTOMER` and `SUBSCRIPTION`. `C#<c>#STRIPE / CUSTOMER#<stripe customer>` finds the Payer from a webhook.
- Each Enrollment is one item on its Payer's Stripe subscription, and `ENR#<id>` stores the item's ID. The Tuition Plan's Stripe Price sets the amount. A price override uses a Price of its own, and a discount uses a Stripe coupon on the item. DC Management decides who gets a discount from the children, not from who pays, so siblings with different Payers still get a sibling discount.
- Every Stripe subscription at a Center uses the Center's billing frequency, and starts on the Center's billing start date as a subscription schedule.
- Stripe's proration is off. DC Management suggests a prorated amount, and the Admin's edited amount goes on the first invoice as an invoice item.
- **Changing the Payer.** Only an Admin changes a child's Payer, with a reason. `PAYER` under the child is a head with history, and the ROSTER item's `payerId` is updated in the same transaction. The change takes effect at the start of the next billing period, unless the Admin picks a date mid-period. Then:
  1. The new Payer gets a Stripe customer if they don't have one. Their invoices are emailed until they opt in to autopay.
  2. The child's item is removed from the old Payer's Stripe subscription and added to the new Payer's, with Stripe's proration off. Stripe bills each period in advance, so the old Payer's next invoice leaves the child out and the new Payer's includes them. A new Stripe subscription bills on the same date as the rest of the Center.
  3. A mid-period date suggests a prorated split, which the Admin can edit, added to each Payer's next invoice as invoice items.
  4. Charges and credits dated before the change stay with the old Payer. Those dated on or after it go to the new Payer.
  5. Past invoices, paid or not, stay with the old Payer, along with their payment history. Neither Payer sees the other's invoices, payments or card details.
  6. A Payer left with no children has their Stripe subscription end with the period. Their Stripe customer and copies of their history stay.
- Autopay is the Stripe subscription's collection method: charged automatically if the Payer opted in, otherwise the invoice is emailed.
- An approved Charge or subsidy credit becomes a Stripe invoice item on the Payer's customer, which the next invoice picks up. Its ID is sent as Stripe's idempotency key and in metadata, and the Stripe ID is saved on the record. A retry after Stripe's 24-hour idempotency window first looks for an invoice item with that metadata.
- **Syncing.** A change to a Tuition Plan, Enrollment, discount, override or Payer is saved in DynamoDB first, marked `stripeSync: pending`, and then sent to Stripe. A sync that fails stays pending, and the stream reader retries it until it lands.
- Stripe creates the invoices. Webhooks copy them, and the payments with their card brand and last four digits, into the Payer's partition.

### Partitions outside a Center

| Partition key | Holds | Sort keys |
|---|---|---|
| `PERSON#<p>` | Login profile, the Centers and Organizations the person belongs to, personal devices and push tokens, notification settings | `PROFILE`, `ACCESS#C#<c>`, `ACCESS#O#<o>`, `DEVICE#<device>`, `PREFS#C#<c>` |
| `LOGIN#<cognito sub>` | The person a Cognito login belongs to | `LOGIN` |
| `ORG#<o>` | The Organization, its Centers and Owners, its subscription to DC Management and Stripe events for it | `ORG`, `CENTER#<c>`, `OWNER#<p>`, `SUBSCRIPTION`, `USAGE#<billing date>`, `EVENT#<event id>` |
| `STRIPEACCOUNT#<account>` | The Center a Stripe Connect account belongs to | `ACCOUNT` |
| `CENTERS` | Every Center, for operations only | `CENTER#<c>` |

### Secondary index

One overloaded, sparse index, `GSI1` (`GSI1PK`, `GSI1SK`). Only items that need it set the attributes. Every entry's key starts with the Center. It's added by the first ticket that needs it.

| `GSI1PK` | `GSI1SK` | Set on | Answers |
|---|---|---|---|
| `C#<c>#CHILD#<k>#SIO` | `<d>#<id>` | Sign-in/out heads | A child's Attendance over a date range |
| `C#<c>#GUARDIAN#<p>` | `CHILD#<k>` | `REL` heads where the person is a Guardian | A Guardian's children at a Center |
| `C#<c>#CONVERSATIONS` | `<last message at>#<conv>` | Conversation heads | Admin inbox |
| `C#<c>#SUGGESTED` | `<recorded at>#<id>` | Charges only while suggested | Charges waiting for an Admin's approval |
| `C#<c>#INVOICES#<yyyy-mm>` | `<status>#<stripe invoice>` | Invoice copies, by the month they were created | The Center's invoices for a month, by status |
| `C#<c>#STRIPESYNC` | `<recorded at>#<id>` | Records only while `stripeSync` is pending | Changes still to reach Stripe |

## Every v1 query

Each query has an ID, so tickets and code can refer to it. "Get" is a single-item read, and "Query" reads one partition, optionally by sort-key prefix or range.

### Access

| ID | Query | Tickets | How |
|---|---|---|---|
| A1 | The person a Cognito login belongs to | #8 | Get `LOGIN#<sub>` |
| A2 | A person's Organizations, Centers and Roles, for the app at login | #8, #12, #13 | Query `PERSON#<p>`, prefix `ACCESS#` |
| A3 | A person's Roles at a Center, on every request | all | Consistent Get `C#<c>#PEOPLE / PERSON#<p>` |
| A4 | Whether the request's device has been removed, on every request | #14 | Consistent Get `C#<c>#DEVICES / DEVICE#<device>`, in one batch with A3 |
| A5 | Whether a person is an Owner of an Organization | #9, #10 | Consistent Get `ORG#<o> / OWNER#<p>` |
| A6 | Whether a Guardian may see a child: a Guardian and not under a Records Restriction | #12, #15, #20, #26–#31 | Consistent Get `C#<c>#CHILD#<k> / REL#<p>` |
| A7 | A Center's people and their Roles | #9, #13, #40 | Query `C#<c>#PEOPLE`, prefix `PERSON#` |
| A8 | Check a personal PIN on a shared tablet, and count failed tries | #14 | Get and conditional update `C#<c>#PEOPLE / PIN#<p>` |
| A9 | A shared tablet's current PIN session | #14 | Consistent Get `C#<c>#DEVICES / SESSION#<session>` |
| A10 | A Center's registered devices | #14 | Query `C#<c>#DEVICES`, prefix `DEVICE#` |
| A11 | The invitation behind an invitation link, which carries the Center ID and a token | #9, #12, #13, #40 | Get `C#<c>#PEOPLE / INVITE#<token hash>` |
| A12 | A Center's pending invitations | #40 | Query `C#<c>#PEOPLE`, prefix `INVITE#` |
| A13 | A person's push tokens | #16 | Query `PERSON#<p>`, prefix `DEVICE#` |
| A14 | A person's notification settings at a Center | #28 | Get `PERSON#<p> / PREFS#C#<c>` |

### Daily operations

| ID | Query | Tickets | How |
|---|---|---|---|
| D1 | A Center's children, with Main Room, Payer and status | #12, #13, #24 | Query `C#<c>#ROSTER` |
| D2 | The children whose Main Room is a given Room | #13, #25 | D1, filtered (a Center has at most about 150 children) |
| D3 | A Guardian's children at a Center | #12 | Query GSI1 `C#<c>#GUARDIAN#<p>`, then A6 for each before showing anything |
| D4 | A child's people: Guardians, Authorized Pickups, Emergency Contacts and restrictions | #19, #20, #24 | Query `C#<c>#CHILD#<k>`, prefix `REL#` |
| D5 | The history of changes to a child's people | #20 | Query `C#<c>#CHILD#<k>`, prefix `H#REL#` |
| D6 | Who may collect a child at sign-out, with photos and whether their ID was checked | #19, #20, #21 | D4, plus D7, plus batch Get of `C#<c>#PEOPLE / PERSON#<p>` |
| D7 | Today's One-Time Authorized Pickups for a child, to check a PIN | #21 | Query `C#<c>#CHILD#<k>`, prefix `OTP#<today>#` |
| D8 | Which children are signed in, and which children and Staff are in each Room, right now | #15, #22, #23 | Query `C#<c>#LIVE` |
| D9 | A day's Sign-in/out, Room Transfers and presence across the Center | #15, #41 | Query `C#<c>#DAY#<d>` |
| D10 | A child's Sign-in/out and Room Transfers on a day, to update `LIVE` and Attendance | #15, #17, #22 | Query `C#<c>#DAY#<d>`, prefixes `SIO#<k>#` and `TRANSFER#<k>#` |
| D11 | The full history of one Sign-in/out | #17 | Query `C#<c>#DAY#<d>`, prefix `H#SIO#<k>#<id>#` |
| D12 | A child's Attendance over a date range | #15 | Query GSI1 `C#<c>#CHILD#<k>#SIO`, `GSI1SK` between the dates |
| D13 | The Attendance report for a date range | #41 | D9 for each day in the range |
| D14 | The Sign-in/out log for a date range, with who recorded each entry, every correction and every void | #41 | D9 for each day, including `H#` items |
| D15 | Children still signed in, and Staff still present in a Room, at closing. Both are flagged to an Admin and left open | #18 | D8, filtered to signed in or present |
| D16 | A Center's Rooms and Ratios | #11 | Query `C#<c>`, prefix `ROOM#` |
| D17 | Rooms out of Ratio | #23 | Query `C#<c>#LIVE`, prefix `ALERT#`, kept up to date by the stream reader from D8 and D16 |
| D18 | The printable daily roster for the Center or a Room | #24 | D1, then D4 for each child, then batch Get of the people |

### Communication

| ID | Query | Tickets | How |
|---|---|---|---|
| M1 | Announcements a Guardian should see, newest first | #25 | Query `C#<c>#ANNOUNCEMENTS`, descending, filtered to the Center and their children's Main Rooms |
| M2 | The Guardians to notify for an Announcement | #25 | D2 (or D1), then D4 for each child |
| M3 | A child's feed of Child Updates and photos, newest first | #28, #30 | Query `C#<c>#CHILD#<k>`, prefix `UPDATE#`, descending, then M10 and M8 for the page's photos |
| M4 | A child's Conversations, shared and private | #26, #27 | Query `C#<c>#CHILD#<k>`, prefix `CONV#` |
| M5 | A Conversation's messages, newest first | #26, #27 | Query `C#<c>#CONV#<conv>`, prefix `MSG#`, descending |
| M6 | Every Conversation at a Center, by latest message, for Admins | #26, #27 | Query GSI1 `C#<c>#CONVERSATIONS`, descending |
| M7 | The shared Conversations a Staff member can reply in | #26 | D2 for their Room, then M4 for each child |
| M8 | Photo Consent for every child tagged in a set of photos | #29, #30, #31 | Batch Get `C#<c>#CHILD#<k> / CONSENT` |
| M9 | The history of a child's Photo Consent | #29 | Query `C#<c>#CHILD#<k>`, prefix `H#CONSENT#` |
| M10 | Photos by key, to decide who may see them, issue a signed link, finish an upload or remove one | #30, #31 | Batch Get `C#<c>#BATCH#<batch> / PHOTO#<photo>` |
| M11 | A batch's photos, with upload progress and any held back | #31 | Query `C#<c>#BATCH#<batch>` |
| M12 | A Guardian's bundled notifications waiting to go | #28, #31 | Query `C#<c>#NOTIFY`, prefix `DIGEST#<p>#` |
| M13 | Whether a notification was already sent, so retries don't send it twice | #16 | Conditional put `C#<c>#NOTIFY / SENT#<source id>#<p>` |
| M14 | Every photo a child is tagged in, for export and retention | #43, #44 | Query `C#<c>#CHILD#<k>`, prefix `UPDATE#`, photos only |

The shared Conversation for a child has the ID `shared-<k>`, so it's never created twice.

### Billing

| ID | Query | Tickets | How |
|---|---|---|---|
| B1 | A Center's billing settings, Tuition Plans with their Stripe Prices, discounts, late-fee rules and Stripe connection | #32, #33, #35, #36, #37 | Query `C#<c>` (a small partition), or Get one item |
| B2 | A child's Enrollments, with their Stripe subscription items | #12, #33, #35 | Query `C#<c>#CHILD#<k>`, prefix `ENR#` |
| B3 | A Payer's Stripe customer and Stripe subscription | #33, #35, #37 | Get `C#<c>#PAYER#<p> / CUSTOMER` and `SUBSCRIPTION` |
| B4 | A child's Charges and credits, with whether they've reached Stripe | #36 | Query `C#<c>#CHILD#<k>`, prefixes `CHG#` and `CREDIT#` |
| B5 | Suggested Charges waiting for approval | #36 | Query GSI1 `C#<c>#SUGGESTED` |
| B6 | The late-fee suggestion for a sign-out, which follows its corrections and voids | #36 | Get `C#<c>#CHILD#<k> / CHG#late-<sign-out id>` |
| B7 | The Payer behind a Stripe customer, for webhooks | #33, #34, #37 | Get `C#<c>#STRIPE / CUSTOMER#<stripe customer>` |
| B8 | A Payer's own invoices and payments | #34, #38 | Query `C#<c>#PAYER#<p>`, prefixes `INV#` and `PAYMENT#` |
| B9 | A Center's invoices for a month, by status | #34, #37 | Query GSI1 `C#<c>#INVOICES#<yyyy-mm>` |
| B10 | Changes still to reach Stripe, for the retry | #33, #35, #36 | Query GSI1 `C#<c>#STRIPESYNC` |
| B11 | Whether a Stripe webhook event was already handled | #34, #37 | Conditional put `C#<c>#STRIPE / EVENT#<event id>`, or `ORG#<o> / EVENT#<event id>` for the Organization's subscription |
| B12 | The Center a Stripe Connect account belongs to | #32 | Get `STRIPEACCOUNT#<account>` |
| B13 | An Organization's subscription to DC Management and its trial | #39 | Get `ORG#<o> / SUBSCRIPTION` |
| B14 | Active Enrollments across an Organization, to set its subscription's quantity before each billing date | #39 | C2, then D1 counted for each Center, saved as `ORG#<o> / USAGE#<billing date>` |
| B15 | A child's Payer and the history of who paid when | #33 | Get `C#<c>#CHILD#<k> / PAYER`, and Query prefix `H#PAYER#` |

### Centers

| ID | Query | Tickets | How |
|---|---|---|---|
| C1 | A Center's profile: Organization, currency, timezone, closing time, retention, `createdAt` | all | Get `C#<c> / CENTER` |
| C2 | An Organization's Centers | #8, #10 | Query `ORG#<o>`, prefix `CENTER#` |
| C3 | The Owner's view of all Centers | #10 | A5, then C2, then C1 and a summary (D1, D8) for each Center in turn. Each Center's `orgId` is checked against the Organization |
| C4 | The setup checklist | #40 | Get `C#<c> / SETUP` |
| C5 | A CSV import's progress and row errors | #40 | Get `C#<c> / IMPORT#<id>` |
| C6 | Records past the Center's retention period (see [Retention](#retention)) | #43 | Day partitions by date, messages by ULID sort-key range, children by withdrawal date from D1, invoice and payment copies by date |
| C7 | Former Guardians still inside their photo download window | #43 | D4, where the `REL` head is a former Guardian with `accessUntil` in the future |
| C8 | Everything a Center holds, for its export and deletion | #44 | Every partition kind in the table above, found the way its last column says |

### Assistant

The Assistant reads and acts through the API operations above (ADR 0007), so it adds only these:

| ID | Query | How |
|---|---|---|
| X1 | A person's recent Assistant requests and replies | Query `C#<c>#ASSISTANT#<p>`, prefix `MSG#` |
| X2 | A Proposed Action, to confirm it. Its ID is the idempotency key for the API operation it carries out | Get `C#<c>#ASSISTANT#<p> / PROPOSED#<id>` |
| X3 | The Center's Assistant use this month, against its fair-use limit | Atomic add on `C#<c> / ASSISTANT#<yyyy-mm>` |

## Owner's view across Centers

An Owner's view never reads across Centers in one query. It reads the Organization's list of Centers (C2) and then each Center in turn (C3), as the spec says. Each Center's record carries its `orgId`, which must match. The list comes from `ORG#<o>`, so it can't include another Organization's Centers.

## Export to S3 for analytics

- An EventBridge schedule starts DynamoDB's own export to S3 once a day, as a full export of the table. That needs point-in-time recovery, which is on in every stage, dev included.
- Athena reads the latest export through a table over its DynamoDB JSON, with one partition per export date. There's no stream, Firehose or Glue schema to maintain.
- The export holds full records, so the bucket is as sensitive as the table. It blocks public access, is encrypted, isn't served through CloudFront, and is readable only by backend services.
- An S3 lifecycle rule deletes each export after 14 days, so a record deleted from the table is gone from analytics within two weeks.

## Retention

Each Center sets two retention periods:

- **Records**, counted two ways:
  - Day partitions (Sign-in/out, Room Transfers, presence) and Conversation messages count from each record's own date.
  - Everything under a child counts from the date the child withdraws: profile, people, Photo Consent, feed, Enrollments and Charges.
- **Billing**: copies of invoices and payments count from their date. The default is at least 7 years, pending the legal review. Stripe keeps its own records in the Center's Stripe account.

Assistant text is always deleted after 30 days, whatever the Center sets. Analytics exports are deleted after 14 days.
