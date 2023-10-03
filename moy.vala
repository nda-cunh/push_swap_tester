//valac moy.vala main.vala --pkg=posix --vapidir=./vapi 
const string GREEN = "\033[1;92m";
const string BLUE = "\033[1;36m";
const string YELLOW = "\033[1;93m";
const string ORANGE = "\033[1;91m";
const string RED = "\033[1;31m";
const string NONE = "\033[0m";

int[] ft_get_random_tab(int size)
{
    var tab = new int[size];
    var n = 0;
	var rand = new Rand();
    
    for (var i = 0; i != size; ++i)
    {
        n = rand.int_range(int.MIN, int.MAX);
        if (n in tab)
            --i;
        else
            tab[i] = n;
    }
    return (tab);
}

string ft_tab_to_string(int []tab)
{
    var str = "";
    foreach (var i in tab)
        str += i.to_string() + " ";
    return(str);
}

int count_line(char *s) {
	var i = 0;
	var n = 0;

	while (s[i] != '\0') {
		if (s[i] == '\n')
			++n;
		++i;
	}
	return n;
}

void print_line(int power, int nbr, string msg) {
	if (power <= 100)
	{
		if (nbr < 700)
			stdout.printf("%s %s%d\033[0m\n", msg, GREEN, nbr); 
		else if (nbr < 900)
			stdout.printf("%s %s%d\033[0m\n", msg, BLUE, nbr); 
		else if (nbr < 1100)
			stdout.printf("%s %s%d\033[0m\n", msg, YELLOW, nbr); 
		else if (nbr < 1500)
			stdout.printf("%s %s%d\033[0m\n", msg, ORANGE, nbr); 
		else
			stdout.printf("%s %s%d\033[0m\n", msg, RED, nbr); 
	}
	else if (power <= 500)
	{
		if (nbr < 5500)
			stdout.printf("%s %s%d\033[0m\n", msg, GREEN, nbr); 
		else if (nbr < 7000)
			stdout.printf("%s %s%d\033[0m\n", msg, BLUE, nbr); 
		else if (nbr < 8500)
			stdout.printf("%s %s%d\033[0m\n", msg, YELLOW, nbr); 
		else if (nbr < 11500)
			stdout.printf("%s %s%d\033[0m\n", msg, ORANGE, nbr); 
		else
			stdout.printf("%s %s%d\033[0m\n", msg, RED, nbr); 
	}
	else
		stdout.printf("%s \033[37m%d033[0m\n", msg, nbr);
}

bool test_push_swap(ref string av, ref string input) {
	try {
		uint8 buffer[16];
		size_t len = 0;
		var pid = new Subprocess.newv({"./checker_linux", av}, SubprocessFlags.STDOUT_PIPE | SubprocessFlags.STDIN_PIPE);

		var @in = pid.get_stdin_pipe();
		var @out = pid.get_stdout_pipe();

		// read all input pipe
		in.write_all(input.data, out len);
		in.close();
		
		// write all output pipe
		out.read_all(buffer, out len);
		buffer[len] = '\0';
		out.close();
		
		pid.wait();
		if ((string)buffer == "OK")
			return true;
		return false;
	}
	catch(Error e) {
		printerr("%s\n", e.message);
	}
	return false;
}


// worker
async PushSwap run_push_swap(int power) {
	bool test = false;
	var thread = new Thread<string?>("async moyenne", () => {
		string? result = null;
		var tab = ft_get_random_tab(power + 1);
		var av = ft_tab_to_string(tab);
		try {
			var pid = new Subprocess.newv({push_swap_emp, av}, SubprocessFlags.STDOUT_PIPE);
			var output = pid.get_stdout_pipe();
			uint8 buffer[65536] = {};
			size_t len;
			while ((len = output.read(buffer)) > 0) {
				buffer[len] = '\0';
				if (result == null)
					result = (string)buffer;
				else
					result += (string)buffer;
			}
			test = test_push_swap(ref av, ref result);
			pid.wait();

		} catch (Error e) {
			printerr(e.message);
		}
		Idle.add(run_push_swap.callback);
		return result; 
	});
	yield;
	return PushSwap(count_line(thread.join()), test);
}

struct PushSwap {
	int count_line;
	bool status;
	PushSwap(int count, bool status) {
		this.count_line = count;
		this.status = status;
	}
	public void print_status() {
			if (this.status)
			stdout.printf("\033[31m[OK]\033[0m ");
		else
			stdout.printf("\033[32m[KO]\033[0m ");
	}
}

async int []exec_all_push_swap(int nbr, int power) {
	uint begin = 0;
	uint max = get_num_processors() * 2;
	int []result = {};

	for (int i = 0; i < nbr; ++i) {
		begin++;
		Idle.add(() => {
			run_push_swap.begin(power, (obj, res)=> {
				var pushswap = run_push_swap.end(res);
				result += pushswap.count_line;
				pushswap.print_status();
				print_line(power, pushswap.count_line, "Nombre de coups : ");
				begin--;
			});
			return false;
		});
		while (begin == max) {
			Idle.add(exec_all_push_swap.callback);
			yield;
		}
	}
	// Wait all thread
	while (result.length != nbr) {
		Idle.add(exec_all_push_swap.callback);
		yield;
	}
	return result;
}

// main of moy.vala
void calc_moy(string []args) {
    var power = args[1] != null ? int.parse(args[1]) : 10;
    var nbr = args.length > 2 ? int.parse(args[2]) : 10;

	var loop = new MainLoop();
	Idle.add(() => {
		exec_all_push_swap.begin(nbr, power, (obj, res)=> {
			var tab = exec_all_push_swap.end(res);
			print_result(power, tab);
			loop.quit();
		});
		return false;
	});
	loop.run();
}

void print_result(int power, int []tab) {
	var moyenne = 0;
	var min = int.MAX;
	var max = 0;
	foreach (var i in tab) {
		if (i > max)
			max = i;
		if (i < min)
			min = i;
		moyenne += i;
	}
	moyenne = moyenne / tab.length;
	stdout.printf("\n");
	print_line(power, moyenne, "[Moyenne]: ");
	print_line(power, max, "[Max]:     ");
	print_line(power, min, "[Min]:     ");
}
