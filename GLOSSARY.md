# DC Management

A daycare management SaaS covering a daycare's daily operations, its communication with families, and its billing.

## Language

### Customers

**Organization**:
The business that subscribes to DC Management and owns one or more Centers.
_Avoid_: Tenant, account, company

**Center**:
A single daycare location, and the merchant that families pay.
_Avoid_: Daycare, site, school, location

### People

**Role**:
The capacity in which a person acts at an Organization or Center. One person can hold several Roles at once.
_Avoid_: User type, account type

**Owner**:
A person who holds an Organization's subscription and appoints the Admins of its Centers.

**Admin**:
A person who runs a single Center's operations, such as a center director or office manager, and who may also do anything Staff can do there.
_Avoid_: Manager

**Staff**:
A person who cares for and educates children at a Center, such as a room educator or floater.
_Avoid_: Teacher, employee

**Guardian**:
An adult with legal responsibility for a child.
_Avoid_: Parent, Parent/Guardian

**Authorized Pickup**:
A person permitted to collect a specific child from a Center.
_Avoid_: Approved adult, pickup person

**One-Time Authorized Pickup**:
An Authorized Pickup whose permission covers a single pickup only.

**Emergency Contact**:
A person to call about a specific child in an emergency.

**Pickup Restriction**:
A bar on a specific person collecting a specific child, applied by an Admin.

**Records Restriction**:
A bar, applied by an Admin, on a Guardian seeing anything about a specific child other than invoices they're the Payer for.

### Daily operations

**Room**:
A group of children and the space they're cared for in at a Center, such as Toddlers or Preschool.
_Avoid_: Classroom, class

**Main Room**:
The Room a child normally belongs to, whichever Room they're in at the moment.
_Avoid_: Home room

**Ratio**:
The number of children allowed per Staff member in a Room, as entered by the Center.

**Sign-in/out**:
The record, made by Staff or an Admin, of who handed a child over to or collected a child from a Center, and when.
_Avoid_: Check-in/out

**Room Transfer**:
The record of a child moving from one room to another during the day.

**Attendance**:
A child's presence at a Center on a given day, as established by their Sign-in/out records.

### Billing

**Enrollment**:
A child's place at a Center, including the days they're expected to attend.

**Tuition Plan**:
The recurring price a Center sets for an Enrollment, owed whether or not the child attends.
_Avoid_: Subscription

**Charge**:
A one-off amount a Center bills in addition to tuition, such as a late-pickup fee.
_Avoid_: Fee, add-on

**Payer**:
A person responsible for paying all or a share of a child's tuition and Charges.
_Avoid_: Customer, bill payer

### Communication

**Announcement**:
A message from a Center to everyone at the Center or in a room.
_Avoid_: Broadcast, notice

**Conversation**:
A private thread about a child between the Center and either all of the child's Guardians or one Guardian.
_Avoid_: Chat, direct message

**Child Update**:
A record of something in a child's day, such as a nap, meal, diaper change or photo, shared with their Guardians.
_Avoid_: Daily report, activity

**Photo Consent**:
A Guardian's permission for photos showing their child to be shared with other children's Guardians.

### Assistant

**Assistant**:
The chat and voice interface through which a person asks questions or requests actions in plain language.
_Avoid_: Bot, chatbot, AI, agent

**Proposed Action**:
An action the Assistant has prepared from a request, which is carried out only once the person confirms it.
_Avoid_: Suggestion, draft
