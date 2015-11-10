%README%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Graph Test contains a first rough conversion with triples of the form
%niod:Scheepvaart	skos:narrower niod:Binnenvaart
%which are to be converted to 
%[someNumericalURI] skos:narrower [someNumericalURI].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function narrower does exactly this, and writes the results to graph narrower_new.
%It first checks if the subject and object already have a URI, i.e.
% whether X in the URI niod:X is already defined as the label (label/prefLabel/altLabel) of some concept.
% If not, a numerical URI is made that does not clash with already defined URIs,
% it is defined that this is a skos:Concept,
% and 'X' is defined to be a skos:label of this concept.
% So, it is assumed that the entry in the data refers to any label, not necessarily the preferred one.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



stitch(Scheme, Authority, Path, URI):-
    uri_data('scheme', Components, Scheme),
    uri_data('authority', Components, Authority),
    uri_data('path', Components, Path),
    uri_components(URI, Components).

get_label_from_path(Path, Label):-
    split_string(Path, '/', '/', SubStrings),
	nth1(2, SubStrings, Label).

%!enumerate all niod graphs here
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

known(Label, S):-
   rdf(S, skos:altLabel, literal(Label), 'niod'); %OR
    rdf(S, skos:prefLabel, literal(Label), 'niod');
    rdf(S, skos:label, literal(Label), 'niod');
    rdf(S, rdfs:label, literal(Label), 'niod').
    %\+ rdf_equal(G, 'Test').


make_numerical_uri_and_define_label(NumericalURI, Label):-
    make_numerical_uri(NumericalURI),
    rdf_assert(NumericalURI, skos:prefLabel, literal(type(xsd:string, Label)), 'niod').


correct_uri(OldURI, NewURI):-
    get_label(OldURI, Label),
    (   known(Label, NewURI) ->  known(Label, NewURI); make_numerical_uri_and_define_label(NewURI, Label)).

get_label(URI, Label):-
    stitch(Scheme, Authority, Path, URI),
    get_label_from_path(Path, Label).

do_narrower(S, O):-
    correct_uri(S, NewS),
    correct_uri(O, NewO),
    rdf_assert(NewS, skos:narrower, NewO, 'niod').
        

narrower:-
    %forall(rdf(S, skos:narrower,O, 'Niod_encoded.ttl'), do_narrower(S, O)).    
    forall(rdf(S, skos:narrower,O, 'Test'), do_narrower(S, O)).    



   


