using Posix;

private const string URL_CHECKER = "https://cdn.intra.42.fr/document/document/28256/checker_linux";
public string? push_swap_emp = null;

/* where is the push_swap default to "./push_swap" */
private Mode g_mode = ALL;

/* mode of the tester */
enum Mode {
	ALL, TRUE, FALSE, MEMORY_LEAK
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

  %3$sVisualiser:%2$s
  - gui : download and run the graphical visualiser

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

	public static bool visualiser = false;
	public static int timeout = 3000;
	private const GLib.OptionEntry[] options = {
		{ "path", 'p', OptionFlags.NONE, OptionArg.STRING, ref push_swap_emp, "The Path of the push_swap executable", "push_swap" },
		{ "gui", 'g', OptionFlags.NONE, OptionArg.NONE, ref visualiser, "download and run the graphical visualiser", "push_swap" },
		{ "timeout", 't', OptionFlags.NONE, OptionArg.INT, ref timeout, "timeout of the tester (default 3000)", "ms" },
		{ null }
	};
}

async void argument_option (string []args) throws Error {
	/* ARGV main */
	g_mode = ALL;
	if (Config.visualiser == true) {
		if (FileUtils.test("visualizer", FileTest.EXISTS) == false) {
			Process.spawn_command_line_sync ("git clone https://gitlab.com/nda-cunh/visualizer-push-swap visualizer");
		}
		if (FileUtils.test("visualizer/visualizer", FileTest.EXISTS) == false) {
			Process.spawn_sync ("./visualizer", {"./install.sh"}, null, 0, null);
		}
		Process.spawn_sync ("./visualizer", {"./visualizer", "--push_swap=../" + push_swap_emp}, null, 0, null);
		return ;
	}
	else if (args.length > 1) {
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
