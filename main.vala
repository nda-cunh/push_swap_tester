using Posix;

private const string URL_CHECKER = "https://cdn.intra.42.fr/document/document/28256/checker_linux";
public string? push_swap_emp = null;

/* where is the push_swap default to "./push_swap" */
Mode g_mode = ALL;

/* mode of the tester */
enum Mode {
	ALL, TRUE, FALSE, MEMORY_LEAK
}

/* All test you can add some test here */
async void list_test() throws Error
{
	/* TRUE = GOOD  */
	/* FALSE = ERROR */
	new PushSwapTest().test.begin({"+000000001", "5", "3", "-5"}, true);
	new PushSwapTest().test.begin({"+ 000000001", "5", "3", "-5"}, false);
	new PushSwapTest().test.begin({"+52"}, true);
	new PushSwapTest().test.begin({"+52", "-5"}, true);
	new PushSwapTest().test.begin({"52"}, true);
	new PushSwapTest().test.begin({""}, false);
	new PushSwapTest().test.begin({" "}, false);
	new PushSwapTest().test.begin({"  "}, false);
	new PushSwapTest().test.begin({"5", "4", "3"}, true);
	new PushSwapTest().test.begin({"5", "1", "0", "2"}, true);
	new PushSwapTest().test.begin({"5 1 + 000000 2"}, false);
	new PushSwapTest().test.begin({"5", "", "0", "2"}, false);
	new PushSwapTest().test.begin({"5 4A 3"}, false);
	new PushSwapTest().test.begin({"5 2 3 4 8"}, true);
	new PushSwapTest().test.begin({"42 -500 -2845 -21 54784 1541"}, true);
	new PushSwapTest().test.begin({"42", "500", "-2845", "-21", " 54784", "1541"}, true);
	new PushSwapTest().test.begin({"52 14 15"}, true);
	new PushSwapTest().test.begin({"e1 2 3 4 5"}, false);
	new PushSwapTest().test.begin({"1 2 4 3 5e"}, false);
	new PushSwapTest().test.begin({"1 2 3 4 5e"}, false);
	new PushSwapTest().test.begin({"+", "52"}, false);
	new PushSwapTest().test.begin({"1 2 3"}, true);
	new PushSwapTest().test.begin({" 1 2 3"}, true);
	new PushSwapTest().test.begin({"1 2 3 "}, true);
	new PushSwapTest().test.begin({" 1 2 3 "}, true);
	new PushSwapTest().test.begin({" 1   2               3 "}, true);
	new PushSwapTest().test.begin({"1 2 3 4 5"}, true);
	new PushSwapTest().test.begin({"5 4 3 2 1"}, true);
	new PushSwapTest().test.begin({"5", "3", "2", "1"}, true);
	new PushSwapTest().test.begin({" 5", "3  ", " 2", " 1"}, true);
	new PushSwapTest().test.begin({"4", "000000000000000000000000000000000000000000000000000000002"}, true);
	new PushSwapTest().test.begin({" 5", "8"}, true);
	new PushSwapTest().test.begin({"05 02"}, true);
	new PushSwapTest().test.begin({"2147483647 -2147483648"}, true);
	new PushSwapTest().test.begin({"0002147483647 -002147483648"}, true);
	new PushSwapTest().test.begin({"05 08 0009 00010 2"}, true);
	new PushSwapTest().test.begin({"05 5 005"}, false);
	new PushSwapTest().test.begin({"-00", "00"}, false);
	new PushSwapTest().test.begin({"052 02"}, true);
	new PushSwapTest().test.begin({"-0", "0"}, false);
	new PushSwapTest().test.begin({"0", "-0"}, false);
	new PushSwapTest().test.begin({"-10", "-23"}, true);
	new PushSwapTest().test.begin({"-0"}, true);
	new PushSwapTest().test.begin({"4 2 3", "5"}, true);
	new PushSwapTest().test.begin({"5", "4", "3"}, true);
	new PushSwapTest().test.begin({"10 5 4 2 1 3 6 9"}, true);
	new PushSwapTest().test.begin({"5-2"}, false);
	new PushSwapTest().test.begin({"5+2"}, false);
	new PushSwapTest().test.begin({"2-5"}, false);
	new PushSwapTest().test.begin({"2+5"}, false);
	new PushSwapTest().test.begin({"2", "", "3"}, false);
	new PushSwapTest().test.begin({"3", "", "2"}, false);
	new PushSwapTest().test.begin({"", ""}, false);
	new PushSwapTest().test.begin({"", " "}, false);
	new PushSwapTest().test.begin({" ", ""}, false);
	new PushSwapTest().test.begin({"   ", " ", "   "}, false);
	new PushSwapTest().test.begin({"   ", "-", "   "}, false);
	new PushSwapTest().test.begin({"   ", "-a", "   "}, false);
	new PushSwapTest().test.begin({"   -a   "}, false);
	new PushSwapTest().test.begin({"++52"}, false);
	new PushSwapTest().test.begin({"+-52"}, false);
	new PushSwapTest().test.begin({"9 2147483648 5"}, false);
	new PushSwapTest().test.begin({"9 -2147483649 8"}, false);
	new PushSwapTest().test.begin({"9 214748364842 5"}, false);
	new PushSwapTest().test.begin({"9 -21474836494 8"}, false);
	new PushSwapTest().test.begin({"8 -214748364945465565656"}, false);
	new PushSwapTest().test.begin({"25 514748364945465565656"}, false);
	new PushSwapTest().test.begin({"4", "999999999999999"}, false);
	new PushSwapTest().test.begin({"12          "}, true);
	new PushSwapTest().test.begin({"454845456689864", "5455464454545"}, false);
	// bdany - ppuiv 
    new PushSwapTest().test.begin({"1", "0", " "}, false);
    new PushSwapTest().test.begin({" ", "2", "1"}, false);
    new PushSwapTest().test.begin({"4", " ", "3"}, false);
    new PushSwapTest().test.begin({"", "4", "2"}, false); 
	while (worker != 0 && test_end != test_begin) {
		Idle.add(list_test.callback);
		yield;
	}
}

private int worker = 0;
private int test_begin = 0;
private int test_end = 0;

private class PushSwapTest {
	public async void test(string[] argv, bool compare) throws Error
	{
		test_begin += 1;
		var arg = argv.copy();

		while (worker >= 16) {
			Idle.add(test.callback);
			yield;
		}
		++worker;
		/* Memory Part */
		if (g_mode == MEMORY_LEAK)
		{
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
				printf("\033[1;32m[MOK]:\033[1;92m %d malloc, %d free\033[0m\n", malloc, free);
			else
				printf("\033[1;31m[MKO]: %d malloc , %d free { %s}\033[0m\n", malloc, free, tab);
			--worker;
			test_end += 1;
			return ;
		}

		/* Part for FALSE test*/
		if (compare == false && g_mode != TRUE)
		{
			StrvBuilder bs = new StrvBuilder();
			bs.add(push_swap_emp);
			bs.addv(arg);
			var proc = new Subprocess.newv (bs.end(), STDOUT_PIPE | STDERR_PIPE);
			yield proc.communicate_utf8_async (null, null, out output, out errput);
			yield proc.wait_async();
			if (errput.has_prefix("Error\n") && output == "")
				printf("\033[1;32mOK \033[0m");
			else
				printf("\033[1;31mKO [ %s] \033[0m", tab);
		}
		/* Part for TRUE test*/
		else if (compare == true && g_mode != FALSE){
			// run push_swap
			StrvBuilder bs = new StrvBuilder();
			bs.add(push_swap_emp);
			bs.addv(arg);
			var proc = new Subprocess.newv (bs.end(), STDOUT_PIPE | STDERR_PIPE);
			yield proc.communicate_utf8_async (null, null, out output, out errput);
			yield proc.wait_async();

			// run checker

			bs = new StrvBuilder();
			bs.add("./checker_linux");
			bs.addv(arg);
			string contents;
			proc = new Subprocess.newv (bs.end(), STDIN_PIPE | STDOUT_PIPE | STDERR_MERGE);
			yield proc.communicate_utf8_async (output, null, out contents, out errput);
			yield proc.wait_async();

			if (contents != null && "OK" in contents)
				printf("\033[1;32mOK \033[0m");
			else if (contents != null && "KO" in contents)
				printf("\033[1;31mKO [ %s] \033[0m", tab);
			else
				printf("\033[1;31mKO [ %s] \033[0m", tab);
		}
		--worker;
		test_end += 1;
	}

	public string? _tab = null; 
	public string tab {
		get {
			if (_tab == null)
				_tab = tab_to_string(argvp);
			return _tab;
		}
	}
	public string []argvp;
	public string output;
	public string errput;
}

/* change string[] to string {"a", "b", "c"}  --> '"a" "b" "c"' */
string tab_to_string(string[] tab)
{
	return "\"" + string.joinv("\" \"", tab) + "\"";
}

async void argument_option (string []args) throws Error {
	/* ARGV main */
	g_mode = ALL;
	if (args.length > 1) {
		if (args[1] == "leak" || args[1] == "valgrind")
			g_mode = MEMORY_LEAK;
		else if (args[1] == "true")
			g_mode = TRUE;
		else if (args[1] == "false")
			g_mode = FALSE;
		if (g_mode != ALL) {
			yield list_test();
			return ;
		}
	}
	if (args.length == 1)
		yield list_test();
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
	try {
		var config = new Config();
		config.parse(args);

		if (push_swap_emp == null) {
			/* Search the good path of push_swap */
			const string []paths_push_swap = {"./push_swap", "../push_swap", "../push_swap/push_swap"};

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
			Posix.system("wget -c " + URL_CHECKER + " -q --show-progress");
			printf("\n");
		}
		if (FileUtils.test("./checker_linux", FileTest.EXISTS) == false) {
			printf("[ERROR]: checker_linux non trouvée.\n");
			return (1);
		}
		FileUtils.chmod("checker_linux", 0755);

		yield argument_option(args);
	} catch (Error e) {
		printerr(e.message);
		return -1;
	}
	return 0;
}
