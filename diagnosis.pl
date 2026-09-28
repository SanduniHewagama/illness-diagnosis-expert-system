% =====================================================================
%  ILLNESS DIAGNOSIS EXPERT SYSTEM
%  CM3321 - Logic Programming and Artificial Cognitive Systems
%  Assignment 2
%
%  Domain : preliminary differentiation between Influenza (Flu), Common
%           Cold, Allergy, COVID-19-like illness and Migraine from
%           self-reported symptoms.
%
%  IMPORTANT: The symptom patterns in every rule below are taken from the
%  published sources listed in SECTION 1 (each rule cites its source in
%  SECTION 4). The system gives POSSIBLE conditions only. It is NOT a
%  medical diagnosis.
%
%  HOW TO RUN (see README.md for details):
%     swipl diagnosis.pl        then type:   ?- start.
% =====================================================================

:- dynamic has/1, hasnt/1, fired/2, ask_on_demand/0, echo_mode/0.

% =====================================================================
% SECTION 1 - KNOWLEDGE SOURCES (7 facts)
% source(Id, Title, URL)
% =====================================================================
source(s1, 'CDC - Similarities and Differences between Flu and COVID-19',
       'https://www.cdc.gov/flu/about/flu-vs-covid19.html').
source(s2, 'Mayo Clinic - Common cold or allergy: symptom check',
       'https://www.mayoclinic.org/diseases-conditions/common-cold/expert-answers/common-cold-vs-flu/faq-20057857').
source(s3, 'NIH "Cold, Flu, or Allergy?" symptom chart, reproduced by UF/IFAS Extension',
       'https://blogs.ifas.ufl.edu/gadsdenco/2018/02/07/cold-allergy-or-the-flu/').
source(s4, 'Mayo Clinic - Migraine: Symptoms and causes',
       'https://www.mayoclinic.org/diseases-conditions/migraine-headache/symptoms-causes/syc-20360201').
source(s5, 'Mayo Clinic News Network - Cold vs. allergies during COVID-19 pandemic',
       'https://newsnetwork.mayoclinic.org/discussion/cold-vs-allergies-during-covid-19-pandemic/').
source(s6, 'Public-health chart "Coronavirus vs. Cold vs. Flu vs. Allergies" (hosted by Children\'s Mercy)',
       'https://www.childrensmercy.org/siteassets/media/covid-19/coronavirus-vs-cold-vs-flu-vs-allergies.pdf').
source(s7, 'Mayo Clinic News Network - What is a migraine headache?',
       'https://newsnetwork.mayoclinic.org/discussion/what-is-a-migraine-headache/').

% =====================================================================
% SECTION 2 - FACTS
% =====================================================================

% --- 18 symptom facts (order = order of the interview questions) ---
symptom(fever).
symptom(chills).
symptom(cough).
symptom(sore_throat).
symptom(runny_nose).
symptom(sneezing).
symptom(congestion).
symptom(body_ache).
symptom(fatigue).
symptom(headache).
symptom(throbbing_headache).
symptom(loss_of_smell).
symptom(loss_of_taste).
symptom(nausea).
symptom(light_sensitivity).
symptom(sound_sensitivity).
symptom(itchy_eyes).
symptom(shortness_of_breath).

% --- 5 illness facts and their display names ---
illness(flu).
illness(common_cold).
illness(allergy).
illness(covid).
illness(migraine).

illness_label(flu,         'Influenza (Flu)').
illness_label(common_cold, 'Common Cold').
illness_label(allergy,     'Allergy (airborne / seasonal)').
illness_label(covid,       'COVID-19-like illness').
illness_label(migraine,    'Migraine').

% --- 18 question facts used by the interface ---
question(fever,               'Do you have a fever (high temperature)?').
question(chills,              'Do you have chills / feel feverish?').
question(cough,               'Do you have a cough?').
question(sore_throat,         'Do you have a sore throat?').
question(runny_nose,          'Do you have a runny nose?').
question(sneezing,            'Are you sneezing a lot?').
question(congestion,          'Do you have a stuffy / blocked nose?').
question(body_ache,           'Do you have muscle or body aches?').
question(fatigue,             'Do you feel unusually tired (fatigue)?').
question(headache,            'Do you have a headache?').
question(throbbing_headache,  'Is the headache throbbing / pulsing?').
question(loss_of_smell,       'Have you lost / changed your sense of smell?').
question(loss_of_taste,       'Have you lost / changed your sense of taste?').
question(nausea,              'Do you feel nauseous (sick in the stomach)?').
question(light_sensitivity,   'Are you sensitive to light?').
question(sound_sensitivity,   'Are you sensitive to sound?').
question(itchy_eyes,          'Do you have itchy or watery eyes?').
question(shortness_of_breath, 'Do you have shortness of breath?').

% =====================================================================
% SECTION 3 - working-memory helper
% sym(S) is true when the user has reported symptom S.
%   - already answered yes  -> true
%   - already answered no   -> false
%   - unknown + on-demand mode (goal-driven) -> ask the user now
%   - unknown otherwise     -> false (not reported = absent)
% =====================================================================
sym(S) :- has(S), !.
sym(S) :- hasnt(S), !, fail.
sym(S) :- ask_on_demand, ask_symptom(S), has(S).

% =====================================================================
% SECTION 4 - RULES (21 IF-THEN rules)
% diagnose_rule(Illness, RuleNo) :- conditions.
% "\+ sym(X)" means: symptom X must NOT be reported.
% The source of every rule is given in rule_info/4 (SECTION 5).
% =====================================================================

% ---- FLU ----
diagnose_rule(flu, 1) :- sym(fever), sym(body_ache), sym(headache).
diagnose_rule(flu, 2) :- sym(fever), sym(chills), sym(cough).
diagnose_rule(flu, 3) :- sym(fever), sym(body_ache), sym(fatigue).
diagnose_rule(flu, 4) :- sym(fever), sym(sore_throat), sym(body_ache),
                         \+ sym(loss_of_smell), \+ sym(loss_of_taste).

% ---- COMMON COLD ----
diagnose_rule(common_cold, 1) :- sym(sore_throat), sym(sneezing), sym(runny_nose),
                                 \+ sym(itchy_eyes).
diagnose_rule(common_cold, 2) :- sym(congestion), sym(sore_throat), sym(cough),
                                 \+ sym(fever).
diagnose_rule(common_cold, 3) :- sym(congestion), sym(sneezing), sym(sore_throat),
                                 \+ sym(fever).
diagnose_rule(common_cold, 4) :- sym(fatigue), sym(runny_nose), sym(sore_throat),
                                 \+ sym(itchy_eyes).

% ---- ALLERGY ----
diagnose_rule(allergy, 1) :- sym(itchy_eyes), sym(sneezing), sym(runny_nose),
                             \+ sym(fever).
diagnose_rule(allergy, 2) :- sym(itchy_eyes), sym(congestion),
                             \+ sym(fever), \+ sym(body_ache).
diagnose_rule(allergy, 3) :- sym(sneezing), sym(runny_nose),
                             \+ sym(fever), \+ sym(sore_throat).
diagnose_rule(allergy, 4) :- sym(itchy_eyes), sym(runny_nose),
                             \+ sym(loss_of_smell), \+ sym(loss_of_taste).

% ---- COVID-19-like illness ----
diagnose_rule(covid, 1) :- sym(loss_of_smell), sym(loss_of_taste).
diagnose_rule(covid, 2) :- sym(fever), sym(cough), sym(loss_of_smell).
diagnose_rule(covid, 3) :- sym(fever), sym(cough), sym(shortness_of_breath).
diagnose_rule(covid, 4) :- sym(fever), sym(fatigue), sym(loss_of_taste).
diagnose_rule(covid, 5) :- sym(cough), sym(shortness_of_breath), sym(fatigue),
                           \+ sym(sneezing), \+ sym(itchy_eyes).

% ---- MIGRAINE ----
diagnose_rule(migraine, 1) :- sym(headache), sym(throbbing_headache), sym(nausea).
diagnose_rule(migraine, 2) :- sym(headache), sym(light_sensitivity), sym(sound_sensitivity).
diagnose_rule(migraine, 3) :- sym(headache), sym(light_sensitivity), sym(nausea).
diagnose_rule(migraine, 4) :- sym(headache), sym(throbbing_headache), sym(sound_sensitivity).

% =====================================================================
% SECTION 5 - RULE REFERENCES (21 facts)
% rule_info(Illness, RuleNo, [SourceIds], WhyTheRuleHolds)
% =====================================================================
rule_info(flu, 1, [s3], 'Chart lists fever (severe, usually high), headache (common) and general aches (usual) for flu.').
rule_info(flu, 2, [s1], 'CDC lists fever/chills and cough among the usual flu symptoms.').
rule_info(flu, 3, [s3], 'Chart lists fever, usual body aches and usual fatigue (up to 3 weeks) for flu.').
rule_info(flu, 4, [s1], 'CDC lists fever, sore throat and body aches for flu; change/loss of taste or smell is noted as a COVID-19 difference.').

rule_info(common_cold, 1, [s2], 'Sore throat, sneezing and runny nose are usual in a cold, while itchy eyes are rare.').
rule_info(common_cold, 2, [s3], 'Chart: stuffy nose and sore throat common, cough mild to moderate, fever rare for a cold.').
rule_info(common_cold, 3, [s6], 'Chart: stuffy nose, sneezing and sore throat are common in a cold; fever is rare.').
rule_info(common_cold, 4, [s2], 'Tiredness sometimes, runny nose and sore throat usually, itchy eyes rarely in a cold.').

rule_info(allergy, 1, [s2], 'Itchy eyes, sneezing and runny nose are usual in allergy, and allergy never causes fever.').
rule_info(allergy, 2, [s3], 'Chart: itchy watery eyes and stuffy nose are common in allergy; fever and general aches never occur.').
rule_info(allergy, 3, [s6], 'Chart: sneezing and runny nose are common in allergy; fever and sore throat do not occur.').
rule_info(allergy, 4, [s5], 'Itchy/watery eyes and runny nose point to allergy; loss of taste/smell is not seen with allergies.').

rule_info(covid, 1, [s1, s5], 'Change or loss of taste or smell is a COVID-19 symptom and is not seen with allergies.').
rule_info(covid, 2, [s1, s5], 'Fever, cough and loss of smell are listed COVID-19 symptoms.').
rule_info(covid, 3, [s1, s6], 'Fever, cough and shortness of breath are listed COVID-19 symptoms.').
rule_info(covid, 4, [s1, s5], 'Fever, fatigue and loss of taste are listed COVID-19 symptoms.').
rule_info(covid, 5, [s6, s5], 'Cough and shortness of breath with fatigue, but no sneezing (rare in COVID-19) and no itchy eyes (allergy sign).').

rule_info(migraine, 1, [s4], 'Mayo Clinic: migraine pain throbs or pulses and is accompanied by nausea.').
rule_info(migraine, 2, [s4, s7], 'Mayo Clinic: migraine headache comes with sensitivity to light and sound.').
rule_info(migraine, 3, [s4], 'Mayo Clinic: migraine headache with light sensitivity and nausea.').
rule_info(migraine, 4, [s4], 'Mayo Clinic: throbbing migraine headache with sensitivity to sound.').

% =====================================================================
% SECTION 6 - INFERENCE ENGINE
% =====================================================================

% ---- 6.1 Working memory ----
reset_memory :-
    retractall(has(_)),
    retractall(hasnt(_)),
    retractall(fired(_, _)),
    retractall(ask_on_demand).

% ---- 6.2 Asking the user (y/n) ----
ask_symptom(S) :-
    question(S, Q),
    repeat,
        format("~w (y/n): ", [Q]),
        flush_output,
        read_line_to_string(user_input, Line),
        (   Line == end_of_file
        ->  Ans = n
        ;   string_lower(Line, Lower),
            normalize_space(string(T), Lower),
            (   yes_no(T, Ans) -> true
            ;   writeln('   Please type y or n.'), fail
            )
        ),
        echo_input(Ans),
    !,
    (   Ans == y -> assertz(has(S)) ; assertz(hasnt(S)) ).

yes_no("y", y).
yes_no("yes", y).
yes_no("n", n).
yes_no("no", n).

% echo_mode is only switched on by the automated test runner so that
% piped answers appear in the transcript. Normal users never see it.
echo_input(X) :- ( echo_mode -> writeln(X) ; true ).

% ---- 6.3 BACKWARD CHAINING (goal-driven) ----
% Goal: prove diagnose_rule(Illness, RuleNo). Prolog tries each rule body
% and asks the user for a symptom ONLY when the rule needs it (sym/1).
goal_driven :-
    reset_memory,
    nl, writeln('Which illness do you want to test?'),
    findall(I, illness(I), Is),
    forall(nth1(N, Is, I),
           ( illness_label(I, L), format("  ~w. ~w~n", [N, L]) )),
    write('Enter number: '), flush_output,
    read_line_to_string(user_input, Line0),
    ( Line0 == end_of_file -> Line = "" ; Line = Line0 ),
    normalize_space(string(T), Line),
    echo_input(T),
    (   number_string(Num, T), nth1(Num, Is, Illness)
    ->  goal_driven(Illness)
    ;   writeln('Invalid choice.')
    ).

goal_driven(Illness) :-
    illness_label(Illness, Label),
    findall(x, rule_info(Illness, _, _, _), Xs),
    length(Xs, NRules),
    format("~nGOAL: show that ~w is possible (~w rules can prove it).~n", [Label, NRules]),
    writeln('I will only ask about symptoms that these rules need.'), nl,
    assertz(ask_on_demand),
    findall(Illness-R, diagnose_rule(Illness, R), Results),
    retractall(ask_on_demand),
    findall(S, has(S), Yes),
    findall(S, hasnt(S), No),
    symptoms_text(Yes, YT), symptoms_text(No, NT),
    format("~nFacts gathered -> YES: [~w]   NO: [~w]~n", [YT, NT]),
    (   Results == []
    ->  format("~nGOAL FAILED: none of the ~w rules for ~w could be satisfied.~n", [NRules, Label]),
        writeln('Hypothesis rejected (based on the answers given).')
    ;   length(Results, Cnt),
        format("~nGOAL PROVED: ~w of ~w rules for ~w are satisfied.~n", [Cnt, NRules, Label]),
        show_results(Results)
    ).

% ---- 6.4 Full interview, then backward chaining over all rules ----
diagnose_interactive :-
    reset_memory,
    nl, writeln('Please answer the following questions with y or n:'), nl,
    forall(symptom(S), ask_symptom(S)),
    findall(I-R, diagnose_rule(I, R), Results),
    show_results(Results).

run :- diagnose_interactive.

% ---- 6.5 FORWARD CHAINING (data-driven) ----
% Known symptoms are put in working memory, then the engine repeats:
%   MATCH  a rule whose conditions are all satisfied and not yet fired,
%   FIRE   it (record the suspected illness),
% until no new rule can fire.
forward_mode :-
    nl, writeln('Type the symptoms you have, separated by commas.'),
    findall(S, symptom(S), Ss),
    symptoms_text(Ss, ST),
    format("Valid symptoms: ~w~n", [ST]),
    write('Symptoms: '), flush_output,
    read_line_to_string(user_input, Line0),
    ( Line0 == end_of_file -> Line = "" ; Line = Line0 ),
    echo_input(Line),
    split_string(Line, ",", " ", Parts0),
    exclude(==(""), Parts0, Parts),
    maplist(norm_symptom, Parts, Given),
    partition(symptom, Given, Valid, Invalid),
    (   Invalid == [] -> true
    ;   symptoms_text(Invalid, IT),
        format("Ignored (not in knowledge base): ~w~n", [IT])
    ),
    forward_chain(Valid).

norm_symptom(Str, Atom) :-
    string_lower(Str, Lower),
    split_string(Lower, " ", "", Words),
    atomic_list_concat(Words, '_', Atom).

forward_chain(Symptoms) :-
    reset_memory,
    forall(member(S, Symptoms), assertz(has(S))),
    symptoms_text(Symptoms, T),
    format("~nWorking memory (facts): [~w]~n~n", [T]),
    forward_loop(1),
    findall(I-R, fired(I, R), Results),
    show_results(Results).

forward_loop(N) :-
    (   diagnose_rule(I, R), \+ fired(I, R)
    ->  assertz(fired(I, R)),
        format("Cycle ~w: all conditions of rule ~w-~w are satisfied -> rule FIRES, ~w is suspected.~n",
               [N, I, R, I]),
        N1 is N + 1,
        forward_loop(N1)
    ;   format("Cycle ~w: no further rule can fire. Forward chaining stops.~n", [N])
    ).

% Ready-made forward-chaining demo:  ?- demo_forward.
demo_forward :-
    forward_chain([fever, chills, cough, body_ache, headache, fatigue]).

% =====================================================================
% SECTION 7 - EXPLANATION MODULE
% For every rule that fired: matched symptoms, absent-required symptoms,
% reasoning text and the source (with URL).
% =====================================================================
show_results([]) :- !,
    nl, writeln('No rule in the knowledge base matched the reported symptoms.'),
    writeln('This does NOT mean you are healthy - see a doctor if you feel unwell.').
show_results(Results) :-
    nl, writeln('================ DIAGNOSIS RESULT ================'),
    forall(member(Item, Results), show_item(Item)),
    nl, writeln('Summary (illness : number of rules that matched):'),
    summary(Results),
    nl, writeln('Note: these are POSSIBLE conditions based on published symptom lists.'),
    writeln('It is not a medical diagnosis. Please consult a doctor.').

show_item(I-R) :-
    illness_label(I, Label),
    conditions(I, R, Present, Absent),
    rule_info(I, R, Srcs, Reason),
    symptoms_text(Present, PT),
    format("~nPossible condition: ~w   [Rule ~w-~w]~n", [Label, I, R]),
    format("  Symptoms matched   : ~w~n", [PT]),
    (   Absent == [] -> true
    ;   symptoms_text(Absent, AT),
        format("  Required absent    : ~w (not reported)~n", [AT])
    ),
    format("  Reasoning          : ~w~n", [Reason]),
    forall(member(S, Srcs),
           (   source(S, Title, URL),
               format("  Source [~w]         : ~w~n                       ~w~n", [S, Title, URL])
           )).

summary(Results) :-
    findall(I, member(I-_, Results), Is0),
    sort(Is0, Is),
    findall(N-I,
            ( member(I, Is),
              aggregate_all(count, member(I-_, Results), N) ),
            Pairs),
    keysort(Pairs, Sorted),
    reverse(Sorted, Desc),
    forall(member(N-I, Desc),
           ( illness_label(I, L), format("  ~w : ~w rule(s)~n", [L, N]) )).

% Reads the IF-part of a rule directly from the rule itself (clause/2),
% so the explanation always matches the real rule.
conditions(I, R, Present, Absent) :-
    clause(diagnose_rule(I, R), Body),
    body_literals(Body, Lits),
    findall(S, member(sym(S), Lits), Present),
    findall(S, member(\+ sym(S), Lits), Absent).

body_literals((A, B), L) :- !,
    body_literals(A, LA), body_literals(B, LB), append(LA, LB, L).
body_literals(G, [G]).

symptoms_text(List, Text) :- atomic_list_concat(List, ', ', Text).

% =====================================================================
% SECTION 8 - USER INTERFACE (text menu)
% =====================================================================
start :-
    banner,
    main_menu.

banner :-
    nl,
    writeln('=================================================='),
    writeln('   ILLNESS DIAGNOSIS EXPERT SYSTEM  (CM3321)      '),
    writeln('   Flu | Common Cold | Allergy | COVID-19-like | Migraine'),
    writeln('=================================================='),
    writeln('Educational project - NOT a medical diagnosis.').

main_menu :-
    nl,
    writeln('MAIN MENU'),
    writeln('  1. Diagnose me   (full interview, all rules checked)'),
    writeln('  2. Test one illness   (goal-driven backward chaining)'),
    writeln('  3. Forward chaining   (type your symptoms)'),
    writeln('  4. Show the knowledge base (rules and sources)'),
    writeln('  0. Exit'),
    write('Enter choice: '), flush_output,
    read_line_to_string(user_input, Line0),
    ( Line0 == end_of_file -> Line = "0" ; Line = Line0 ),
    normalize_space(string(Choice), Line),
    echo_input(Choice),
    handle(Choice).

handle("1") :- !, diagnose_interactive, main_menu.
handle("2") :- !, goal_driven, main_menu.
handle("3") :- !, forward_mode, main_menu.
handle("4") :- !, show_kb, main_menu.
handle("0") :- !, writeln('Goodbye. Stay healthy!').
handle(_)   :- writeln('Invalid choice, please enter 0-4.'), main_menu.

show_kb :-
    nl, writeln('=========== KNOWLEDGE BASE: RULES ==========='),
    forall(illness(I),
           (   illness_label(I, L), format("~n~w~n", [L]),
               forall(rule_info(I, R, Srcs, _), print_rule_line(I, R, Srcs))
           )),
    nl, writeln('=========== SOURCES ==========='),
    forall(source(Id, T, U), format("[~w] ~w~n     ~w~n", [Id, T, U])).

print_rule_line(I, R, Srcs) :-
    conditions(I, R, Present, Absent),
    symptoms_text(Present, PT),
    symptoms_text(Srcs, ST),
    format("  Rule ~w-~w: IF ~w", [I, R, PT]),
    (   Absent == [] -> true
    ;   symptoms_text(Absent, AT), format(" AND NOT (~w)", [AT])
    ),
    format("   [source: ~w]~n", [ST]).
