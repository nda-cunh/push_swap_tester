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
			n++;
		i++;
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

// worker
async int run_push_swap(int power) {
	var thread = new Thread<string>("async moyenne", () => {
		var result = "";
		var tab = ft_get_random_tab(power + 1);
		var av = ft_tab_to_string(tab);
		try {
			var pid = new Subprocess.newv({"push_swap", @"$av"}, SubprocessFlags.STDOUT_PIPE);
			var output = pid.get_stdout_pipe();
			uint8 buffer[32768] = {};
			size_t len;
			while ((len = output.read(buffer)) > 0) {
				buffer[len] = '\0';
				result += (string)buffer;
			}
			pid.wait();
		} catch (Error e) {
			printerr(e.message);
		}
		Idle.add(run_push_swap.callback);
		return result; 
	});
	yield;
	return count_line(thread.join());
}


async int []exec_all_push_swap(int nbr, int power) {
	uint begin = 0;
	uint max = get_num_processors() * 2;
	int []result = {};

	for (int i = 0; i < nbr; ++i) {
		begin++;
		Idle.add(() => {
			run_push_swap.begin(power, (obj, res)=> {
				var nb_hit = run_push_swap.end(res);
				result += nb_hit;
				print_line(power, nb_hit, "Nombre de coups : ");
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
