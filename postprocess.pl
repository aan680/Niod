:- use_module(library(uri)).

postprocess:-
    merge,
    add_type_definitions('Niod_cleaned.ttl', 'Niod_cleaned.ttl'),
    add_conceptscheme_definitions('Niod_cleaned.ttl', 'Niod_cleaned.ttl'),
    forall(needs_preflabel(S, L, 'Niod_cleaned.ttl'), add_preflabel_remove_label(S, L, 'Niod_cleaned.ttl', 'Niod_cleaned.ttl')).
               
needs_preflabel(S, L, OldG):-
    rdf(S, skos:label, literal(L), OldG),
    \+ rdf(S, skos:prefLabel,literal(_), OldG).

add_preflabel_remove_label(S,L, OldG, NewG):-
    rdf_retractall(S, rdfs:label, literal(L), OldG),
    rdf_assert(S, skos:prefLabel, literal(L), NewG).

merge:-
    collect_graph('related_new'),
    collect_graph('broader_new'),
    collect_graph('narrower_new'),
    collect_graph('pref_new'),
    collect_graph('altPref_new').
    
needs_type(S, Graph):-
    has_label(S),
    \+ rdf(S, rdf:type, skos:'Concept').

collect_graph(Old):-
	forall(rdf(S,P,O, Old), rdf_assert(S,P,O, 'Niod_cleaned.ttl')).

%add_type_definitions('Niod_cleaned.ttl', 'Niod_cleaned.ttl').
add_type_definitions(OldGraph, NewGraph):-
    forall(needs_type(S, OldGraph), rdf_assert(S, rdf:type, skos:'Concept', NewGraph)).

add_conceptscheme_definitions(OldGraph, NewGraph):-
    rdf_assert(niod:'concept-collection', rdf:type, skos:'ConceptScheme'),
    rdf_assert(niod:'concept-collection', rdfs:label, literal(type(xsd:string, "Niod concept collection"))),
    forall(concept(S, OldGraph), rdf_assert(S, skos:inScheme, niod:'concept-collection', NewGraph)).

concept(S, Graph):-
    rdf(S, rdf:type, skos:'Concept', Graph).

literal_to_clean(L, Before, Len, After):-
    label(L),
    %atom_string(L
	sub_atom(L, Before, Len, After,'_').
   	%sub_atom(P, Before, Len, After,'_'),

do(L, SubStrings):-
    literal_to_clean(L, Before, Len, After),
    split_string(L, '_', '_', SubStrings).
    %member(Part, SubStrings).

dothis(Position, Part):-
    do(DirtyString, SubStrings),
	forall(member(Part, SubStrings), nth1(Position, SubStrings, Part)).

has_label(S):-
    rdf(S, skos:label, literal(type(_, _))); 
    rdf(S, skos:prefLabel,literal(type(_, _))); 
    rdf(S, skos:altLabel, literal(type(_, _))).



label(L):-
    rdf(_, skos:label, literal(type(_, L))); 
    rdf(_, skos:prefLabel,literal(type(_, L))); 
    rdf(_, skos:altLabel, literal(type(_, L))).

split_string(S, '_', '_', SubStrings).

split(S, Part1, Part2):-
    split_string(S, '_', '_', SubStrings),
	nth1(1, SubStrings, Part1),
    nth1(2, SubStrings, Part2),
    

preprocess:-
    read('log/langdetection_results/langid_FV.txt', Line),
    uri_encoded(+Component, -Value, +Encoded).
 	read_file_to_terms(+Spec, -Terms, +Options).

