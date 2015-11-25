clean_up:-
    assign_missing_types,
    handle_relatedpriority_triples,
    assert_symmetric_relations,
    add_conceptscheme_definitions,
    define_literal_types,
    remove_untyped_literals.
    
%not applicable but good to test anyways.
infer_preflabel:-
    %forall(preflabel_implicit(S,L), replace_label_by_preflabel(S,L)),
    forall(preflabel_implicit_2(S,L), replace_label_by_preflabel_2(S,L)),
    clean_double_labels.

assign_missing_types:-
   forall(conceptdef_missing(S), rdf_assert(S, rdf:type, skos:'Concept', 'niod')).     
       
handle_relatedpriority_triples:-
  forall(broadnarrow_to_be_overruled(S,O), remove_broadnarrow_assert_related(S, O)),
  forall(rdf(S, niod:'related-priority',O, 'niod'), replace_relatedpriority_by_related(S,O)).

assert_symmetric_relations:-
    forall(rdf(A, skos:narrower, B, 'niod'), rdf_assert(B, skos:broader, A, 'niod')),
    forall(rdf(A, skos:broader, B, 'niod'), rdf_assert(B, skos:narrower, A, 'niod')),
    forall(rdf(A, skos:related, B, 'niod'), rdf_assert(B, skos:related, A, 'niod')).

add_conceptscheme_definitions:-
    rdf_assert(niod:'thesaurus', rdf:type, skos:'ConceptScheme', 'niod'),
    rdf_assert(niod:'thesaurus', rdfs:label, literal(type(xsd:string, "Niod thesaurus"))),
    forall(concept(S), rdf_assert(S, skos:inScheme, niod:'thesaurus', 'niod')).

clean_double_labels:-
	forall(rdf(S,P,literal(literal(O)), 'niod'), rdf_assert(S,P,literal(O), 'niod')),
	rdf_retractall(S,P,literal(literal(O)), 'niod').

define_literal_types:-
    forall(literal_type_undefined(S,P,Label), rdf_assert(S,P,literal(type(xsd:string,Label)), 'niod')).

remove_untyped_literals:-
    forall(untyped_literal(S,P,Label), rdf_retractall(S,P,Label, 'niod')).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


untyped_literal(S,P,L):-
    rdf(S,P,literal(type(Type,L)), 'niod'),
    \+ rdf_equal(Type,'http://www.w3.org/2001/XMLSchema#string').                                                         
                                                             
literal_type_undefined(S,P,Label):-
	rdf(S,P,literal(Label), 'niod'), \+ rdf(S,P,literal(type(xsd:string,Label)), 'niod').

double_label(S,L):-
   rdf(S, skos:prefLabel, literal(L), 'niod'),
   rdf(S, skos:altLabel, literal(L), 'niod').

        
           
concept(S):-
    rdf(S, rdf:type, skos:'Concept', 'niod').

replace_relatedpriority_by_related(S,O):-
    rdf_retractall(S, skos:'related-priority',O, 'niod'),
    rdf_assert(S, skos:related, O, 'niod').



remove_broadnarrow_assert_related(S, O):-
    rdf_retractall(S, skos:broader,O, 'niod'),
    rdf_retractall(S, skos:narrower,O, 'niod'),
    rdf_retractall(S, niod:'related-priority',O, 'niod'),
    rdf_assert(S, skos:related, O, 'niod').

broadnarrow_to_be_overruled(S,O):-
    rdf(S, niod:'related-priority',O),
    (   rdf(S, skos:narrower,O);rdf(S, skos:broader,O)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
sanity_check(S1, S2, O):- %o is prefLabelobject
    rdf(S1, skos:'prefLabel', O, 'niod'),
    rdf(S2, skos:'prefLabel', O, 'niod'),
    \+ rdf_equal(S1,S2).

conceptdef_missing(S):-
    rdf(S, skos:prefLabel, O, 'niod'),
    \+ rdf(S, rdf:type, _, 'niod').

replace_label_by_preflabel(S,L):-
    rdf_assert(S, skos:prefLabel, L, 'niod'),
    rdf_retractall(S, skos:label, L, 'niod'). %ie all with implicit preflabel
    

preflabel_implicit(S,Label):-
    \+ rdf(S, skos:prefLabel, literal(Label), 'niod'),
    (rdf(S, skos:altLabel, literal(Label), 'niod'); %OR
    rdf(S, skos:label, literal(Label), 'niod');
    rdf(S, rdfs:label, literal(Label), 'niod')).
    %\+ rdf_equal(G, 'Test').



replace_label_by_preflabel_2(S,L):- %this time for rdfs:label
    rdf_assert(S, skos:prefLabel, L, 'niod'),
    rdf_retractall(S, rdfs:label, L, 'niod'). %ie all with implicit preflabel
    
preflabel_implicit_2(S,L):- %this time for rdfs:label
    rdf(S, rdfs:label, L, 'niod'),
    \+ rdf(S, skos:prefLabel, L, 'niod').


niod_astrid_not_victor(S, PrefLabel):-
    %rdf(S, rdf:type, skos:'Concept', 'niod'),
    rdf(S, skos:prefLabel, literal(PrefLabel), 'niod'),
    \+ rdf(_, skos:prefLabel, literal(PrefLabel), 'niod_old'),
    \+ rdf(_, rdfs:label, literal(PrefLabel), 'niod_old'),
    \+ rdf(_, skos:altLabel, literal(PrefLabel), 'niod_old').

 

niod_victor_not_astrid(S):-
    %rdf(S, rdf:type, skos:'Concept', 'niod_old'),
    rdf(S, skos:prefLabel, literal(PrefLabel), 'niod_old'),
    \+ rdf(_, skos:prefLabel, literal(PrefLabel), 'niod'),
    \+ rdf(_, rdfs:label, literal(PrefLabel), 'niod'),
    \+ rdf(_, skos:altLabel, literal(PrefLabel), 'niod').


all_labels_astrid:-
    true.
    
    
all_labels_victor:-
    true.

