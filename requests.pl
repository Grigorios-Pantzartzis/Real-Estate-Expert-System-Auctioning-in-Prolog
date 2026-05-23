customer("John Smith",		45, 2, yes, 3, 400, 300, 250, 5, 2).
customer("Nick Cave", 		55, 2, yes, 3, 450, 350, 300, 7, 3).
customer("George Harris",	50, 3, yes, 1, 500, 350, 300, 7, 5).
customer("Harrison Ford", 	50, 2, no,  0, 370, 300, 350, 5, 0).
customer("Will Smith", 		100,5, yes, 0, 100, 50,  25, 2, 1).

customer(X) :-       customer(X, _, _, _, _, _, _, _, _, _).
