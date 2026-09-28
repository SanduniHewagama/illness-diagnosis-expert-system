# Illness Diagnosis Expert System (SWI-Prolog)

CM3321 - Logic Programming and Artificial Cognitive Systems - Assignment 2

An expert system that suggests **possible** conditions - Influenza (Flu), Common Cold,
Allergy, COVID-19-like illness and Migraine - from symptoms reported by the user.
It uses 21 IF-THEN rules taken from published sources (CDC, Mayo Clinic, NIH chart,
a public-health chart). For every conclusion it prints the rule that fired, the matched
symptoms, the reasoning and the source (with URL).

> Educational project only. It is **not** a medical diagnosis.

## 1. What you need

* **SWI-Prolog** (free) - https://www.swi-prolog.org/download/stable
  (tested with SWI-Prolog 9.0.4; any recent 9.x / 10.x version should work)
* Nothing else: no libraries, no internet connection.

## 2. Files

| File | Purpose |
|------|---------|
| `diagnosis.pl` | The whole expert system (facts, 21 rules, inference engine, explanation, menu) |
| `README.md` | This guide |
| `tests/T1.txt ... T10.txt` | Real output transcripts of the 10 test cases in the report |
| `tests/run_tests.py` | (Optional) re-runs the 10 tests automatically; needs Python 3 and `swipl` on the PATH |

## 3. How to run

### Option A - SWI-Prolog window (Windows / Mac)
1. Unzip the package.
2. Open **SWI-Prolog** (Start menu -> "SWI-Prolog").
3. Menu **File -> Consult...** and choose `diagnosis.pl`. SWI-Prolog prints `true.`
4. At the `?-` prompt type the following and press Enter (**do not forget the full stop**):

```
?- start.
```

### Option B - Terminal / command prompt
```
cd path/to/unzipped/folder
swipl diagnosis.pl
?- start.
```
or directly in one line:
```
swipl -q -f diagnosis.pl -g start -t halt
```

## 4. How to use the system

`start.` shows a menu:

```
MAIN MENU
  1. Diagnose me   (full interview, all rules checked)
  2. Test one illness   (goal-driven backward chaining)
  3. Forward chaining   (type your symptoms)
  4. Show the knowledge base (rules and sources)
  0. Exit
```

| Option | What to do | What you get |
|--------|-----------|--------------|
| **1** | Answer 18 questions with `y` or `n` + Enter | Every matching illness, the rule number, matched symptoms, reasoning, source + URL, and a summary |
| **2** | Choose an illness number (1-5), answer only the questions asked | Goal proved/failed. Asks only what the rules need (backward chaining) |
| **3** | Type symptoms separated by commas, e.g. `fever, chills, cough, body ache, headache, fatigue` | Each forward-chaining cycle (rule fires), then the explained result |
| **4** | Nothing | All 21 rules with their sources |

Valid symptom names for option 3: fever, chills, cough, sore_throat, runny_nose, sneezing,
congestion, body_ache, fatigue, headache, throbbing_headache, loss_of_smell, loss_of_taste,
nausea, light_sensitivity, sound_sensitivity, itchy_eyes, shortness_of_breath
(spaces are accepted instead of underscores; unknown words are ignored).

Other entry points (type at the `?-` prompt):

* `run.` - same as menu option 1
* `demo_forward.` - ready-made forward-chaining demo

## 5. Example

Menu option 1, answering **y** to: fever, chills, cough, body ache, fatigue, headache (n to the rest).
Expected result: **Influenza (Flu)** - rules flu-1, flu-2 and flu-3 fire, each with its explanation and source.
(See `tests/T1.txt`.)

Menu option 3 with `fever, chills, cough, body ache, headache, fatigue, toothache`:
`toothache` is ignored, cycles 1-3 fire flu-1, flu-2, flu-3, cycle 4 stops. (See `tests/T10.txt`.)

## 6. Troubleshooting

* Nothing happens after typing a command -> every Prolog command must end with a full stop `.`
* `source_sink ... does not exist` -> wrong path; use **File -> Consult...** and browse to the file.
* On Windows, if you type a path yourself, use forward slashes: `consult('C:/Users/you/Downloads/diagnosis.pl').`
* Reload after editing the file: `?- make.` or consult it again.

## 7. Knowledge sources

Every rule cites its source(s) inside `diagnosis.pl` (`rule_info/4`) and in Annex A of the report:

* S1 CDC - Similarities and Differences between Flu and COVID-19 - https://www.cdc.gov/flu/about/flu-vs-covid19.html
* S2 Mayo Clinic - Common cold or allergy - https://www.mayoclinic.org/diseases-conditions/common-cold/expert-answers/common-cold-vs-flu/faq-20057857
* S3 NIH "Cold, Flu, or Allergy?" chart (UF/IFAS Extension copy) - https://blogs.ifas.ufl.edu/gadsdenco/2018/02/07/cold-allergy-or-the-flu/
* S4 Mayo Clinic - Migraine: Symptoms and causes - https://www.mayoclinic.org/diseases-conditions/migraine-headache/symptoms-causes/syc-20360201
* S5 Mayo Clinic News Network - Cold vs. allergies during COVID-19 pandemic - https://newsnetwork.mayoclinic.org/discussion/cold-vs-allergies-during-covid-19-pandemic/
* S6 Public-health chart "Coronavirus vs. Cold vs. Flu vs. Allergies" - https://www.childrensmercy.org/siteassets/media/covid-19/coronavirus-vs-cold-vs-flu-vs-allergies.pdf
* S7 Mayo Clinic News Network - What is a migraine headache? - https://newsnetwork.mayoclinic.org/discussion/what-is-a-migraine-headache/
