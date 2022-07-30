all:
	valac main.vala moy.vala --pkg=posix -o push_swap_tester

run:
	./push_swap_tester
