# BAG BUDDY — The Complete Reference

---

## OVERVIEW

Bag Buddy is a hands-free heavy bag training app for iOS. It calls out boxing and Muay Thai combinations via audio so fighters can train with structure, variety, and intensity — without looking at their phone. Built by Rafe Tangorra, a fighter and software engineer who needed the tool and couldn't find it.

**App Store Name:** The Bag Buddy
**Bundle ID:** com.rafetangorra.bagbuddy
**Apple ID:** 6762319334
**SKU:** bagbuddy-001
**Price:** Free (forever for v1)
**Platform:** iOS 17+
**Status:** Live on the App Store as of April 2026

---

## LINKS

- **App Store:** https://apps.apple.com/us/app/the-bag-buddy/id6762319334
- **Website:** https://rafetangorra-tech.github.io/BagBuddy/
- **Investor Deck:** https://rafetangorra-tech.github.io/BagBuddy/deck.html
- **Privacy Policy:** https://rafetangorra-tech.github.io/BagBuddy/privacy-policy.html
- **GitHub Repo:** https://github.com/rafetangorra-tech/BagBuddy (public)

---

## BRAND IDENTITY

### Tagline
BEEN HIT. STILL GRINNING.

### Hero Line
TRAIN LIKE YOU FIGHT.

### Voice & Tone
- Coach talk. Short, commanding, second person ("you"), present tense.
- Near-imperatives without the bark — more "that's the work. now recover." than "DO 20 PUSHUPS!!!"
- Blunt about what it expects. Dry about how hard it is.
- No exclamation points. The app doesn't yell; it commands.
- No emojis in UI (except fire on streak banner and boxing glove in share text).

### Casing Rules
- Display/headline: ALL CAPS with wide letter-spacing (2-3px)
- Body copy: sentence case
- Never title case
- Combo codes: BN-04, BD-08 — hyphenated, caps, Oswald Medium

### Colors
- **Accent Red:** #E43945 (app) / #E03030 (website) — one brand color, used for active states, CTAs, combo codes, the mascot
- **App (light):** #FFFFFF background, #FAFAFA surface, #EEEEEE borders, #111111 text primary, #999999 text secondary
- **Website (dark):** #0A0A0A background, #141414 cards, #222222 borders, #FFFFFF text, #888888 dim text
- **One-red rule:** no other hues. No green, amber, or blue.

### Typography
- **Display:** Oswald (Medium 500, SemiBold 600) — condensed, fight-poster style
- **UI/Body:** SF Pro (app) / Inter (web)
- **Monospace:** SF Mono for live timers

### Logo / Mascot
- Red punching bag with X-eyes, slack grin, and mouthguard — "dazed face"
- Hanging from a chain
- Used at all sizes: 36pt in nav, 72pt on home screen, 580pt on website hero
- Never recolor, never invert

---

## THE APP

### Disciplines
1. **Boxing** — numbered punch system (1=jab, 2=cross, 3=lead hook, 4=rear hook, 5=lead uppercut, 6=rear uppercut)
2. **Muay Thai** — punches + low kicks, body kicks, knees, elbows, teeps, checks

### Training Modes
1. **Stand and Bang** — Pure offense. Back-to-back strike combinations called out loud. No defense.
2. **Stick and Move** — Combos with defensive moves included (slips, rolls, pivots, checks). Boxing version also mixes in short offensive "breaker" combos.
3. **Drillers Make Killers** — One complex combination drilled for 60 seconds. Audio replays at configurable intervals. Screen-only display for drill combos.

### Combo Library
- **Total:** 149 combinations
- **Boxing offense (BN):** 22 combos
- **Boxing defense (BD):** 21 combos
- **Boxing drill (BX):** 22 combos
- **Muay Thai offense (MN):** 34 combos
- **Muay Thai defense (MD):** 22 combos
- **Muay Thai drill (MX):** 28 combos
- All offense and defense combos have recorded audio callouts
- Drill combos display on screen only (no audio)

### Audio System
- **Combo callouts:** 108 hand-recorded MP3s by the founder (Rafe's voice)
- **Coach cues:** 6 motivational audio drops (HandsUp, KeepThePressureOn, MakeItCount, PushThrough, StayBusy, WatchYourGuard) — fire 1-in-10 between combos
- **SFX:** Round Start bell, Round End bell, Warning bell
- **Background music:** Optional looping ambient gym track
- **Music integration:** .mixWithOthers + .duckOthers — Spotify/Apple Music keeps playing, ducks during callouts, restores between
- **Volume:** All audio normalized to -0.5dB peak via ffmpeg. Coach cues play at 0.55 volume.
- **First combo delay:** 1.5 second pause-aware delay after round bell before first combo

### Timing Engine
Combo pacing is calculated, not random:
- **Processing buffer:** 300ms (auditory decoding + motor planning)
- **Per strike:** 350ms execution time
- **Per kick/knee (MT):** 450ms (100ms surcharge for body displacement)
- **Per defense move:** 500ms (weight transfer + reset)
- **Pacing multiplier:** Relaxed 1.3x / Normal 1.0x / Push 0.8x
- **Fatigue multiplier:** 1.0x first half of round, 1.2x second half
- **Random jitter:** ±15% to prevent rhythm anticipation

### Combo Repeats
- 1-in-7 chance after any combo to repeat the same combination (coach emphasis style)

### Settings
- Rounds: 1-12
- Round duration: 30s - 10min (step 30s)
- Rest duration: 15s - 5min (step 15s)
- Drill duration: 30s - 2min (step 15s)
- Drill replay interval: 10s - 30s (step 5s)
- Combo pacing: Relaxed / Normal / Push
- Warning bell: OFF / 10s / 15s / 30s before round end
- Background music: on/off
- Haptics: on/off
- Daily notifications: on/off

### Haptics
- Round start: heavy impact
- Round end: medium impact
- Warning bell: notification feedback
- Countdown tick: light impact
- Combo delivered: light impact (0.5 intensity)

### Apple Health / WHOOP
- Writes workout summaries to HealthKit (activity type, duration, estimated calories)
- Calorie estimate: ~10 cal/min boxing, ~11 cal/min Muay Thai
- WHOOP syncs automatically via Apple Health — no extra setup

### Session History
- Stored locally via UserDefaults (JSON encoded)
- Records: date, discipline, mode, rounds, round duration, rest duration, combos delivered
- Streak tracking: consecutive calendar days with at least one session
- Streak banner displayed at top of History tab

### Push Notifications
- 11 coach-voice messages rotating daily at 5 PM
- Scheduled 60 days out via local notifications
- Messages include: "Your hands are getting slow. Fix it." / "Stop thinking. Start punching." / "The bag doesn't hit back. What's your excuse?" / etc.

### Onboarding
- Shows on first launch only (hasSeenOnboarding flag in UserDefaults)
- 3 slides: Stand and Bang, Stick and Move, Drillers Make Killers
- Optional 4th slide: Apple Health + WHOOP
- X button to dismiss, NEXT/LET'S GO navigation
- Info button on home screen reopens onboarding as fullScreenCover

### Session Flow
1. Logo animation plays (mp4, muted, crossfades out)
2. Onboarding (first launch only)
3. Home screen: select discipline, mode, view session summary
4. Tap START SESSION → logo animation plays again → session starts
5. 3-2-1 countdown (silent, haptic only)
6. Round bell → 1.5s delay → combos called
7. Warning bell at configured time before round end
8. Round end bell → rest period (if not final round)
9. Repeat rounds
10. Complete screen: stats, closing line, share button, done button
11. Workout saved to history + HealthKit

### Technical Architecture
- **SwiftUI** single-app target, iOS 17+
- **State machine:** idle → countdown → round → rest → complete
- **RoundTimerEngine:** @MainActor, manages session loop with pause-aware sleep
- **TimingEngine:** calculates combo gap delays
- **AudioEngine:** @MainActor singleton, AVAudioPlayer for combos/SFX/coach, AVAudioSession with .mixWithOthers + .duckOthers
- **SessionViewModel:** @Published state, UserDefaults persistence, combo pool management
- **ComboService:** loads combos.json, filters by discipline/mode/audio availability
- **Watchdog timeouts:** on playCombo and playCoachLine to prevent deadlocks
- **Task group cleanup:** skipCombo + stopCoachLine called before group.cancelAll()

### Known Issues (Fixed)
- Session freeze: caused by CheckedContinuation never resolving when task cancelled. Fixed with explicit skipCombo/stopCoachLine before group.cancelAll, in stop(), and in deactivateSession().
- Data race on onNeedNextCombo: combo fetch now inside MainActor.run block.
- Music pause on launch: AudioEngine now initializes eagerly in BagBuddyApp.init() before AVPlayer.
- SFX not playing on device: playRoundEnd and playCountdownBeep used local AVAudioPlayer variables that were deallocated. Fixed by assigning to self.

---

## BUSINESS MODEL

### V1 (Current) — Free
- All 149 combos, all 3 modes
- Full round timer, history, streaks
- Coach voice, audio cues
- Apple Health integration
- No ads, no subscription, no tracking

### V2 (Planned) — Premium Tier
- Custom workout presets (save/load named configs)
- Combo blocking/favorites
- Performance analytics & charts
- Apple Watch companion app
- iCloud sync
- Additional disciplines

### Fighter Signature Packs (Revenue Unlock)
- Partner with professional fighters and celebrity boxing coaches
- Release curated combo packs — their favorite combinations, recorded in their voice
- In-app purchase model (~$4.99 per pack)
- Revenue share with the fighter/coach
- Each fighter brings their own audience to the app
- Low production cost (audio files + combo data), ships without app updates
- Scalable content pipeline — new packs grow the roster indefinitely

### Investment Thesis
- **Raising:** $750K SAFE, post-money cap $6M, 18-month runway
- **Allocation:** 45% engineering ($340K), 30% community/growth ($225K), 15% coach voice studio ($115K), 10% ops/reserve ($70K)
- **Vision:** Bag Buddy is to boxing what Strava is to running

---

## MARKET OPPORTUNITY

- **At-home boxing market:** $2.1B projected by 2028
- **U.S. boxing/kickboxing participants:** 36M+ Americans
- **Boxing participation growth:** +61% since 2017 (SFIA 2024)
- **AirPods owners (US):** 38M — voice-only UX has a distribution channel
- **Global fitness app market:** $220B projected 2026
- **Heavy bags:** #1 selling combat sports equipment globally
- **78% of heavy bag owners train at home without a coach**

### Competitive Landscape
- **Timer apps** (most boxing apps): count down rounds, nothing else. No intelligence.
- **FightCamp:** $1,350 hardware + subscription. Not hands-free.
- **Boxtastic / Shadow Boxing App:** some audio combos, no Muay Thai, paid.
- **Bag Buddy:** Free, hands-free, fight-specific, no hardware required. Only app that calls combos out loud with proper pacing across both boxing and Muay Thai.

---

## TRACTION (as of April 2026)

- **Status:** Live on App Store
- **Downloads:** Organic, zero paid acquisition
- **Audio assets:** 108 hand-recorded callouts + 6 coach cues
- **Funding to date:** $0 — fully bootstrapped

---

## MARKETING

### App Store Listing
- **Name:** The Bag Buddy
- **Subtitle:** Heavy Bag Training & Coach
- **Category:** Health & Fitness (primary), Sports (secondary)
- **Age Rating:** 4+
- **Keywords:** boxing,bag work,heavy bag,muay thai,combo trainer,boxing timer,round timer,fight training,workout (99 chars)
- **Promotional Text:** Boxing and Muay Thai combos called out loud. Hands-free. No timers to watch. Just you and the bag. Coach-voice cues, full round timer, Apple Health integration.

### App Store Description
```
TRAIN LIKE YOU FIGHT.

Bag Buddy is the no-nonsense heavy bag training app built for boxers and Muay Thai fighters who want real coaching, not just a timer.

The app calls out combinations out loud - hands-free, eyes up, 100% focused on the bag. No staring at your phone. No guessing what to throw next. Just work.

HOW IT WORKS
Choose your discipline (Boxing or Muay Thai), set your rounds, pick your mode, and go. Bag Buddy handles the rest - timing your rounds, calling your combinations, and pushing you to keep moving forward.

MODES
- Stand and Bang - Pure offense. Back-to-back strike combos, no defense.
- Stick and Move - Defensive boxing. Combos include slips, rolls, and pivots.
- Drill Mode - Lock in on one combination at a time and drill it to muscle memory.

FEATURES
- Spoken combo callouts - crisp, clear audio so you stay locked in
- Configurable rounds: 1-12 rounds, 30s to 10min each
- Rest timers with warning bell before round end
- Combo pacing: Slow / Normal / Fast
- Background music support
- Round haptics - feel the bell
- Apple Health integration - every session logged as a boxing workout, syncs to WHOOP automatically
- Session history - track your rounds, combos, and calories over time
- Daily training reminders from your coach (5 PM, every day)

BUILT FOR FIGHTERS
Bag Buddy was built by a fighter, for fighters. No subscription. No gamification. No fluff. Just you, the bag, and the work. Spread the word and tell your teammates about us!

"My back is broken. Spinal. Yours isn't so use Bag Buddy."
```

### Website
- Dark theme (#0A0A0A background, white text, red accent)
- Sections: Nav, Hero (two-column with mascot), Features (6 cards), Modes (3 cards), Screenshots (tilted phones), Pricing ($0 card), Testimonials (3 quotes), FAQ (4 items), Final CTA, Footer
- Oswald font loaded locally from TTF files
- Proper Apple-style App Store download buttons
- Responsive breakpoints for mobile
- Hosted via GitHub Pages from /docs folder

### Investor Deck
- 14-slide full-screen navigable presentation
- Custom <deck-stage> web component with keyboard/touch navigation
- Slides: Title, Hook, Problem, Why Now, Insight, Product, Modes, Manifesto, Market (TAM/SAM/SOM), Traction, Business Model, Competitive (2D axis plot), Team, The Ask
- Exportable to PDF via Cmd+P
- Dark theme matching the brand

### Instagram Strategy

#### Account Setup
**Bio:**
```
Bag Buddy
Your coach. Your bag. Your work.
149 combos called out loud.
Boxing | Muay Thai | Free
Link below
```

**Link in bio:** https://rafetangorra-tech.github.io/BagBuddy/

#### Instagram Carousels (5 complete sets, 33 slides total)

**Carousel 1 — Main Product Intro** (8 slides, dark theme)
- 01_hook: Logo + "Train Like You Fight" + swipe
- 02_problem: "Tired of throwing the same 3 punches?"
- 03_solution: "Meet Bag Buddy" + session screenshot
- 04_modes: Three training modes in cards
- 05_features: 6 features with red dot bullets
- 06_music: "Play Your Music. We'll Call The Combos."
- 07_price: "$0 Free. Forever."
- 08_cta: Logo + "Download Now"

**Carousel 2 — Them vs. Us** (6 slides, dark theme)
- 09_vs_hook: Logo + "Them VS. Us"
- 10_vs_1: Them: "Count down rounds" / Us: "Calls out 149 combos"
- 11_vs_2: Them: "Stare at your phone" / Us: "Audio callouts, eyes on the bag"
- 12_vs_3: Them: "Pause your music" / Us: "Ducks Spotify automatically"
- 13_vs_4: Them: "$10/month for a timer" / Us: "Free. Forever."
- 14_vs_cta: "Train Like You Fight" + Download

**Carousel 3 — Hidden Features** (8 slides, dark theme)
- 15_feat_hook: "6 Things You Didn't Know Bag Buddy Could Do"
- 16_feat_1: Play your own music (Spotify/Apple Music ducks)
- 17_feat_2: Background gym noise (built-in ambient loop)
- 18_feat_3: Feel the bell (haptic feedback on every cue)
- 19_feat_4: Customize your warning (OFF, 10s, 15s, 30s)
- 20_feat_5: Syncs to WHOOP (via Apple Health)
- 21_feat_6: Daily coach check-in (5 PM reminders)
- 22_feat_cta: "Now You Know" + Download

**Carousel 4 — Why Stand and Bang Matters** (5 slides, white theme, Oswald font)
- 23_sab_hook: Logo + "Why Stand and Bang Matters"
- 24_sab_problem: "Most people hit the bag the same way every time"
- 25_sab_what: "Pure Offense. Zero Defense." + combo counts
- 26_sab_science: 4 benefits (pattern breaking, motor recruitment, cardio, fight IQ)
- 27_sab_cta: "Stop Going Through The Motions"

**Carousel 5 — The Science Behind The Pace** (6 slides, white theme, Oswald font)
- 28_pace_hook: "The Science Behind The Pace"
- 29_pace_problem: "Random timing doesn't work"
- 30_pace_formula: 300ms processing, 350ms/strike, 450ms/kick, 500ms/defense
- 31_pace_adaptive: Fatigue multiplier + random jitter
- 32_pace_presets: Relaxed 1.3x / Normal 1.0x / Push 0.8x
- 33_pace_cta: "Engineered To Train You Right"

All slides: 1080x1350 (4:5 portrait, Instagram optimal)
Location: /Users/tangorra/BagBuddy/marketing/instagram/

#### First Post Caption
```
It's here.

Bag Buddy — the heavy bag coaching app that calls out combinations out loud so you can stop staring at your phone and start training for real.

Boxing. Muay Thai. 149 combinations. 3 training modes. Coach audio. Round timer. Apple Health. Streak tracking.

All of it. Free. No subscription. No ads. Ever.

I built this because I needed it. No app on the market actually tells you WHAT to throw. They just count down rounds and call it a day. That's a stopwatch, not a coach.

Bag Buddy is the coach.

Download it. Start a round. Hit the bag.

Link in bio.

#BagBuddy #Boxing #MuayThai #HeavyBag #BoxingTraining #MuayThaiTraining #BagWork #ComboTraining #FightTraining #BoxingApp #TrainLikeYouFight #HeavyBagWorkout #BoxingLife #FighterLife #MartialArts #HomeGym #GarageGym #BoxingCoach #NoExcuses #PutInTheWork #FreeApp #AppStore #FitnessApp #CombatSports #StrikeTraining
```

---

## ROADMAP

### V1.0 (Shipped — April 2026)
- Boxing + Muay Thai
- 149 combinations with recorded audio
- 3 training modes
- Full round timer with configurable settings
- Coach audio drops
- Music ducking (Spotify/Apple Music)
- Haptic feedback
- Apple Health + WHOOP sync
- Session history + streak tracking
- Daily push notifications
- Onboarding slideshow

### V1.5 (Planned)
- Workout presets (save/load named configs)
- Combo blocking/favorites (long-press to remove from pool)
- History charts (sessions per week, combos over time)
- iCloud sync

### V2.0 (Planned — Premium)
- Subscription tier ($8/mo)
- Apple Watch companion app
- Custom combo builder
- Coach voice marketplace (licensed pro fighters)
- Structured 6-week fight camps
- Advanced analytics (round-by-round heat map)
- Fighter Signature Packs (in-app purchase)

### 2027+
- Android launch
- Gym/trainer B2B partnerships (licensed class mode)
- Social sharing and leaderboards
- Additional martial arts disciplines

---

## FILE STRUCTURE

### App Source
```
BagBuddy/
├── BagBuddyApp.swift              # Entry point, eagerly inits AudioEngine
├── Models/
│   ├── Combo.swift                 # Discipline, WorkoutMode, PacingPreset, Combo, ComboSegment
│   ├── RoundConfiguration.swift    # WorkoutConfiguration struct
│   ├── WorkoutRecord.swift         # Session history record
│   └── WorkoutPreset.swift         # Saved preset model (v1.5)
├── Data/
│   ├── ComboLibrary.swift          # ComboService — loads/filters combos.json
│   ├── HistoryStore.swift          # UserDefaults persistence + streak calculation
│   └── PresetStore.swift           # Preset persistence (v1.5)
├── Engines/
│   ├── AudioEngine.swift           # AVAudioPlayer, coach lines, music ducking
│   ├── RoundTimerEngine.swift      # Session state machine, combo delivery
│   ├── TimingEngine.swift          # Pacing formula calculation
│   ├── HapticsEngine.swift         # UIImpactFeedbackGenerator
│   ├── HealthKitManager.swift      # HKWorkoutBuilder
│   └── NotificationManager.swift   # Local daily notifications
├── Views/
│   ├── RootView.swift              # Main state switch + logo animation + onboarding
│   ├── HomeView.swift              # Discipline/mode selection, start button
│   ├── SessionView.swift           # Active workout display + controls
│   ├── CountdownView.swift         # 3-2-1 countdown
│   ├── RestView.swift              # Rest between rounds
│   ├── CompleteView.swift          # Session complete + stats + share
│   ├── SettingsView.swift          # All configuration options
│   ├── HistoryView.swift           # Session records + streak banner
│   ├── OnboardingView.swift        # Tutorial slideshow
│   └── LogoAnimationView.swift     # AVPlayer video bridge
├── Resources/
│   ├── combos.json                 # All 149 combo definitions
│   └── logoanimation.mp4           # Launch animation video
├── Audio/
│   ├── Callouts/                   # 108 combo MP3s (BN, BD, MN, MD series)
│   ├── CoachCues/                  # 6 motivational MP3s
│   └── SFX/                        # Round Start, Round End, Warning, BGLoop
├── Fonts/
│   ├── Oswald-SemiBold.ttf
│   └── Oswald-Medium.ttf
├── Assets.xcassets/
│   ├── AppIcon.appiconset/Icon.png
│   └── BagBuddyLogo.imageset/Logo.png
├── Info.plist
└── BagBuddy.entitlements
```

### Marketing / Web
```
docs/                               # GitHub Pages root
├── index.html                      # Marketing website
├── deck.html                       # Investor deck (14 slides)
├── deck-stage.js                   # Deck navigation web component
├── privacy-policy.html             # Privacy policy
├── fonts/                          # Oswald TTFs for web
└── images/                         # Screenshots, logo, icon

marketing/
└── instagram/                      # 33 carousel slides (1080x1350 PNG)
    ├── 01-08_*.png                 # Carousel 1: Product intro
    ├── 09-14_*.png                 # Carousel 2: Them vs Us
    ├── 15-22_*.png                 # Carousel 3: Hidden features
    ├── 23-27_*.png                 # Carousel 4: Stand and Bang
    └── 28-33_*.png                 # Carousel 5: Pacing science
```

---

## FOUNDER

**Rafe Tangorra** (Raphael Tangorra)
- Fighter and software engineer
- Records all audio callouts himself
- Built and shipped v1 solo
- Apple Developer: rafetangorra@gmail.com
- GitHub: rafetangorra-tech
- Contact: rafe@bagbuddyapp.com

---

*Last updated: April 2026*
