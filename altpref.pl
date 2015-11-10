%README%
%input is a first rough conversion in graph Test with triples of the form
%niod:Aanvallen skos:prefLabel "Aanslagen", which are to be converted to 
%these two triples:
%[someNumericalURI] skos:prefLabel "Aanslagen",
%[someNumericalURI] skos:altLabel "Aanvallen".
%Function altpref does exactly this, and writes the results to graph niod.


stitch(Scheme, Authority, Path, URI):-
    uri_data('scheme', Components, Scheme),
    uri_data('authority', Components, Authority),
    uri_data('path', Components, Path),
    uri_components(URI, Components).

get_label_from_path(Path, Label):-
    split_string(Path, '/', '/', SubStrings),
	nth1(2, SubStrings, Label).


number_in_use(Number):-
 %(rdf(URI, P, O, 'altPref_new'); rdf(URI, P, O, 'broader_new'); rdf(URI, P, O, 'narrower_new'); rdf(URI, P, O, 'related_new');rdf(URI, P, O, 'pref_new')),
   rdf(URI,_,_,'niod'),
   stitch(_,_, Path, URI),
   get_label_from_path(Path, NumberStr),
   atom_string(NumberAtom, NumberStr),
   atom_number(NumberAtom, Number).


numbers_in_use(Numbers):-
    findall(Number, number_in_use(Number), Numbers).

next(Numbers, Next):-
    numbers_in_use(Numbers),
    (   max_list(Numbers, Max) ->  Next is Max + 1; Next is 1000).

make_numerical_uri(NumericalURI):-
    next(Numbers, Next), 
    atom_string(Next, NextStr),
    stitch(http, 'data.niod.nl/concept/', NextStr, NumericalURI).


known(Label):-
    rdf(S, skos:'prefLabel', literal(Label), 'niod').

correct(URI, Label):-
	make_numerical_uri(NumericalURIStr),
   % atom_string(NumericalURI, NumericalURIStr),
    rdf_assert(NumericalURIStr, skos:'altLabel', literal(Label), 'niod'),
    forall(rdf(URI, skos:'prefLabel', O, 'Test'),rdf_assert(NumericalURIStr, skos:'prefLabel', O, 'niod')).
    %rdf_retractall(URI, skos:'prefLabel', _, 'niod'). %remove old triples



%remove altlabel if this is defined as the pref label
postprocess:-
    forall(concept_with_same_alt_pref(S,O), rdf_retractall( S, skos:'altLabel', O, 'niod')).
               
concept_with_same_alt_pref_test(S,O1,O2):-
               rdf(S, skos:'prefLabel', O1, 'niod'),
               rdf(S, skos:'altLabel', O2, 'niod').
    

concept_with_same_alt_pref(S):-
               rdf(S, skos:'prefLabel', literal(O), 'niod'),
               rdf(S, skos:'altLabel', literal(O), 'niod').
  

do_pref(URI):-
	get_label(URI, Label), %this is the intended altLabel
    (known(Label) ->  true; correct(URI, Label)).
    %postprocess.

altpref:-
    %forall(rdf(S, niod:uniquePrefLabel,_, 'Niod_encoded.ttl'), do_pref(S)).    
    rdf_register_prefix('niod', 'http://data.niod.nl/concept/'),
    forall(rdf(S, skos:'prefLabel',_, 'Test'), do_pref(S)).
    %postprocess.


