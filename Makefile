NAME    =   push_swap_tester

all:    ${NAME}

${NAME} :
    @valac main.vala moy.vala --pkg=posix -o push_swap_tester 
    @echo -e "\033[92;1;5m[push_swap_tester]\033[0m Correctly created"

opti:
    @valac main.vala moy.vala --pkg=posix -o push_swap_tester
    @echo -e "\033[92;1;5m[push_swap_tester]\033[0m Correctly created with optimisation"

run:
    ./push_swap_tester

clean:  
    @rm -f push_swap_tester
    @echo -e "\033[93;1;5m[push_swap_tester]\033[0m Correctly deleted"
