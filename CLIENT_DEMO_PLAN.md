# YULUK — Client Demo & Test Plan
**Date:** 2026-07-19  
**Purpose:** Live walkthrough of all platform features with client  
**Apps needed:** YULUK (customer) + YULUK Business (professional)  
**Devices:** Two phones — one for each app, or alternate on same device

---

## Before You Start

- [ ] Both apps installed and running
- [ ] Backend is reachable (test: open app, should not show "connection error")
- [ ] Have two email addresses ready (one for customer, one for professional)
- [ ] Clear app data / log out of both apps so you start fresh

---

## PART 1 — Customer Experience
*Use the YULUK (customer) app*

---

### Step 1 — Onboarding & Registration
**What we're testing:** First-time user experience

1. Open the YULUK customer app
2. Swipe through the onboarding screens
3. Tap **Get Started** → **Create Account**
4. Fill in: Name, Email, Password
5. Tap **Register**

**Expected:** Lands on the home screen with categories visible  
- [ ] Pass &nbsp;&nbsp; - [ ] Fail &nbsp;&nbsp; Notes: _______________

---

### Step 2 — Discover by Category
**What we're testing:** The 10 service categories

1. On the home screen, observe the category grid
2. Confirm all 10 categories are visible:
   - Men Grooming & Barber
   - Hair Styling
   - Braiding Specialists
   - Makeup Artists
   - Nail Technicians
   - Beauty Therapists
   - Massage Therapists *(new)*
   - Spas
   - Bridal Specialists *(new)*
   - Kids Hair Specialists *(new)*
3. Tap **Hair Styling**

**Expected:** Opens a list of hair styling professionals  
- [ ] Pass &nbsp;&nbsp; - [ ] Fail &nbsp;&nbsp; Notes: _______________

---

### Step 3 — Filter & Sort Professionals
**What we're testing:** Rating filter and sort options

1. Inside the Hair Styling listing, tap the **filter icon** (top right — sliders icon)
2. A bottom sheet appears with:
   - **Minimum Rating** slider — drag to 3.5
   - **Sort By** chips — tap "Top Rated"
3. Tap **Apply**

**Expected:** List refreshes showing only 3.5★+ professionals, sorted by rating. A red dot appears on the filter icon indicating active filters.  
- [ ] Pass &nbsp;&nbsp; - [ ] Fail &nbsp;&nbsp; Notes: _______________

---

### Step 4 — View a Professional's Profile
**What we're testing:** Rich professional profile

1. Tap any professional from the list
2. On their profile, verify you can see:
   - [ ] Profile photo / name / location
   - [ ] Star rating and review count
   - [ ] "Verified Professional" badge (if they have one)
   - [ ] Followers count
   - [ ] **Portfolio photos** strip (tap a photo to view fullscreen, swipe through)
   - [ ] **About** section with bio
   - [ ] **Years of experience** (e.g. "5 years of experience")
   - [ ] **Working Hours** — 7-day schedule showing open/closed times
   - [ ] **Services & Prices** in TZS
   - [ ] **Reviews** from past customers

**Expected:** All sections populated and scrollable  
- [ ] Pass &nbsp;&nbsp; - [ ] Fail &nbsp;&nbsp; Notes: _______________

---

### Step 5 — Follow a Professional
**What we're testing:** Follow system and activity feed

1. On the professional's profile, tap **Follow** (bottom right button)
2. A confirmation screen appears — tap confirm
3. Go back to home screen → tap **Following** tab
4. The professional should appear in the followed list

**Expected:** Follow works, professional appears in Following  
- [ ] Pass &nbsp;&nbsp; - [ ] Fail &nbsp;&nbsp; Notes: _______________

---

### Step 6 — Book an In-Studio Appointment
**What we're testing:** Standard booking flow

1. On the professional's profile, tap **Request / Book**
2. Choose **Book — At the salon**
3. On the booking screen:
   - [ ] Select a service from the dropdown (price shown in TZS)
   - [ ] Pick a date (tomorrow)
   - [ ] Pick a time (10:00 AM)
4. Tap **Confirm Booking**

**Expected:** "Appointment booked!" success message. Booking appears under My Bookings.  
- [ ] Pass &nbsp;&nbsp; - [ ] Fail &nbsp;&nbsp; Notes: _______________

---

### Step 7 — Request a Home Service (with Venue Type)
**What we're testing:** Home service request + venue type selection

1. Go back to the same professional's profile
2. Tap **Request / Book** → choose **Request — Home service**
3. On the booking screen:
   - [ ] Select a service
   - [ ] Pick a date and time
   - [ ] **Venue Type** dropdown appears — select **Home** (or Office/Hotel/Event)
   - [ ] Enter your address
   - [ ] Optionally tap **Use GPS** — GPS coordinates appear
4. Tap **Send Request**

**Expected:** "Home service request sent!" — booking created with venue type attached  
- [ ] Pass &nbsp;&nbsp; - [ ] Fail &nbsp;&nbsp; Notes: _______________

---

### Step 8 — View My Bookings
**What we're testing:** Customer booking management

1. Tap the **Bookings** tab at the bottom
2. See both bookings — the in-studio one and the home service request
3. Tap one to expand it

**Expected:** Both bookings visible with date, time, service name, status, price in TZS  
- [ ] Pass &nbsp;&nbsp; - [ ] Fail &nbsp;&nbsp; Notes: _______________

---

### Step 9 — Edit Customer Profile
**What we're testing:** Profile editing

1. Tap **Profile** tab → tap the **edit icon** (top right)
2. Change the name or phone number
3. Tap **Save**

**Expected:** Profile updates successfully  
- [ ] Pass &nbsp;&nbsp; - [ ] Fail &nbsp;&nbsp; Notes: _______________

---

## PART 2 — Professional / Business Experience
*Switch to the YULUK Business app*

---

### Step 10 — Professional Registration & Profile Setup
**What we're testing:** Onboarding as a beauty professional

1. Open YULUK Business app
2. Register with a **different email** than the customer
3. On the **Setup Profile** screen:
   - [ ] Enter business/professional name
   - [ ] Select category (e.g. "Hair Styling")
   - [ ] Write a bio
   - [ ] Enter **Years of Experience** (e.g. 7)
   - [ ] Enter price range (e.g. "TZS 15,000 – 50,000")
   - [ ] Pin your location on the map
4. Tap **Save & Continue**

**Expected:** Profile created, lands on the main business dashboard  
- [ ] Pass &nbsp;&nbsp; - [ ] Fail &nbsp;&nbsp; Notes: _______________

---

### Step 11 — Set Working Hours
**What we're testing:** Weekly availability configuration

1. Go to **Profile** tab → tap **Edit Profile**
2. Scroll down, tap **Manage Working Hours**
3. On the Working Hours screen:
   - [ ] Toggle days on/off (e.g. close Sunday)
   - [ ] For Monday–Saturday, set open time (8:00 AM) and close time (6:00 PM)
   - [ ] Toggle Sunday to **Closed**
4. Tap **Save** in the top right

**Expected:** Working hours saved. When a customer views this professional's profile (Part 1, Step 4), they'll see the 7-day schedule.  
- [ ] Pass &nbsp;&nbsp; - [ ] Fail &nbsp;&nbsp; Notes: _______________

---

### Step 12 — Build a Portfolio
**What we're testing:** Portfolio photo management

1. In **Profile** tab → scroll to **My Portfolio** → tap it
2. Tap the **add photo icon** (top right)
3. Pick a photo from the gallery
4. A dialog asks for a caption — type something like "Fresh blowout"
5. Photo uploads and appears in the grid
6. Upload 2–3 more photos
7. Long-press a photo → tap **Delete** to remove one

**Expected:** Photos upload successfully, grid updates, delete works. Photos appear on the professional's consumer profile.  
- [ ] Pass &nbsp;&nbsp; - [ ] Fail &nbsp;&nbsp; Notes: _______________

---

### Step 13 — Add Services & Pricing
**What we're testing:** Service catalogue

1. Tap the **Services** tab
2. Tap **Add Service**
3. Select a service type from the catalogue (e.g. "Haircut")
4. Set price in TZS (e.g. 25000)
5. Tap **Save**

**Expected:** Service appears in the services list with price  
- [ ] Pass &nbsp;&nbsp; - [ ] Fail &nbsp;&nbsp; Notes: _______________

---

### Step 14 — Manage Incoming Bookings (List View)
**What we're testing:** Booking acceptance flow

1. Tap the **Bookings** tab
2. The booking made in Step 6 and Step 7 should appear here (status: **PENDING**)
3. On the in-studio booking card:
   - [ ] Customer name and contact visible
   - [ ] Service, date, time, price in TZS
   - [ ] Tap **Accept** → confirm
4. On the home service request card:
   - [ ] Venue type chip visible (e.g. **Home** icon + label)
   - [ ] Customer address shown
   - [ ] Tap **Accept** → confirm

**Expected:** Both bookings move to CONFIRMED status  
- [ ] Pass &nbsp;&nbsp; - [ ] Fail &nbsp;&nbsp; Notes: _______________

---

### Step 15 — Calendar View
**What we're testing:** Calendar-based booking overview

1. Still on the **Bookings** screen, tap the **calendar icon** (top right)
2. View switches to a monthly calendar
3. Days with bookings show a green dot
4. Tap the day with bookings
5. The bookings for that day appear below the calendar

**Expected:** Calendar renders correctly, dots on booked days, tapping day shows bookings  
- [ ] Pass &nbsp;&nbsp; - [ ] Fail &nbsp;&nbsp; Notes: _______________

---

### Step 16 — Complete a Booking
**What we're testing:** End-to-end booking lifecycle

1. Switch back to list view (tap list icon)
2. On a CONFIRMED booking, tap **Mark Complete**
3. Confirm

**Expected:** Booking moves to COMPLETED. Revenue updates on the Dashboard.  
- [ ] Pass &nbsp;&nbsp; - [ ] Fail &nbsp;&nbsp; Notes: _______________

---

### Step 17 — Dashboard & Revenue Overview
**What we're testing:** Business analytics

1. Tap the **Dashboard** tab
2. Review:
   - [ ] Total bookings count
   - [ ] Pending / Confirmed / Completed counts
   - [ ] Total revenue in TZS
   - [ ] Completed bookings list

**Expected:** Numbers reflect the bookings created and completed during this session  
- [ ] Pass &nbsp;&nbsp; - [ ] Fail &nbsp;&nbsp; Notes: _______________

---

### Step 18 — Apply for Verified Badge
**What we're testing:** Professional verification request

1. Tap **Profile** tab
2. Below the profile photo, find **"Apply for Verified Badge"** button
3. Tap it → confirm

**Expected:** Status changes to "Verification pending review" (orange). When admin approves in backend, the blue verified badge will appear.  
- [ ] Pass &nbsp;&nbsp; - [ ] Fail &nbsp;&nbsp; Notes: _______________

---

## PART 3 — Cross-App Verification
*Confirm both apps are talking to the same backend*

---

### Step 19 — Customer Sees Accepted Booking
1. Switch back to **YULUK customer app**
2. Tap **Bookings** tab
3. The booking status should now show **CONFIRMED** (was PENDING before)

**Expected:** Status reflects the professional's acceptance in real time  
- [ ] Pass &nbsp;&nbsp; - [ ] Fail &nbsp;&nbsp; Notes: _______________

---

### Step 20 — Customer Leaves a Review
**What we're testing:** Review system

1. Find the **COMPLETED** booking in the customer app
2. Tap **Leave a Review**
3. Select 5 stars, write a comment
4. Submit

**Expected:** Review saved. Switch to business app → Profile → "My Reviews" shows the new review.  
- [ ] Pass &nbsp;&nbsp; - [ ] Fail &nbsp;&nbsp; Notes: _______________

---

## Summary Scorecard

| Area | Result |
|---|---|
| Customer registration & onboarding | ☐ Pass / ☐ Fail |
| Category discovery (10 categories) | ☐ Pass / ☐ Fail |
| Filter & sort | ☐ Pass / ☐ Fail |
| Professional profile (hours, experience, portfolio) | ☐ Pass / ☐ Fail |
| In-studio booking | ☐ Pass / ☐ Fail |
| Home service + venue type | ☐ Pass / ☐ Fail |
| Professional setup (experience, working hours) | ☐ Pass / ☐ Fail |
| Portfolio management | ☐ Pass / ☐ Fail |
| Booking management (accept, complete) | ☐ Pass / ☐ Fail |
| Calendar view | ☐ Pass / ☐ Fail |
| Dashboard & revenue | ☐ Pass / ☐ Fail |
| Verification badge request | ☐ Pass / ☐ Fail |
| Cross-app sync | ☐ Pass / ☐ Fail |
| Reviews | ☐ Pass / ☐ Fail |

---

## Known Limitations to Mention to Client

1. **Backend not yet deployed** — running on staging. Production deployment is the next step after sign-off today.
2. **Booking reminders** (24h and 1h email notifications) require the server scheduler to be running — will be active post-deployment.
3. **Verified badge** requires manual admin approval on the backend — the client/admin needs a way to approve these (future admin panel feature or direct DB update for now).
4. **Portfolio reorder** — drag-to-reorder UI is not yet built; order is set by upload sequence.

---

## Post-Demo Decision Points

- [ ] Client sign-off on all features?
- [ ] Any changes needed before production deployment?
- [ ] Agree on deployment date
- [ ] Confirm admin process for approving verified badges
- [ ] Agree on go-live communication plan
