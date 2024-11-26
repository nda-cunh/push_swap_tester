//valac moy.vala main.vala --pkg=posix --vapidir=./vapi 
const string GREEN = "\033[1;92m";
const string BLUE = "\033[1;36m";
const string YELLOW = "\033[1;93m";
const string ORANGE = "\033[1;91m";
const string RED = "\033[1;31m";
const string WHITE = "\033[1;37m";
const string NONE = "\033[0m";

private int[] ft_get_random_tab(int size)
{
    var tab = new int[size];
    var n = 0;
	var rand = new Rand();
    
    for (var i = 0; i != size; ++i)
    {
        n = rand.int_range(0, 20000);
        if (n in tab)
            --i;
        else
            tab[i] = n;
    }
    return (tab);
}

class PushSwap {
	public int[] tab_input;
	public string output;
	public string output_checker;
	public int count = 0;
	string []argv;
	public bool is_timeout = false;

	public static async PushSwap run (int nbr) throws Error {
		var self = new PushSwap ();
		yield self.init_power (nbr);
		yield self.run_push_swap_exec ();
		if (self.is_timeout == false)
			yield self.run_checker ();
		return self;
	}

	private async void init_power (int power) {
		var t = new Thread<void>(null, ()=> {
			tab_input = ft_get_random_tab (power);
			foreach (unowned var i in tab_input) {
				argv += i.to_string();
			}
			count = 0;
			Idle.add (init_power.callback);
		});
		yield;
		t.join();
	}
	private async int count_me (string output) {
		int index = 0;
		while ((index = output.index_of_char ('\n', index + 1)) != -1) {
			++count;
		}
		return (count);
	}

	private async void run_push_swap_exec () throws Error {
		var bs = new StrvBuilder();
		bs.add (push_swap_emp);
		if (argv != null)
			bs.addv (argv);

		var proc = new Subprocess.newv (bs.end(), STDOUT_PIPE | STDERR_MERGE);
		var source = Timeout.add (Config.timeout, ()=> {
			proc.force_exit ();
			is_timeout = true;
			output = "Error\n";
			count = 0;
			return false;
		});
		yield proc.communicate_utf8_async (null, null, out output, null);
		if (is_timeout == false) {
			count = yield count_me(output);
			Source.remove (source);
		}
	}

	private async void run_checker () throws Error {
		var bs = new StrvBuilder();
		bs.add ("./checker_linux");
		if (argv != null)
			bs.addv (argv);
		var proc = new Subprocess.newv (bs.end(), STDOUT_PIPE | STDIN_PIPE | SubprocessFlags.STDERR_MERGE);
		yield proc.communicate_utf8_async (output, null, out output_checker, null);
		output_checker._delimit ("\n", '\0');
	}
	
	private static void simple_print () {
		double moyenne = moy_count / array.length;
		double ecart_type = CalculateEcartType (moyenne);
		if (moyenne.is_nan ())
			moyenne = 0;
		if (ecart_type.is_nan ())
			ecart_type = 0;
		print ("\033[2K\033[35;1mMax: %s%d\n", color (max_count), max_count);
		print ("\033[2K\033[35;1mMin: %s%d\n", color (min_count), min_count);
		print ("\033[2K\033[34;1mAverage:\033[34;0m %s%g\n", color ((int)moyenne), moyenne);
		print("\033[2K\033[34;1mstandard deviation:\033[34;0m %g\n", ecart_type);
		print ("\033[2K%s | %s | %s\n", (nbr_ko == 0 ? "\033[32;1mKO 0" : @"\033[31;1mKO $nbr_ko"),
			(nbr_err == 0 ? "\033[32;1mError 0" : @"\033[31;1mError $nbr_err"),
			(nbr_timeout == 0 ? "\033[32;1mTimeout 0" : @"\033[31;1mTimeout $nbr_timeout"));
		print ("\033[2K\033[33;1mTest %d / %d\033[0m\n", nbr_test, nbr_max);
	}

	private static void draw_result (PushSwap? new_push_swap = null) {
		if (new_push_swap != null)
		{
			if (new_push_swap.is_timeout == true) {
				error_text += "Timeout: [\"%s\"]\n\n".printf(string.joinv ("\" \"", new_push_swap.argv));
				nbr_timeout += 1;
				moy_count += 10000;
				return ;
			}
			if (max_count < new_push_swap.count)
				max_count = new_push_swap.count;
			if (min_count == 0 || min_count > new_push_swap.count)
				min_count = new_push_swap.count;
			if (new_push_swap.output_checker == "KO") {
				error_text += "Ko : [\"%s\"]\n\n".printf(string.joinv ("\" \"", new_push_swap.argv));
				nbr_ko++;
			}
			if (new_push_swap.output_checker == "Error" || new_push_swap.output_checker == "Error\n") {
				error_text += "Error : [\"%s\"]\n\n".printf(string.joinv ("\" \"", new_push_swap.argv));
				nbr_err++;
			}
			moy_count += new_push_swap.count;
			print("\033[6A");
		}
		simple_print ();
	}

	private static unowned string color (int nb) {
		if (power <= 3)
		{
			if (nb <= 2)
				return GREEN;
			else
				return RED;
		}
		else if (power <= 5)
		{
			if (nb <= 12)
				return GREEN;
			else
				return RED;
		}
		else if (power <= 100)
		{
			if (nb <= 700)
				return GREEN;
			if (nb < 900)
				return BLUE;
			if (nb < 1100)
				return YELLOW;
			if (nb < 1500)
				return ORANGE;
			return RED;
		}
		else if (power <= 500)
		{
			if (nb < 5500)
				return GREEN;
			if (nb < 7000)
				return BLUE;
			if (nb < 8500)
				return YELLOW;
			if (nb < 11500)
				return ORANGE;
			return RED;
		}
		else
			return WHITE;
	}

	private static double CalculateEcartType(double moyenne)
    {
        double sumOfSquares = 0;
        foreach (unowned var value in array) {
            sumOfSquares += Math.pow(value.count - moyenne, 2);
        }
        return Math.sqrt(sumOfSquares / array.length);
    }


	/* Static */

	public static PushSwap []array;
	public static string error_text;
	public static int max_count;
	public static int min_count;
	public static double moy_count;
	public static int nbr_max;
	public static int nbr_test;
	public static int nbr_ko;
	public static int nbr_err;
	public static int nbr_timeout;
	public static int power = 0;

	public static async void exec_all_push_swap (int nbr, int power) throws Error {
		PushSwap.power = power;
		int job_max = 0;
		error_text = "";
		max_count = 0;
		min_count = 0;
		moy_count = 0;
		nbr_max = nbr;
		nbr_test = 0;
		nbr_ko = 0;
		nbr_err = 0;
		nbr_timeout = 0;

		print ("\033[42m 5 \033[46m 4 \033[103m 3 \033[101m 2 \033[41m 1 \033[0m\n");
		draw_result (null);

		while (job_max != 0 || nbr != 0) {
			if (job_max == get_num_processors ()) {
				Idle.add (exec_all_push_swap.callback);
				yield;
				continue;
			}
			if (nbr == 0) {
				Idle.add (exec_all_push_swap.callback);
				yield;
				continue;
			}
			++job_max;
			PushSwap.run.begin(power, (obj, res) => {
				try {
					var p = PushSwap.run.end(res);
					array += p;
					draw_result (p);
				}
				catch (Error e) {
					printerr("Error: %s\n", e.message);
				}
				++nbr_test;
				--job_max;
			});
			--nbr;
		}
		for (int i = 0; i < 6; ++i) {
			print("\033[1A\033[2K");
		}
		if (error_text != "") {
			printerr("\033[91m%s\033[0m", error_text);
		}
		draw_result (null);
	}
}

// main of moy.vala
async void calc_moy(string []args) throws Error {
    var power = args[1] != null ? int.parse(args[1]) : 10;
    var nbr = args.length > 2 ? int.parse(args[2]) : 10;

	if (power > 10000 || power <= 0) {
		printerr("[Error]: Max of tester_pushwap is %d / 10000\n", power);
		return ;
	}
	
	if (nbr <= 0) {
		printerr("[Error]: can't iterate %d time\n", nbr);
		return ;
	}

	yield PushSwap.exec_all_push_swap(nbr, power);
}
