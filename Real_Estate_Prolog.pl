
/* Members-Contributors:
	Name: Εράλντο Σινάνι 		AEM: 3677
	Name: Γιάννης Μάρκου 		AEM: 3637
	Name: Γρηγόρης Παντζαρτζής	AEM: 3785
	
   Hinds:
	+Variable: Input of the method
	-Variable: Output of the method
*/


%%% Run method
run :-  
	repeat,
	
	menu(Userselection),
	selection(Userselection),
	
	(Userselection == 0),
	!.
	
%%%===================================================
%%% This is the menu
menu(X) :- 
	write('Μενού:'), nl, 
	write('======'), nl, nl,
	write('1 - Προτιμήσεις ενός πελάτη'), nl,
	write('2 - Μαζικές προτιμήσεις πελατών'), nl,
	write('3 - Επιλογή πελατών μέσω δημοπρασίας'), nl,
	write('0 - Έξοδος'), nl, nl,
	write('Επιλογή : '),
	read(X) .

%%%===================================================
%%% The options listed in the menu
/* The user gives the necessary information
	and the program goes through the list of houses that
	has saved and finds and prints all the compatible houses
	with these properties and the best selection for the user,
	if they exist. */
selection(1) :-
	findall(X, house(X), List_houses),
	write('Δώσε τις παρακάτω πληροφορίες:'), nl,
	write('=============================='), nl,
	write('Ελάχιστο Εμβαδόν: '), read(E_main),
	write('Ελάχιστος αριθμός υπονοδωματίων: '), read(Bedrooms),
	write('Να επιτρέπονται κατοικίδια; (yes/no) '), read(Pet),
	write('Από ποιον όροφο και πάνω να υπάρχει ανελκυστήρας; '), read(Elev),
	write('Ποιο είναι το μέγιστο ενοίκιο που μπορείς να πληρώσεις;'), read(Maxpay),
	
	write('Πόσα θα έδινες για ένα διαμέρισμα στο κέντρο της πόλης (στα ελάχιστα τετραγωνικά); '),
	read(Citypay),
	write('Πόσα θα έδινες για ένα διαμέρισμα στα προάστια της πόλης (στα ελάχιστα τετραγωνικά);'),
	read(Outskirtpay),
	write('Πόσα θα έδινες για κάθε τετραγωνικό διαμερίσματος πάνω από το ελάχιστο; '),
	read(E_mainpay),
	write('Πόσα θα έδινες για κάθε τετραγωνικό κήπου; '), read(E_gardenpay),
	compatible_houses(E_main,Bedrooms,Pet,Elev,Maxpay,Citypay,Outskirtpay,E_mainpay,E_gardenpay,
					List_houses, Comp_houses), nl,
	%length(Comp_houses, Length_comp_houses),
	%write("Comp houses: "), write(Comp_houses),nl,
	print_comp_houses(Comp_houses),
	length(Comp_houses, Length_comp_houses),
	( Length_comp_houses \= 0 ->	%%% Find the best house if there are comp_houses
		find_best_house_print(Comp_houses),
		true
	;
		true
	),
	!.
/* Does the same as the '1' but here we have saved the Customers-users and
	their needs and for each one of them we print the compatible houses and 
	their best choice, if they exist. */
selection(2) :-
	findall(X, customer(X), List_customers),
	findall(X, house(X), List_houses),
	bulk_service(List_customers, List_houses),
	!.
/* Here we take the privious data that are saved (Customers and Houses)
	and we find the best house choice for each one of them.
	The houses that have competition go to auction and the customer
	with the biggest offer wins the house. The others try to find an 
	other best house and the procedure is over when everyone has a house
	if available. 
   The Results are printed to the screen for each Customer. */
selection(3) :-
	nl, 
	findall(X, customer(X), List_customers),
	findall(X, house(X), List_houses),
	find_houses(List_customers, Houses_per_customer, _Best_selection),
	refine_houses(List_houses, Houses_per_customer, List_customers),
	nl,
	!.
/* Exit the Program */
selection(0).
/* Wrong entry */
selection(_) :-
	write('Η επιλογή που δώσατε δεν ήταν δεχτή'), nl,
	write('Παρακαλώ δώστε ενάν αριθμό από τις διαθέσιμες επιλογές.'), nl.
	
%%%======================================================================
/* House's perks */
bedrooms(X, Value) :-        house(X, Value, _, _, _, _, _, _, _).
area(X, Value) :-            house(X, _, Value, _, _, _, _, _, _).
in_city_center(X, Value) :-  house(X, _, _, Value, _, _, _, _, _).
floor_number(X, Value) :-    house(X, _, _, _, Value, _, _, _, _).
has_elevator(X, Value) :-    house(X, _, _, _, _, Value, _, _, _).
allows_pets(X, Value) :-     house(X, _, _, _, _, _, Value, _, _).
yard_area(X, Value) :-       house(X, _, _, _, _, _, _, Value, _).
rent_amount(X, Value) :-     house(X, _, _, _, _, _, _, _, Value).
address(X, Value) :-         house(X, _, _, _, _, _, _, _, _), Value = X.

/* Customer's perks */
min_area(X, Value) :-                      customer(X, Value, _, _, _, _, _, _, _, _).
min_bedrooms(X, Value) :-                  customer(X, _, Value, _, _, _, _, _, _, _).
needs_pet(X, Value) :-                     customer(X, _, _, Value, _, _, _, _, _, _).
needs_elevator_above_floor(X, Value) :-    customer(X, _, _, _, Value, _, _, _, _, _).
max_rent_cutoff(X, Value) :-               customer(X, _, _, _, _, Value, _, _, _, _).
max_rent_for_city_center(X, Value) :-      customer(X, _, _, _, _, _, Value, _, _, _).
max_rent_for_suburbs(X, Value) :-          customer(X, _, _, _, _, _, _, Value, _, _).
max_rate_per_extra_area_unit(X, Value) :-  customer(X, _, _, _, _, _, _, _, Value, _).
max_rate_per_yard_area_unit(X, Value) :-   customer(X, _, _, _, _, _, _, _, _, Value).
customer_name(X, Value) :-                 customer(X, _, _, _, _, _, _, _, _, _), Value = X.

%%%===================================================
%%% Returns a list with the compatible houses
compatible_houses(_,_,_,_,_,_,_,_,_,[],Result) :- Result = [],!.
compatible_houses(E_main,Bedrooms,Pet,Elev,Maxpay,Citypay,Outskirtpay,E_mainpay,E_gardenpay,
				[H1|List],[H1|Result]) :-
	compatible_house(E_main,Bedrooms,Pet,Elev,Maxpay,Citypay,Outskirtpay,E_mainpay,E_gardenpay,
				H1),
	compatible_houses(E_main,Bedrooms,Pet,Elev,Maxpay,Citypay,Outskirtpay,E_mainpay,E_gardenpay,
				List,Result),!
	.
compatible_houses(E_main,Bedrooms,Pet,Elev,Maxpay,Citypay,Outskirtpay,E_mainpay,E_gardenpay,
				[_H1|List],Result) :-
	compatible_houses(E_main,Bedrooms,Pet,Elev,Maxpay,Citypay,Outskirtpay,E_mainpay,E_gardenpay,
				List,Result)
	.

%%%===================================================
%%% Checks if a house is compatible
/* Returns true if it is a compatible house to the customers needs, else false.
	+E_main: Min Area, +Bedrooms: Min Bedrooms, +Pet: Are pets Allowed, 
	+Maxpay: Max rent willing to give, 
	+Citypay: Rent willing to pay in the city for the minimum area
	+Outskirtpay: Rent willing to pay in the outskirt for the minimum area
	+E_mainpay: the amount willing to pay for each extra area of square in house 
	+E_gardenpay: the amount willing to pay for each extra area of square in garden
	+X: The name of the house that we are checking to see if it is compatible */
compatible_house(E_main,Bedrooms,Pet,Elev,Maxpay,Citypay,Outskirtpay,E_mainpay,E_gardenpay,
				X) :-
	area(X, V1), E_main =< V1,
	bedrooms(X, V2), Bedrooms =< V2,
	allows_pets(X, V3), Pet == V3,
	has_elevator(X, V4),
	floor_number(X, Floor), 
	( Floor >= Elev -> 
		(V4 == yes ->
			true
		; 
			fail
		)	
	;
		true
	),
	rent_amount(X, Rent),
	offer(E_main, Maxpay, Citypay, Outskirtpay, E_mainpay, E_gardenpay, X, Offer),
	( Offer >= Rent ->
		true
	;
		fail
	)
	.

%%%==========================================================
%%% Print the compatible house if found
/* Prints all the compatible houses found in the list with
	all the informations of each house.
		+Comp_houses: A list of the house's names */
print_comp_houses(Comp_houses) :-
	(	Comp_houses == [] ->
		nl,write("Δεν υπάρχει κατάλληλο σπίτι!"),
		nl,nl
	;
		member(X, Comp_houses),	% loop through all the answers
		bedrooms(X, Rooms),
		area(X, E),
		yard_area(X, Yard),
		in_city_center(X, In_city),
		allows_pets(X, Pet),
		floor_number(X, Floor),
		has_elevator(X, Elev),
		rent_amount(X, Rent),
		write('Κατάλληλο σπίτι στην διεύθυνση: '), write(X), nl,
		write('Υπνοδωμάτια: '), write(Rooms), nl,
		write('Εμβαδόν: '), write(E), nl,
		write('Εμβαδόν κήπου: '), write(Yard), nl,
		write('Είναι στο κέντρο της πόλης: '), write(In_city), nl,
		write('Επιτρέπονται κατοικίδια: '), write(Pet), nl,
		write('Όροφος: '), write(Floor), nl,
		write('Ανελκυστήρας: '), write(Elev), nl,
		write('Ενοίκιο: '), write(Rent), nl, nl,
		fail
	)
	.
print_comp_houses(_).

%%%===================================================
%%% Bulk customer service
/* Check through the data of each Customer that the program has_elevator
	saved in and all the houses the program has too, and prints for each customer
	the houses that are compatible with his needs.
		+Customer: A list of the Customer's names 
		+List_houses: A list of the House's names */
bulk_service(Customers, List_houses) :-
	nl,
	member(X, Customers),
	write("Κατάλληλα διαμερίσματα για τον πελάτη: "),
	write(X),nl,
	write("====================================="),nl,
	min_area(X, E_main),
	min_bedrooms(X, Bedrooms),
	needs_pet(X, Pet),
	needs_elevator_above_floor(X, Elev),
	max_rent_cutoff(X, Maxpay),
	max_rent_for_city_center(X, Citypay),
	max_rent_for_suburbs(X, Outskirtpay),
	max_rate_per_extra_area_unit(X, E_mainpay),
	max_rate_per_yard_area_unit(X, E_gardenpay),
	
	compatible_houses(E_main,Bedrooms,Pet,Elev,Maxpay,Citypay,Outskirtpay,E_mainpay,E_gardenpay,
					List_houses, Comp_houses), nl,
	print_comp_houses(Comp_houses),
	length(Comp_houses, Length_comp_houses),
	( Length_comp_houses \= 0 ->
		find_best_house_print(Comp_houses),
		true
	;
		true
	),
	fail
	.
bulk_service(_,_).

%%%===================================================
%%% find_cheaper, find_biggest_garden, find_biggest_house.
findLessCost([],999999999).
findLessCost([X|L],COST) :-
	findLessCost(L,COST1),
	rent_amount(X,V),
	COST is min(V,COST1).

findMaxGard([],-1).
findMaxGard([X|L],GARD) :-
	findMaxGard(L,GARD1),
	yard_area(X,V),
	GARD is max(V,GARD1).
	
findMaxEmv([],-1).
findMaxEmv([X|L],EMV) :-
	findMaxEmv(L,EMV1),
	area(X,V),
	EMV is max(V,EMV1).

find_cheaper([],[],_).
find_cheaper([X|L],Y,COST):-
	find_cheaper(L,Y1,COST),
	rent_amount(X,V),
	( V = COST -> my_append(Y1,[X],Y); my_append(Y1,[],Y)).
	
find_biggest_garden([],[],_).
find_biggest_garden([X|L],Y,GARD):-
	find_biggest_garden(L,Y1,GARD),
	yard_area(X,V),
	( V = GARD -> my_append(Y1,[X],Y); my_append(Y1,[],Y)).
	
find_biggest_house([],[],_).
find_biggest_house([X|L],Y,EMV):-
	find_biggest_house(L,Y1,EMV),
	area(X,V),
	( V = EMV -> my_append(Y1,[X],Y); my_append(Y1,[],Y)).
	

%%%===============================================================
%%% Find the best house
find_best_house_print(List_houses):-
	find_best_house(List_houses, Best),
	write("Προτείνεται η ενοικίαση του διαμερίσματος στην διεύθυνση: "),
	write(Best),nl,nl
	.

/* 	Finds the best house in a list of houses.
	Firstly, the best house is the cheapest in the list.
	Secondly, if there are many houses with the same cheapest prize
	then the best is the one with the biggest garden. 
	Lastly, if we have again many choices being cheapest with the biggest
	garden, then the biggest will be the one with the most main area of squares.
	If the last case also have a lot of houses, just pick the first because all are
	consider "The Best Choise".
		+List_houses: A list of house's names
		-Best: A house name */
find_best_house(List_houses, Best) :-
	( List_houses == [] -> 
		Best = [] 
	;
		findLessCost(List_houses, Cost),
		find_cheaper(List_houses, Cheaper_houses, Cost),
		length(Cheaper_houses, Length1),
		( Length1 == 1 ->		
			first_element(C1, Cheaper_houses),
			Best = C1,
			true
		;
			findMaxGard(Cheaper_houses, Yard),
			find_biggest_garden(Cheaper_houses, Cheaper_garden_houses, Yard),
			length(Cheaper_garden_houses, Length2),
			( Length2 == 1 ->

				first_element(C2, Cheaper_garden_houses),
				Best = C2,
				true
			;
				findMaxEmv(Cheaper_garden_houses, E),
				find_biggest_house(Cheaper_garden_houses, Biggest_better_houses, E),
				% length(Biggest_better_houses, Length3),
				length(Biggest_better_houses, Length3),
				( Length3 == 1 ->
					first_element(C3, Biggest_better_houses),
					Best = C3,
					true
				;
					first_element(C3, Biggest_better_houses),
					Best = C3,
					% Best = Biggest_better_houses,	%%% Add the first cause all are the same
					true							
				),
				true
			)
		)
	)
	.
%%%===================================================
/* A method that returns the bidders for each house, if they exist.
	+Houses: a list of the houses
	+Best_selection: a list of the best house choice for each customer
	+Customers: a list of all the customers
	-Bidders: a list of lists of the customers
		that are competing for each house */
find_bidders(Houses, Best_selection, Customers, Bidders):-
	nreverse(Houses, Reversed_list_houses),
	find_bidders_main(Reversed_list_houses, Best_selection, Customers, Bidders).

%%% +HOUSE,+HOUSESFOREN,+ENIKIASTES,-ENIKISTESFORHOUSES)
t_customer(_,[],[],[]).
t_customer(H,[HE|L],[EN|L2],EnForHouse):-
	t_customer(H,L,L2,EnForHouse1),
	( H == HE -> 
		my_append(EnForHouse1,[EN],EnForHouse)
	;
		my_append(EnForHouse1,[],EnForHouse)
	).

%%% (+houses,+best selection,+customers -enforhouses)
%%% Needs the house list reverse cause it reverses the Results
find_bidders_main([],_,_,[]).
find_bidders_main([H|L], Best_houses, Customers, EnForHouses):-
	find_bidders_main(L, Best_houses, Customers, EnForHouses1),
	t_customer(H,Best_houses, Customers, EnForHouse),
	my_append(EnForHouses1,[EnForHouse],EnForHouses),!.
	
%%%===================================================
%%% The houses and bidders lists should get reversed.
/* A method that takes all the bidders and find the best ones
	for each house. The best bidders is the one that makes the
	biggest offer. If someone has no other competitors we win 
	the house.
		+List_houses: a list of house's names
		+List_bidders: a list of lists of the customers
			that are competing for each house 	
		-Best_bidders: a list of the best bidders for each
			house. The houses without a bidder are empty "[]" */
find_best_bidders(List_houses, List_bidders, Best_bidders) :-
	nreverse(List_houses, Reversed_list_houses),
	nreverse(List_bidders, Reversed_list_bidders),
	find_best_bidders_main(Reversed_list_houses, Reversed_list_bidders, Best_bidders).

%%% +list_houses, +List_bidders, -Best_bidders
find_best_bidders_main([],[],[]).
find_best_bidders_main([H|List_houses], [B|Bidders], Best_bidders):-
	find_best_bidders_main(List_houses, Bidders, Best_b),
	length(B, Len_b),
	( Len_b == 0 ->
		my_append(Best_b, [[]], Best_bidders),
		true
	;
		( Len_b == 1 ->
			my_append(Best_b, B, Best_bidders),
			true
		;
			best_offer(H, B, Offer),
			best_customer_offer(H, B, Offer, Person),
			my_append(Best_b, Person, Best_bidders),
			true
		)
	),!
	.

%%% Returns the best offer of a bidder in a specific house
%%% +House, +Bidders, -Offer
best_offer(_, [], -1).
best_offer(House, [B|Bidder], Offer) :-
	best_offer(House, Bidder, New_offer),
	customer_offer(B, House, C_offer),
	Offer is max(C_offer, New_offer).

%%% Returns the Bidder's name with the best known offer for a house
%%% +House, +Bidder, +Offer, -Person
best_customer_offer(_,[],_,[]).
best_customer_offer(House, [B|Bidder], Offer, Person) :-
	best_customer_offer(House, Bidder, Offer, New_person),
	customer_offer(B, House, C_offer),
	( C_offer == Offer ->
		my_append(New_person, [B], Person),
		!,true
	;
		my_append(New_person, [], Person),
		true
	).

%%%==================================================================
%%%
/* Returns all the compatible houses for each customer and the best
   choices too.
	+Customers : A list of Customer's names
	-Houses : A list of compatible houses lists for each Customer
	-Best_house : A list of the recommended('best') house for each Customer
*/
find_houses(_Customers,Houses,Best_houses):-
	findall(C,houses_for_customer(_X,C),Houses),
	find_best_house_list(Houses, Best_houses).

houses_for_customer(X,Comp_houses):-
	findall(Y, house(Y), List_houses),
	customer(X),
	min_area(X, E_main),
	min_bedrooms(X, Bedrooms),
	needs_pet(X, Pet),
	needs_elevator_above_floor(X, Elev),
	max_rent_cutoff(X, Maxpay),
	max_rent_for_city_center(X, Citypay),
	max_rent_for_suburbs(X, Outskirtpay),
	max_rate_per_extra_area_unit(X, E_mainpay),
	max_rate_per_yard_area_unit(X, E_gardenpay),
	compatible_houses(E_main,Bedrooms,Pet,Elev,Maxpay,Citypay,Outskirtpay,E_mainpay,E_gardenpay,
					List_houses, Comp_houses)
	.

find_best_house_list([], X) :- X =[].
find_best_house_list([H|Houses], [B|Best_houses]):-
	find_best_house(H, B),
	find_best_house_list(Houses, Best_houses).

%%%=============================================================
%%% Offer section
/* This method returns the offer that a Customer makes for a specific house.
	The offer changes as the houses properties change. 
		+E_main_wanted: Min Area,
		+Maxpay: Max rent willing to give, 
		+Citypay: Rent willing to pay in the city for the minimum area
		+Outskirtpay: Rent willing to pay in the outskirt for the minimum area
		+E_mainpay: the amount willing to pay for each extra area of square in house 
		+E_gardenpay: the amount willing to pay for each extra area of square in garden
		+House: The name of the house that we are checking
		-Offer: The offer of the customer for this house */
offer(E_main_wanted, Maxpay, Citypay, Outskirtpay, E_mainpay, E_gardenpay, House, Offer):-
	area(House, E_main),
	in_city_center(House, In_city),
	yard_area(House, E_yard),
	( In_city == yes ->	
		%%% Is in city center
		%%% E_main >= E_main_wanted checked already
		Tmp1 is ((E_main - E_main_wanted) * E_mainpay + E_yard * E_gardenpay + Citypay),
		true
	; 
		%%% Is in the outskirt
		Tmp1 is ((E_main - E_main_wanted) * E_mainpay + E_yard * E_gardenpay + Outskirtpay),
		true
	),
	( Tmp1 >= Maxpay  ->	%%% Offer the max payout if the house too big
		Offer = Maxpay,
		true
	;
		Offer = Tmp1,
		true
	)
	.

/* Returns the offer of a Customer for a house.
	+Customer: A Customer's name
	+House: A House's name
	-Offer: The offer of the customer */
customer_offer(Customer, House, Offer) :-
	min_area(Customer, E_main_wanted),
	max_rent_cutoff(Customer, Maxpay),
	max_rent_for_city_center(Customer, Citypay),
	max_rent_for_suburbs(Customer, Outskirtpay),
	max_rate_per_extra_area_unit(Customer, E_mainpay),
	max_rate_per_yard_area_unit(Customer, E_gardenpay),
	offer(E_main_wanted, Maxpay, Citypay, Outskirtpay, E_mainpay, E_gardenpay, House, Offer)
	.
	
%%%==============================================================
/* 	This method takes a list with compatible houses for each customer
	and finds the best choice for each of them, if exists.
	The customers that are competing for the same house, auction it
	and the winner of the house is the one with the greatest offer.
	Finally, this prints for each customer the house that the are going 
	to buy, if they found something matching their needs. 
		+List_houses: A list of house's names
		+House_per_customer: A list of lists of house's names for each customer
		+List_customers: A list of Customer's names */
refine_houses(List_houses, Houses_per_customer, List_customers) :-
	find_best_house_list(Houses_per_customer, Best_selection),
	find_bidders(List_houses, Best_selection, List_customers, Bidders),
	find_best_bidders(List_houses, Bidders, Best_bidders),
	
	( check_collision_bidders(Bidders) ->
		print_best_bidders(List_houses, List_customers, Best_bidders),!,
		true
	;	
		transform_into_list(Best_bidders, Transformed_best_bidders),
		remove_houses(Transformed_best_bidders,Houses_per_customer,Bidders,
			New_houses_per_customer),
		refine_houses(List_houses, New_houses_per_customer, List_customers),
		true
	)
	.

%%% transform a list into a list of lists
transform_into_list([],[]).
transform_into_list([B|Bidders], Transformed) :-
	transform_into_list(Bidders, Transformed1),
	( B \= [] ->
		my_append([[B]], Transformed1, Transformed)
	;
		my_append([[]], Transformed1, Transformed)
	),!.
	
%%% Checks if are any bidders competing with each other for a house
check_collision_bidders([]).
check_collision_bidders([B|Bidders]) :-
	check_collision_bidders(Bidders),
	length(B, Len_b),
	( Len_b > 1 ->
		fail
	;
		true
	).

%%% Prints the best bidders for each house, if they exist.
%%% +List_houses, +Customers, +Best_bidders
print_best_bidders(_, [], _).
print_best_bidders(List_houses, [C|List_customers], Best_bidders) :-
	print_best_bidders(List_houses, List_customers, Best_bidders),
	customer_owns(List_houses, C, Best_bidders, House_own),
	( House_own == [] ->
		write("O πελάτης "),write(C),
		write(" δεν θα νοικιάσει κάποιο διαμέρισμα!"),nl,
		true
	;
		first_element(First, House_own),
		write("O πελάτης "),write(C),
		write(" θα νοικιάσει το διαμέρισμα στην διεύθυνση: "), write(First),nl,
		true
	),!.

customer_owns([],_,[],[]).
customer_owns([H|List_houses], Customer, [B|Best_bidders], House_own) :-
	customer_owns(List_houses, Customer, Best_bidders, New_house),
	( Customer == B ->
		my_append(New_house, [H], House_own)
	;
		my_append(New_house, [], House_own)
	).

%%%==============================================================
	
%%% Bhouses,Customers,Customer,house,Nbhouses
rhfc([],[],_Customer,_House,[]):- !.

rhfc([_BH|_L1],[_C|_L2],[],_House,_NH).

rhfc([BH|L1],[C|L2],Customer,House,NH):-
	rhfc(L1,L2,Customer,House,NH1),
	list_length(BH,LEN),
	( LEN = 0 ->  my_append(NH1,[[]],NH); 
		( Customer = C -> my_append(NH1,[[House]],NH);
			( sublist([House],BH) -> my_delete(House,BH,NhousesYpolist),my_append(NH1,[NhousesYpolist],NH); my_append(NH1,[BH],NH) )
		)
	).

rhfc([],[_C|L2],Customer,House,NH):-
	rhfc([],L2,Customer,House,NH1),
	my_append(NH1,[],NH).

%%% +BEST_BIDDERS,+Customers,+Houses,+Bidders,-nHouses
remove_houses_helper([],Best_houses,Customers,[],Bidders,[]):- !.
remove_houses_helper([BB|L1],Best_houses,Customers,[H|L2],Bidders,NHouses):-
	remove_houses_helper(L1,Best_houses,Customers,L2,Bidders,NHouses1),
	( BB \= [] ->
	return1oflist(BB,Customer),
	rhfc(Best_houses,Customers,Customer,H,NH1),
	my_append(NH1,[],NHouses)
	; my_append(NHouses1,[],NHouses)).
	
/* Remove the houses that are already won from the compatible house's lists
	of all the losers of the auction. 
		+Best_bidders: A list with the best bidders for each house
		+Best_houses: A list of lists of the compatible house's of the Customers
		+Bidders: A list of lists of the Bidder's names that are competing
		-NEWHouses: A list of lists with the new houses */
remove_houses(Best_Bidders,Best_Houses,Bidders,NEWHouses):-
	findall(X,house(X),HOUSES),
	findall(Y,customer(Y),CUST),
	remove_houses_helper(Best_Bidders,Best_Houses,CUST,HOUSES,Bidders,NHOUSES),
	nreverse(NHOUSES,NEWHouses).

%%%===================================================
%%% Useful functions
my_append([],L,L).
my_append([X|L1],L2,[X|L3]) :- my_append(L1,L2,L3).

member(Χ,[Χ|_Υ]).
member(X,[_Head|Tail]) :- member(X,Tail).

list_delete(_X,[],[]).
list_delete(X,[X|T],T1) :- 
	list_delete(X,T,T1).
list_delete(X,[H|T],[H|T1]) :-
    Χ \= Η,
	list_delete(X,T,T1).
	
nreverse( [], []) .
nreverse([H|T],RL):-
	nreverse(T,RT),
	my_append(RT,[H],RL).
	
my_delete(E,L,NL):-
	my_append(L1,[E|L2],L),
	my_append(L1,L2,NL).
	
sublist(S,L) :-
	my_append(_L1, L2, L),
	my_append(S, _L3, L2).

last_element( _X, [_Χ]).
last_element( X, [_Head|Tail]) :- last_element(X, Tail).

first_element(H, [H|_]).

list_length([],0).
list_length([_|TAIL],N) :- list_length(TAIL,N1), N is N1 + 1.

%%% return first element of a list
return1oflist([X|_L],X).


user_input_yn(Ans):-
	write('Please answer yes/no '), 
	read(X),
	processAns(X,Ans).

processAns(Ans,Ans) :-
	Ans = yes ; Ans = no.
processAns(_X,Ans) :- 
	user_input_yn(Ans).

