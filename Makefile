NAME    =   tester_push_swap

all:
	valac -g main.vala moy.vala --pkg=posix --pkg=gio-2.0 -X -w --vapidir=./vapi -o ${NAME} 
	@echo "\033[92;1;5m[tester_push_swap]\033[0m Correctly created"

clean:  
	@rm -f tester_push_swap
	@echo "\033[93;1;5m[tester_push_swap]\033[0m Correctly deleted"

run: all
	@./tester_push_swap 100 10

re:	clean all
