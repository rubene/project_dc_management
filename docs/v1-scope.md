# V1 scope

What the first release of DC Management includes, and what it leaves for later. See `GLOSSARY.md` for terms and `docs/adr/` for the reasoning behind the hard-to-reverse decisions.

## Who it's for

- **Customers:** independent Centers with about 30–150 children, in the US and Canada, excluding Quebec for now.
- **Why they'd switch:** a lower price, a better daily experience for Staff and Guardians than existing apps, and an Assistant that lets Staff log their day by voice while their hands are full.
- **Quality bar:** Staff stay logged in, can add many photos easily, and can use the app while managing children.

## Pricing

- Organizations pay one monthly price per enrolled child, with a monthly minimum and a free trial that doesn't need a card.
- The plan includes every feature, and the subscription is paid by card in v1.
- DC Management takes no fee on the payments families make to their Center.

## In v1

### Setup

- An Admin imports children and Guardians from a CSV, sets up Rooms and Tuition Plans, connects Stripe, and invites everyone.
- An Admin creates each Enrollment directly and chooses the date new billing starts.

### Roles and access

- Each person has one login, with Roles assigned per Organization or Center.
- An Owner manages the subscription and appoints Admins across the Organization's Centers.
- An Admin controls one Center and can do anything Staff can do there, including on a shared tablet. An Admin can't see other Centers' data or give consent for a family.
- Shared tablets stay logged in to the Center, and each person uses a personal PIN to act. Personal phones stay logged in and unlock with Face ID or a fingerprint.
- An Admin can immediately remove a lost device or a departed person's access.

### Sign-in/out and Attendance

- Only Staff and Admins record Sign-in/out, showing who handed the child over or collected them and who recorded it.
- Guardians are notified right away.
- Late entries use the actual time, and corrections keep a reason and history.
- Missed sign-outs stay open and are flagged to an Admin at closing, never closed automatically.
- Staff shouldn't record Sign-in/out for their own child if another Staff member is available.
- During an outage, Centers use a printed roster and paper sheet, then enter the actual times later.

### Pickups and Guardians

- Staff check ID the first time a regular Authorized Pickup collects a child, and see a photo on file after that.
- A One-Time Authorized Pickup needs a single-use PIN from a Guardian and a manual ID check, and the app doesn't store a copy of the ID.
- If there's a mismatch, Staff don't release the child and they contact a Guardian and an Admin.
- Only Admins change who's a Guardian or apply restrictions, with a reason and history kept.
- Pickup Restrictions and Records Restrictions are separate, because court orders vary.
- A Records Restriction hides everything about the child from that Guardian, including Child Updates, photos, Conversations and Attendance. If they're the Payer, they still see their own invoices.
- Guardians manage Authorized Pickups and Emergency Contacts, within those restrictions.

### Rooms and Ratios

- Each child has a Main Room, and their current Room follows Room Transfers.
- Staff and Admins record when they enter and leave a Room, and anyone recorded as present counts toward its Ratio.
- Each Room has one Ratio, entered by the Center.
- Being out of Ratio alerts Staff and Admins, but never blocks anything.

### Communication

- V1 includes Announcements, Conversations and Child Updates.
- Each child has one Conversation shared with all their Guardians, and a Guardian can start a private one with the Center.
- Admins can read every Conversation, Staff in the child's Room can reply to shared ones, and private ones go to Admins by default.
- A Guardian whose records access is restricted is left out of the shared Conversation.
- Staff can upload a batch of photos in the background and tag children on each photo or across the batch.
- A photo tagged with a child who has no Photo Consent isn't shared, and Staff see a warning. Guardians don't wait on Admin approval, and an Admin can remove a shared photo.
- Notifications use push, with email as the backup and no SMS. Child Updates are bundled into one alert. Sign-in/out, urgent Announcements and failed payments notify right away.

### Billing

- Each Center sets its own Tuition Plans, billing frequency (weekly, every two weeks or monthly), discounts and late-fee rules.
- Admins can override a child's price and edit suggested proration.
- Tuition is owed whether or not the child attends.
- Late-fee rules only suggest a Charge, and an Admin approves it.
- Each child has one Payer, and each invoice belongs to a Payer so splits can be added later.
- Families pay by bank debit by default, or by card. Each Center chooses whether it or the family pays card fees, subject to legal review.
- Autopay is opt-in. A failed payment retries and notifies the Payer and an Admin, and the app never automatically blocks a child's care.
- Admins see amounts, payment status, card brand and last four digits. Full card and bank numbers stay in Stripe.
- Payers can download their payment history.

### Reports and data

- V1 licensing reports are Attendance and the Sign-in/out log, showing who recorded each entry and any corrections.
- The Center controls its records and sets their retention period.
- Former Guardians get a limited window to download their child's photos.
- A cancelling Center gets a time-limited full export before deletion.

### Assistant

- **Who uses it for what:**
  - Staff use the Assistant by voice or chat for Child Updates, Sign-in/out and Room Transfers.
  - Guardians and Admins use it to ask questions, which only read data.
- **Where it appears:**
  - Staff get push-to-talk and chat on every screen of the mobile app.
  - Guardians get chat in the mobile app.
  - Admins get a chat panel in the web app.
- **Proposed Actions:**
  - Every change the Assistant prepares is a Proposed Action, carried out only when the person confirms it. Questions need no confirmation.
  - One request can create several Proposed Actions, confirmed with one tap.
  - Safety-critical actions such as Sign-in/out are each confirmed on their own, and are never included in "confirm all".
  - Actions are recorded as the person's own, marked as done through the Assistant.
- **When it's unsure:** the Assistant never guesses. It asks one short question, favoring children in the speaker's current Room. If it still can't tell, it opens the normal screen with what it understood filled in.
- **Permissions:** the Assistant has exactly the person's permissions, and every rule still applies, including restrictions and PIN and ID checks.
- **Voice:**
  - Voice capture works only while a button is held. There's no always-on listening.
  - Speech becomes text on the phone, and the audio is never kept.
  - The Assistant understands English and Spanish, and answers in the language used. The screens stay English-only.
- **What it keeps and sees:**
  - Request and reply text is kept for 30 days, then deleted.
  - The model sees only what the API returns for that person, never photos.
  - Anything people wrote is treated as information, never as instructions.
- **Cost to Centers:** the Assistant is included in the plan, with a monthly fair-use limit per Center that's set after measuring pilot usage.

## Later

- **Features:** waitlist and online applications, staff scheduling, curriculum and lesson planning, child portfolios, advanced reporting and analytics.
- **Billing:** tuition split between Payers, year-end statements, filing subsidy claims (v1 records subsidies as a manual credit), and bank debit for subscriptions.
- **Product:** offline use, Admin tools in the app, and Quebec.
- **Assistant:** the remaining actions through the Assistant, voice for Guardians and Admins, and French.

Payroll and time cards aren't planned.

## Technical decisions

- **Apps:** Flutter for the mobile and web apps, with the web app on S3 and CloudFront.
- **Marketing site:** a separate Astro static site on S3 and CloudFront.
- **Backend:** TypeScript on Lambda and Step Functions, with EventBridge where needed.
- **API:** REST on API Gateway, with an OpenAPI definition that generates the Flutter client. V1 uses push notifications and polling, not WebSockets.
- **Data:** one main DynamoDB table with the Center in each record's key, access checks on every request, and append-only history for corrected records. List every v1 query before designing the schema. A daily DynamoDB export to S3 is kept for 14 days and queried with Athena.
- **Login:** Cognito handles login only, and Roles live in DynamoDB. MFA with an authenticator app is optional for everyone.
- **Files:** all S3 buckets block public access. People view files only through CloudFront, using short-lived signed links for child photos. Uploads use short-lived signed links, and internal buckets are available only to backend services.
- **Stripe:** DC Management holds the prices and rules, and keeps one Stripe subscription per Payer in each Center's Stripe account in step with them (ADR 0011). Stripe Billing creates the invoices and handles collection, autopay, receipts and retries. A retried change must never charge a family twice.
- **Infrastructure:** CDK in TypeScript, in `us-west-2`. Only a dev account exists until v1 is code complete, but the CDK must support staging and production.
- **Test data:** the dev account only ever holds made-up data, and any pilot with a real Center waits for production.
- **Assistant:**
  - Claude runs through Amazon Bedrock on a US cross-region inference profile.
  - Claude Opus 5.5 is used during development. A switch to Claude Haiku 5.5 happens only if it matches Opus on the Assistant's test set.
  - Speech is transcribed on the phone, with Amazon Transcribe as the fallback if testing shows it isn't accurate enough.
  - API tests use a fake model. A test set of realistic requests runs against the real model before each release, covering English and Spanish, noisy transcripts, duplicate names and injection attempts.
- **Documentation:** a short `README.md`, `docs/architecture.md` and `docs/runbook.md`, updated in the same PR as the code they describe.

## Still to do before launch

- Set the per-child price after modeling costs, including Stripe, email, photo storage and support.
- Get a legal review of privacy and children's data in both countries, storing Canadian data in the US, default retention periods, deletion requests, and passing card fees to families.
- Confirm the PCI requirements that apply.
- Plan a pilot Center.
- Include the Assistant in the legal review, including Bedrock's data terms, and set its fair-use limit from pilot usage.
- Confirm access to Claude on Bedrock with one test request, and test on-device speech on the phones Staff actually use.
- Add more detail on current app frustrations from the project owner and a working educator.
