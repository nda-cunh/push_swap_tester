using Posix;

/* where is the push_swap default to "./push_swap" */
public string? push_swap_emp = null;
Mode g_mode = ALL;

/* mode of the tester */
enum Mode {
	ALL, TRUE, FALSE, MEMORY_LEAK
}

/* All test you can add some test here */
void list_test() throws Error
{
	/* TRUE = GOOD  */
	/* FALSE = ERROR */

	test({"+000000001", "5", "3", "-5"}, true);
	test({"+ 000000001", "5", "3", "-5"}, false);
	test({"+52"}, true);
	test({"+52", "-5"}, true);
	test({"52"}, true);
	test({""}, false);
	test({" "}, false);
	test({"  "}, false);
	test({"5", "4", "3"}, true);
	test({"5", "1", "0", "2"}, true);
	test({"5 1 + 000000 2"}, false);
	test({"5", "", "0", "2"}, false);
	test({"5 4A 3"}, false);
	test({"5 2 3 4 8"}, true);
	test({"42 -500 -2845 -21 54784 1541"}, true);
	test({"42", "500", "-2845", "-21", " 54784", "1541"}, true);
	test({"52 14 15"}, true);
	test({"e1 2 3 4 5"}, false);
	test({"1 2 4 3 5e"}, false);
	test({"1 2 3 4 5e"}, false);
	test({"+", "52"}, false);
	test({"1 2 3"}, true);
	test({" 1 2 3"}, true);
	test({"1 2 3 "}, true);
	test({" 1 2 3 "}, true);
	test({" 1   2               3 "}, true);
	test({"1 2 3 4 5"}, true);
	test({"5 4 3 2 1"}, true);
	test({"5", "3", "2", "1"}, true);
	test({" 5", "3  ", " 2", " 1"}, true);
	test({"4", "000000000000000000000000000000000000000000000000000000002"}, true);
	test({" 5", "8"}, true);
	test({"05 02"}, true);
	test({"2147483647 -2147483648"}, true);
	test({"0002147483647 -002147483648"}, true);
	test({"05 08 0009 00010 2"}, true);
	test({"05 5 005"}, false);
	test({"-00", "00"}, false);
	test({"052 02"}, true);
	test({"-0", "0"}, false);
	test({"0", "-0"}, false);
	test({"-10", "-23"}, true);
	test({"-0"}, true);
	test({"4 2 3", "5"}, true);
	test({"5", "4", "3"}, true);
	test({"10 5 4 2 1 3 6 9"}, true);
	test({"5-2"}, false);
	test({"5+2"}, false);
	test({"2-5"}, false);
	test({"2+5"}, false);
	test({"2", "", "3"}, false);
	test({"3", "", "2"}, false);
	test({"", ""}, false);
	test({"", " "}, false);
	test({" ", ""}, false);
	test({"   ", " ", "   "}, false);
	test({"   ", "-", "   "}, false);
	test({"   ", "-a", "   "}, false);
	test({"   -a   "}, false);
	test({"++52"}, false);
	test({"+-52"}, false);
	test({"9 2147483648 5"}, false);
	test({"9 -2147483649 8"}, false);
	test({"9 214748364842 5"}, false);
	test({"9 -21474836494 8"}, false);
	test({"8 -214748364945465565656"}, false);
	test({"25 514748364945465565656"}, false);
	test({"4", "999999999999999"}, false);
	test({"12          "}, true);
	test({"454845456689864", "5455464454545"}, false);

	// bdany - ppuivif
    test({"1", "0", " "}, false);
    test({" ", "2", "1"}, false);
    test({"4", " ", "3"}, false);
    test({"", "4", "2"}, false); 
}

/* Run test take a array like {"5", "12", "3"} and print result */
void test(string[] arg, bool compare) throws Error
{
	var tab = tab_to_string(arg);
	string []argvp;
	string output;
	string errput;
	int wait_status;

	/* Memory Part */
	if (g_mode == MEMORY_LEAK)
	{
		int malloc = -42;
		int free = 666;
		argvp = {"valgrind", push_swap_emp};
		foreach(var i in arg)
			argvp += i;
		Process.spawn_sync(null, argvp, null, SEARCH_PATH, null, out output, out errput);
		foreach (var line in errput.split("\n")) {
			if ("total heap usage:" in line) {
				unowned string begin = line.offset (line.index_of_char(':'));
				begin.scanf(": %d allocs, %d frees", out malloc, out free);
				break ;
			}
		}
		if (malloc == free)
			printf("\033[1;32m[MOK]:\033[1;92m %d malloc, %d free\033[0m\n", malloc, free);
		else
			printf("\033[1;31m[MKO]: %d malloc , %d free { %s}\033[0m\n", malloc, free, tab);
		return ;
	}

	/* Part for FALSE test*/
	if (compare == false && g_mode != TRUE)
	{
		Process.spawn_command_line_sync(@"$push_swap_emp $tab", out output, out errput, out wait_status);
		if (errput == "Error\n" && output == "")
			printf("\033[1;32mOK \033[0m");
		else
			printf("\033[1;31mKO [ %s] \033[0m", tab);
	}
	/* Part for TRUE test*/
	else if (compare == true && g_mode != FALSE){
		string? contents = null;
		int fd_out;
		int fd;

		Shell.parse_argv(@"$push_swap_emp $tab", out argvp);
		Process.spawn_async_with_pipes(null, argvp, null, SEARCH_PATH, null, null, null, out fd, null);
		Shell.parse_argv(@"./checker_linux $tab", out argvp);
		Process.spawn_async_with_pipes_and_fds (null, argvp, null, SEARCH_PATH, null, fd, -1, -1, {}, {}, null, null, out fd_out, null);

		var stream = new IOChannel.unix_new (fd_out);
		stream.read_to_end(out contents, null);
		
		if (contents != null && "OK" in contents)
			printf("\033[1;32mOK \033[0m");
		else if (contents != null && "KO" in contents)
			printf("\033[1;31mKO [ %s] \033[0m", tab);
		else
			printf("\033[1;31mKO [ %s] \033[0m", tab);
	}
}

/* change string[] to string */
string tab_to_string(string[] tab)
{
	var str = new StringBuilder.sized(tab.length * 5);
	foreach (var i in tab) {
		str.append_c('\"');
		str.append(i);
		str.append("\" ");
	}
	return ((owned)str.str);
}

async void argument_option (string []args) throws Error {
	/* ARGV main */
	g_mode = ALL;
	if (args.length > 1) {
		if (args[1] == "help" || args[1] == "-h")
			printf("\n[Help]\ntester_push_swap [true|false|leak|valgrind| puissance(int)] [iteration(int)] \n");
		else if (args[1] == "leak" || args[1] == "valgrind")
			g_mode = MEMORY_LEAK;
		else if (args[1] == "true")
			g_mode = TRUE;
		else if (args[1] == "false")
			g_mode = FALSE;
		if (g_mode != ALL) {
			list_test();
			return ;
		}
	}
	if (args.length == 1)
		list_test();
	else
		yield calc_moy(args);
}

private bool search_path (string path) {
	printf("`%s` ", path);
	return (FileUtils.test(path, FileTest.EXISTS) && !FileUtils.test(path, FileTest.IS_DIR));
}


public class Config {

	public void parse(string[] args) throws Error {
		var context = new GLib.OptionContext("[(true|false) | (leak|valgrind) | (puissance [iteration])]");
		context.set_help_enabled(true);
		context.set_ignore_unknown_options(true);
		context.add_main_entries(options, null);
		context.set_description("""
%3$s42 push_swap tester in vala%2$s

%1$sMode:%2$s :
  %3$sParsing:%2$s
  - true : test only the good input
  - false : test only the bad input
  
  %3$sMemory:%2$s
  - leak or valgrind: test the memory leak
  
  %3$sPerformance:%2$s
  - puissance : test the puissance of the tester
  - iteration : test the iteration of the tester
  %1$sex%2$s: tester_push_swap 500 1000
  	it will test 1000 push_swap with 500 numbers each 

%1$sExample:%2$s

%4$s# Test the parsing%2$s
./tester_push_swap true
./tester_push_swap false

%4$s# Test the memory leak%2$s
./tester_push_swap leak

%4$s# Test the performance%2$s
./tester_push_swap 100
./tester_push_swap 500 
./tester_push_swap 100 1000


""".printf("\033[34;1m", "\033[0m", "\033[33;1m", "\033[32;1m"));
		context.parse(ref args);
	}

	private const GLib.OptionEntry[] options = {
		{ "path", '\0', OptionFlags.NONE, OptionArg.STRING, ref push_swap_emp, "The Path of the push_swap executable", "push_swap" },
		{ null }
	};
}

async int main(string []args)
{
	var config = new Config();
	config.parse(args);


	if (push_swap_emp == null) {
		/* Search the good path of push_swap */
		string []paths_push_swap = {"./push_swap", "../push_swap", "../push_swap/push_swap"};

		printf("\033[96;1m[INFO] search ");
		foreach (unowned var path in paths_push_swap) {
			if (search_path(path) == true) {
				push_swap_emp = path;
				break ;
			}
		}
		printf("\033[0m\n");
	}
	if (push_swap_emp == null ) {
		printf("\033[96;1m[INFO] \033[0m ../push_swap not found \n");
		return(-1);
	}
	if (FileUtils.test(push_swap_emp, FileTest.EXISTS) == false) 
	{
		printf("\033[31m[ERROR]: \033[91m%s non trouvée.\n", push_swap_emp);
		return (1);
	}
	FileUtils.chmod(push_swap_emp, 0755);

	/* Search the good path of push_swap */
	if (FileUtils.test("./checker_linux", FileTest.EXISTS) == false) {
		Posix.system("wget -c https://cdn.intra.42.fr/document/document/28256/checker_linux -q --show-progress");
		printf("\n");
	}
	if (FileUtils.test("./checker_linux", FileTest.EXISTS) == false) {
		printf("[ERROR]: checker_linux non trouvée.\n");
		return (1);
	}
	FileUtils.chmod("checker_linux", 0755);

	try {
		yield argument_option(args);
	} catch (Error e) {
		printerr(e.message);
		return -1;
	}
	return 0;
}
