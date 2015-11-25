:- use_module(library(semweb/rdf_db)).

:-[altpref].
:-[broader].
:-[narrower].
:-[related].
:-[cleanup].


godo:-
	rdf_load('../../git/Niod/Input.ttl',[graph('Test')]),
	altpref:altpref,
	broader:broader,
	narrower:narrower,
	related:related,
	cleanup:clean_up.



/*
'Create the NIOD thesaurus in .ttl from a first rough conversion
1) Upload file Input.ttl to ClioPatria server and store in a graph named Test.\
2) run method altpref from altpref.pl\
3) run method broader from broader.pl\
4) run method narrower from narrower.pl\
5) run method related from related.pl\
6) run method clean_up from cleanup.pl
DONE! Now download the resulting graph.
The results for each step are visible as newly created triples in graph
'niod'.*/