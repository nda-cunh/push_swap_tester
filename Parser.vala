/* All test you can add some test here */
private async void list_test() throws Error
{
	/* TRUE = GOOD  */
	/* FALSE = ERROR */

	Intl.setlocale ();
	// use utf square
	print ("\n%s[Mandatory] \033[0m|", Level.MANDATORY.get_when_ko());
	print (" %s[Optional] \033[0m|", Level.OPTIONAL.get_when_ko());
	print (" %s[Extra]\033[0m\n", Level.EXTRA.get_when_ko());
	print("-\n");

    yield test({" ", "2", "1"}, false);
    yield test({"4", " ", "3"}, false);
    yield test({"", "4", "2"}, false); 
    yield test({"1", "0", " "}, false);
	yield test({"454845456689864", "5455464454545"}, false);
	yield test({"4", "999999999999999"}, false);
	yield test({"25 514748364945465565656"}, false);
	yield test({"8 -214748364945465565656"}, false);
	yield test({"9 -21474836494 8"}, false);
	yield test({"9 214748364842 5"}, false);
	yield test({"9 -2147483649 8"}, false);
	yield test({"9 2147483648 5"}, false);
	yield test({"+-52"}, false, OPTIONAL);
	yield test({"++52"}, false, OPTIONAL);
	yield test({"   -a   "}, false);
	yield test({"   ", "-a", "   "}, false);
	yield test({"   ", "-", "   "}, false);
	yield test({"   ", " ", "   "}, false);
	yield test({" ", ""}, false);
	yield test({"", " "}, false);
	yield test({"", ""}, false);
	yield test({"3", "", "2"}, false);
	yield test({"2", "", "3"}, false);
	yield test({"2+5"}, false);
	yield test({"2-5"}, false);
	yield test({"5+2"}, false);
	yield test({"5-2"}, false);
	yield test({"0", "-0"}, false);
	yield test({"-0", "0"}, false);
	yield test({"-00", "+00"}, false);
	yield test({"-00", "00"}, false);
	yield test({"05 5 005"}, false);
	yield test({"+", "52"}, false);
	yield test({"1 2 3 4 5e"}, false);
	yield test({"1 2 4 3 5e"}, false);
	yield test({"e1 2 3 4 5"}, false);
	yield test({"5 4A 3"}, false);
	yield test({"5", "", "0", "2"}, false);
	yield test({"5 1 + 000000 2"}, false);
	yield test({"  "}, false);
	yield test({" "}, false);
	yield test({""}, false);
	yield test({"+ 000000001", "5", "3", "-5"}, false, OPTIONAL);

	// True test
	yield test({"3", "1", " 0"}, true, EXTRA);
	// test.begin({"3", "1", "\t0"}, false, EXTRA); // TODO search if it's a good test
	// test.begin({"3", "1", "\n0"}, false, EXTRA);
	// test.begin({"3", "1", "\r0"}, true, EXTRA);
	// test.begin({"3", "1", "\v0"}, true, EXTRA);
	// test.begin({"3", "1", "\f0"}, true, EXTRA);
	yield test({"3", "1", "\f\r\n\t\v 0"}, false, EXTRA);
	yield test({"+52"}, true);
	yield test({"+52", "-5"}, true);
	yield test({"52"}, true);
	yield test({"5", "4", "3"}, true);
	yield test({"5", "1", "0", "2"}, true);
	yield test({"5 2 3 4 8"}, true);
	yield test({"42 -500 -2845 -21 54784 1541"}, true);
	yield test({"42", "500", "-2845", "-21", " 54784", "1541"}, true);
	yield test({"52 14 15"}, true);
	yield test({"1 2 3"}, true);
	yield test({" 1 2 3"}, true);
	yield test({"1 2 3 "}, true);
	yield test({" 1 2 3 "}, true);
	yield test({" 1   2               3 "}, true);
	yield test({"1 2 3 4 5"}, true);
	yield test({"1 2 3 4 5 6"}, true);
	yield test({"5 4 3 2 1"}, true);
	yield test({"6 5 4 3 2 1"}, true);
	yield test({"5", "3", "2", "1"}, true);
	yield test({" 5", "3  ", " 2", " 1"}, true);
	yield test({"4", "000000000000000000000000000000000000000000000000000000002"}, true);
	yield test({" 5", "8"}, true);
	yield test({"05 02"}, true);
	yield test({"2147483647 -2147483648"}, true);
	yield test({"0002147483647 -002147483648"}, true);
	yield test({"05 08 0009 00010 2"}, true);
	yield test({"052 02"}, true);
	yield test({"-10", "-23"}, true);
	yield test({"-0"}, true);
	yield test({"4 2 3", "5"}, true, OPTIONAL);
	yield test({"5", "4", "3"}, true);
	yield test({"10 5 4 2 1 3 6 9"}, true);
	yield test({"12          "}, true);
}

delegate void test_me(string str_test);

public async void test(string[] argv_do_not_use, bool compare, Level level = MANDATORY) throws Error
{
	var arg = argv_do_not_use.copy();

	/* Memory Part */
	if (g_mode == MEMORY_LEAK)
	{
		string errput;

		int malloc = -42;
		int free = -666;
		StrvBuilder bs = new StrvBuilder();
		bs.add("valgrind");
		bs.add(push_swap_emp);
		bs.addv(arg);
		var proc = new Subprocess.newv (bs.end(), STDERR_PIPE | STDOUT_SILENCE);
		yield proc.communicate_utf8_async (null, null, null, out errput);
		yield proc.wait_async ();
		int index = errput.index_of("total heap usage:");
		if (index != -1)
		{
			unowned string ptr = errput.offset(index);
			unowned string begin = ptr.offset (ptr.index_of_char(':'));
			begin.scanf(": %d allocs, %d frees", out malloc, out free);
		}
		if (malloc == free)
			stdout.printf("\033[1;32m[MOK]:\033[1;92m %d malloc, %d free\033[0m\n", malloc, free);
		else
			stdout.printf("\n\033[1;31m[MKO]: %d malloc , %d free {%s}\033[0m\n", malloc, free, tab_to_string(arg));

		StringBuilder errbuilder = new StringBuilder();

		test_me func = ((s) => {
			unowned string tmp;
			tmp = errput;
			do {
				index = tmp.index_of(s, 4);
				if (index != -1) {
					tmp = tmp.offset(index);
					errbuilder.append(tmp[0: tmp.index_of_char ('\n') + 1]);
				}
			} while (index != -1);
		});

		func("Conditional jump or move depends on uninitialised value");
		func("Invalid read of size");
		func("Invalid write of size");
		func("Use of uninitialised value of size");

		errbuilder.replace("\n", " ", 0);
		if (errbuilder.len != 0)
			stdout.printf("\033[1;31m[MKO]: [%s] {%s}\033[0m\n", errbuilder.str, tab_to_string(arg));
		return ;
	}

	/* Part for FALSE test*/
	if (compare == false && g_mode != TRUE)
	{
		string output;
		string errput;

		StrvBuilder bs = new StrvBuilder();
		bs.add(push_swap_emp);
		bs.addv(arg);
		var proc = new Subprocess.newv (bs.end(), STDOUT_PIPE | STDERR_PIPE);
		yield proc.communicate_utf8_async (null, null, out output, out errput);
		yield proc.wait_async();
		if (errput.has_prefix("Error\n") && output == "")
			stdout.printf("%s[OK] \033[0m", level.get_when_ok());
		else
			stdout.printf("\n%s[KO] (%s) \033[0m", level.get_when_ko(), tab_to_string(arg));
	}
	/* Part for TRUE test*/
	else if (compare == true && g_mode != FALSE){
		// run push_swap
		string pipe;
		string errput;
		string errput_push;

		StrvBuilder bs = new StrvBuilder();
		bs.add(push_swap_emp);
		bs.addv(arg);
		var proc = new Subprocess.newv (bs.end(), STDOUT_PIPE | STDERR_PIPE);
		yield proc.communicate_utf8_async (null, null, out pipe, out errput_push);
		yield proc.wait_async();


		// print ("pipe: %s\n", pipe ?? "NULLLL");
		bs = new StrvBuilder();
		bs.add("./checker_linux");
		bs.addv(arg);
		string contents;
		proc = new Subprocess.newv (bs.end(), STDIN_PIPE | STDOUT_PIPE | STDERR_MERGE);
		yield proc.communicate_utf8_async (pipe, null, out contents, out errput);
		yield proc.wait_async();
		// print ("begin checker\n");

		if (contents != null && "OK" in contents)
			stdout.printf("%s[OK] \033[0m", level.get_when_ok());
		else if (contents != null && "KO" in contents)
			stdout.printf("\n%s[KO] (%s) \033[0m", level.get_when_ko(), tab_to_string(arg));
		else
			stdout.printf("\n%s[KO] (%s) \033[0m", level.get_when_ko(), tab_to_string(arg));

		if ((errput_push ?? "") != (errput ?? ""))
			stdout.printf("\n\033[1;31m[Ko (stderr)]: %s You:[%s] Checker:[%s]\033[0m", tab_to_string(arg), errput_push?.escape() ?? "" , errput?.escape() ?? "");
	}
	stdout.flush();
}

/* change string[] to string {"a", "b", "c"}  --> '"a" "b" "c"' */
private string tab_to_string(string[] tab)
{
	var tmp = "\"" + string.joinv("\" \"", tab) + "\"";
	return tmp.escape("\"");
}

public enum Level {
	MANDATORY,
	OPTIONAL,
	EXTRA;
	public unowned string get_when_ok () {
		return "\033[1;32m";
	} 

	public unowned string get_when_ko () {
		switch (this) {
			case MANDATORY:
				return "\033[1;31m";
			case OPTIONAL:
				return "\033[1;33m";
			case EXTRA:
				return "\033[1;34m";
		}
		error ("Invalid Level");
	}
}
