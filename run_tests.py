import subprocess, re, json, os

SYMPTOMS = ["fever","chills","cough","sore_throat","runny_nose","sneezing","congestion",
            "body_ache","fatigue","headache","throbbing_headache","loss_of_smell",
            "loss_of_taste","nausea","light_sensitivity","sound_sensitivity",
            "itchy_eyes","shortness_of_breath"]

def interview(yes):
    return "1\n" + "".join(("y\n" if s in yes else "n\n") for s in SYMPTOMS) + "0\n"

tests = [
  # id, title, mode, description of input, stdin, expected rules
  ("T1","Flu pattern","1 Full interview",
   "YES: fever, chills, cough, body_ache, fatigue, headache",
   interview({"fever","chills","cough","body_ache","fatigue","headache"}),
   {"flu-1","flu-2","flu-3"}),
  ("T2","Common cold pattern","1 Full interview",
   "YES: cough, sore_throat, runny_nose, sneezing, congestion, fatigue (no fever)",
   interview({"cough","sore_throat","runny_nose","sneezing","congestion","fatigue"}),
   {"common_cold-1","common_cold-2","common_cold-3","common_cold-4"}),
  ("T3","Allergy pattern","1 Full interview",
   "YES: runny_nose, sneezing, congestion, itchy_eyes (no fever, no sore throat)",
   interview({"runny_nose","sneezing","congestion","itchy_eyes"}),
   {"allergy-1","allergy-2","allergy-3","allergy-4"}),
  ("T4","COVID-19-like pattern","1 Full interview",
   "YES: fever, cough, fatigue, loss_of_smell, loss_of_taste, shortness_of_breath",
   interview({"fever","cough","fatigue","loss_of_smell","loss_of_taste","shortness_of_breath"}),
   {"covid-1","covid-2","covid-3","covid-4","covid-5"}),
  ("T5","Migraine pattern","1 Full interview",
   "YES: headache, throbbing_headache, nausea, light_sensitivity, sound_sensitivity",
   interview({"headache","throbbing_headache","nausea","light_sensitivity","sound_sensitivity"}),
   {"migraine-1","migraine-2","migraine-3","migraine-4"}),
  ("T6","Overlapping symptoms (flu + COVID-19-like)","1 Full interview",
   "YES: fever, chills, cough, sore_throat, body_ache, headache, loss_of_smell",
   interview({"fever","chills","cough","sore_throat","body_ache","headache","loss_of_smell"}),
   {"flu-1","flu-2","covid-2"}),
  ("T7","No matching rule","1 Full interview",
   "YES: headache only",
   interview({"headache"}),
   set()),
  ("T8","Goal-driven: hypothesis rejected (Flu)","2 Goal-driven",
   "Choose 1 (Flu); answer n to the only question asked (fever)",
   "2\n1\nn\n0\n",
   set()),
  ("T9","Goal-driven: hypothesis proved (Migraine)","2 Goal-driven",
   "Choose 5 (Migraine); answer y to the 5 questions asked",
   "2\n5\ny\ny\ny\ny\ny\n0\n",
   {"migraine-1","migraine-2","migraine-3","migraine-4"}),
  ("T10","Forward chaining with an unknown symptom","3 Forward chaining",
   "Typed: fever, chills, cough, body ache, headache, fatigue, toothache",
   "3\nfever, chills, cough, body ache, headache, fatigue, toothache\n0\n",
   {"flu-1","flu-2","flu-3"}),
]

os.makedirs("tests", exist_ok=True)
summary = []
for tid, title, mode, desc, stdin, expected in tests:
    r = subprocess.run(
        ["swipl","-q","-f","../diagnosis.pl","-g","assertz(echo_mode),start","-t","halt"],
        input=stdin, capture_output=True, text=True, timeout=60)
    out = r.stdout + r.stderr
    open(f"tests/{tid}.txt","w").write(out)
    actual = set(f"{a}-{b}" for a,b in re.findall(r"\[Rule ([a-z_]+)-(\d+)\]", out))
    ok = (actual == expected)
    summary.append(dict(id=tid,title=title,mode=mode,desc=desc,
                        expected=sorted(expected),actual=sorted(actual),ok=ok))
    print(tid, "PASS" if ok else "FAIL", sorted(actual))
json.dump(summary, open("tests/summary.json","w"), indent=1)
