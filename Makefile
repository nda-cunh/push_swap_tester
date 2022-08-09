NAME    =   tester_push_swap

all:
	valac main.vala moy.vala --pkg=posix -o ${NAME} 
	@echo "\033[92;1;5m[push_swap_tester]\033[0m Correctly created"

opti:
	valac main.vala moy.vala --pkg=posix -X -O3 -o ${NAME}
	@echo "\033[92;1;5m[push_swap_tester]\033[0m Correctly created with optimisation"

run:
	@./${NAME}

clean:  
	@rm -f push_swap_tester
	@echo "\033[93;1;5m[push_swap_tester]\033[0m Correctly deleted"

re:	clean all
